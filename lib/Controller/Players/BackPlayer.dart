

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:smartshuffle/Controller/AppManager/DatabaseController.dart';
import 'package:smartshuffle/Controller/AppManager/GlobalQueue.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Players/FrontPlayer.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Model/Util.dart';
class AudioPlayerTask extends BackgroundAudioTask {

  static const int DEFAULT_LENGTH_QUEUE = 5;
  final AudioPlayer _player = AudioPlayer();
  List<MediaItem> _queue = <MediaItem>[];
  List<Track> trackQueue = <Track>[];
  int currentIndex = 0;

  bool _isTrackDone = false;

  @override
  Future<void> onStart(Map<String, dynamic> params) async {

    PlatformsLister.initBackPlayer();
    await DataBaseController().backDatabase;

    // Listen to state changes on the player...
    _player.playerStateStream.listen((playerState) {
      // ... and forward them to all audio_service clients.
      AudioServiceBackground.setState(
        playing: playerState.playing,
        // Every state from the audio player gets mapped onto an audio_service state.
        processingState: {
          ProcessingState.loading: AudioProcessingState.connecting,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[playerState.processingState],
        // Tell clients what buttons/controls should be enabled in the
        // current state.
        controls: [
          MediaControl.skipToPrevious,
          playerState.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: [
          MediaAction.seekTo,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        ]
      );
    });

    return super.onStart(params);
  }

  Future<void> _nextTrack() async {
    await AudioService.pause();

    if(currentIndex+1 >= trackQueue.length) {
      currentIndex = 0;
    }
    await _playTrack(trackQueue[currentIndex+1]);
    currentIndex++;
  }

  @override
  Future<void> onSkipToNext() async {
    await _nextTrack();
    AudioServiceBackground.sendCustomEvent('SKIP_NEXT');
    _queueLoader();
    // return super.onSkipToNext();
  }

  Future<void> _previousTrack() async {
    await AudioService.pause();
    await _playTrack(trackQueue[currentIndex-1]);
    currentIndex--;
  }

  @override
  Future<void> onSkipToPrevious() async {
    if(_player.position.inSeconds <= 2 && (currentIndex-1) >= 0) {
      await _previousTrack();
    } else {
      AudioService.seekTo(Duration.zero);
    }
    AudioServiceBackground.sendCustomEvent('SKIP_PREVIOUS');
    // return super.onSkipToPrevious();
  }

  @override
  Future<void> onStop() async {
    AudioServiceBackground.setState(
      controls: [],
      playing: false,
      processingState: AudioProcessingState.none
    );
    AudioServiceBackground.sendCustomEvent('STOP');
    await _player.stop();
    await _player.dispose();
    return super.onStop();
  }

  @override
  Future<void> onPause() async {
    AudioServiceBackground.setState(
      playing: false,
      processingState: AudioProcessingState.ready
    );
    await _player.pause();
    return super.onPause();
  }

  @override
  Future<void> onPlay() async {
    AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.ready
    );
    await _player.play();
    return super.onPlay();
  }

  @override
  Future<void> onSeekTo(Duration position) async {
    // _currentTrack.seekTo(position, false);
    await _player.seek(position);
    AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.ready,
      position: position
    );
    return super.onSeekTo(position);
  }
  
  Future<MapEntry<Track, File>> _getFilePath(Track track) async {
    MediaItem searchingItem = _queue.firstWhere((element) => 
      (element.extras['track_id'] == track.id && element.extras['service_name'] == track.serviceName),
      orElse: () => null);
    if(searchingItem != null) {
      MapEntry<Track, File> me = MapEntry<Track, File>(
        Track(
          id: searchingItem.id,
          title: track.title,
          artist: track.artist,
          imageUrlLittle: track.imageUrlLittle,
          imageUrlLarge: track.imageUrlLarge,
          totalDuration: track.totalDuration.value
        ),
        File.fromUri(Uri.file(searchingItem.id))
      );
      return Future<MapEntry<Track, File>>.value(me);
    } else {
      File file = await track.loadFile();
      if(file != null) {
        _synchroTrackMediaitem(file, track, track);
        return MapEntry(track, file);
      } else {
        return MapEntry(track, null);
      }
    }
  }
  
  void _synchroTrackMediaitem(File file, Track foundTrack, Track track) {
    final MediaItem mediaItem = MediaItem(
      id: file.path,
      album: track.artist,
      title: track.title,
      artUri: Uri.parse(track.imageUrlLarge),
      duration: foundTrack.totalDuration.value,
      extras: {'track_id': track.id, 'service_name': track.serviceName}
    );
    _queue.add(mediaItem);
  }

  Future<void> _playTrack(Track track) async {

    if (AudioService.playbackState != null) {
      await AudioService.seekTo(Duration.zero);
      await AudioService.pause();
    }

    MapEntry<Track, File> foundTrack = await _getFilePath(track);

    if(foundTrack.value != null) {    
      final MediaItem mediaItem = _queue.firstWhere((element) => 
      (element.extras['track_id'] == track.id && element.extras['service_name'] == track.serviceName),
      orElse: () => null);

      if(foundTrack.key.id != null && mediaItem != null) {

        print(foundTrack.key);
        
        // Tell the UI and media notification what we're playing.
        AudioServiceBackground.setMediaItem(mediaItem);

        // Play when ready.
        if(!_player.playing) {
          _player.play();
        }

        // Start loading something (will play when ready).
        print('mediaitem : ${mediaItem.id}');
        await _player.setFilePath(mediaItem.id);
        _isTrackDone = false;
        
        _player.positionStream.listen(
          (position) {
            if(position.inSeconds >= AudioServiceBackground.mediaItem.duration.inSeconds-1) {
              if(!_isTrackDone) {
                AudioService.skipToNext();
              }
              _isTrackDone = true;
            }
          }
        );

      }

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        AudioServiceBackground.sendCustomEvent({'SNACKBAR': 'no_internet_connexion'});
      }

    } else {
      AudioServiceBackground.sendCustomEvent({'SNACKBAR': 'track_not_found'});
      AudioService.skipToNext();
    }

  }

  Duration _parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  @override
  Future onCustomAction(String type, arguments) async {

    switch(type) {

      case 'PLAY_TRACK' : {
        Track track = trackQueue[arguments['index']];
        MapEntry<Track, File> foundTrack = await _getFilePath(track);

        if(foundTrack.value != null) {
          // _synchroTrackMediaitem(foundTrack.value, foundTrack.key, track);

          currentIndex = arguments['index'];
          await _playTrack(track);
        } else {
          AudioServiceBackground.sendCustomEvent({'SNACKBAR': 'track_not_found'});
          AudioService.skipToNext();
        }

      } break;
      

      case 'LAUNCH_QUEUE' : {
        // await AudioService.pause();

        currentIndex = 0;
        trackQueue.clear();

        for(int i=0; i<arguments['queue']['id'].length; i++) {
          trackQueue.add(Track(
            id: arguments['queue']['id'][i],
            title: arguments['queue']['name'][i],
            artist: arguments['queue']['artist'][i],
            imageUrlLittle: arguments['queue']['imageurllittle'][i],
            imageUrlLarge: arguments['queue']['imageurllarge'][i],
            service: PlatformsLister.nameToService(arguments['queue']['service'][i]),
            totalDuration: _parseDuration(arguments['queue']['duration'][i])
          ));
        }

        _queueLoader();

      } break;


      case 'INSERT_ITEM' : {
        Track tr = Track(
          id: arguments['track']['id'],
          title: arguments['track']['name'],
          artist: arguments['track']['artist'],
          imageUrlLittle: arguments['track']['imageLittle'],
          imageUrlLarge: arguments['track']['imageLarge'],
          service: PlatformsLister.nameToService(arguments['track']['service'])
        );
        trackQueue.insert(arguments['index'], tr);
        MapEntry<Track, File> me = await _getFilePath(tr);
        if(me.value != null) {
          final MediaItem mi = MediaItem(
            id: me.value.path,
            album: tr.artist,
            title: tr.title,
            artUri: Uri.parse(tr.imageUrlLarge),
            duration: Duration(seconds: tr.totalDuration.value.inSeconds),
            extras: {'track_id': tr.id, 'service_name': tr.serviceName}
          );
          _queue.insert(arguments['index'], mi);
        }
        
      } break;


      case 'REMOVE_ITEM' : {
        _queue.removeWhere((element) => 
          element.extras['track_id'] == trackQueue[arguments['index']].id
          && element.extras['service_name'] == trackQueue[arguments['index']].serviceName
        );
        trackQueue.removeAt(arguments['index']);

      } break;


      case 'REMOVE_ITEM' : {
        trackQueue.removeAt(arguments['index']);

      } break;


      case 'REORDER_ITEM' : {
        Track track = trackQueue.removeAt(arguments['old_index']);
        trackQueue.insert(arguments['new_index'], track);
        _queueLoader();

      } break;


      case 'SKIP_NEXT' : {
        await _nextTrack();
        
      } break;


      case 'SKIP_PREVIOUS' : {
        await _previousTrack();
        
      } break;


      case 'INDEX_QUEUE_REQUEST' : {
        AudioServiceBackground.sendCustomEvent({'INDEX': trackQueue.indexOf(
          trackQueue.firstWhere((element) => 
            element.id == AudioServiceBackground.mediaItem.extras['track_id'] &&
            element.serviceName == AudioServiceBackground.mediaItem.extras['service_name'],
            orElse: null))
          }
        );

      } break;

    }
    

    return super.onCustomAction(type, arguments);
  }


  Future<List<MediaItem>> _queueLoader() async {
    for(int i=0; i<DEFAULT_LENGTH_QUEUE; i++) {

      if((currentIndex+1+i)<trackQueue.length) {

        Track track = trackQueue[currentIndex+1+i];

        if(
          _queue.firstWhere((element) => 
          (element.extras['track_id'] == track.id && element.extras['service_name'] == track.serviceName),
          orElse: () => null)
          == null
        ) {
          File file = await track.loadFile();

          if(file != null) {

            _synchroTrackMediaitem(file, track, track);

          } else {
            
            trackQueue.removeAt(currentIndex+1+i);
          
          }

        }

      }

    }

    return _queue;

  }


}



class PlayerListener {

  static final PlayerListener _instance = PlayerListener._singleton();
  Track _track;

  PlayerListener._singleton() {
    AudioService.playbackStateStream.listen(
      (data) {        
        if(data.playing == true && !_track.isPlaying.value) _track.resumeOnly();
        else if(data.playing == false && _track.isPlaying.value) _track.pauseOnly();
      }
    );
    AudioService.positionStream.listen(
      (data) {
        _track.seekTo(data, false);
      }
    );
    AudioService.customEventStream.listen(
      (data) {
        switch (data) {

          case 'STOP' : {
            _track.playing = false;
          } break;


          case 'SKIP_NEXT' : {
            FrontPlayerController().nextTrack(backProvider: true);
          } break;


          case 'SKIP_PREVIOUS' : {
            FrontPlayerController().previousTrack(backProvider: true, isSeekToZero: true);
          } break;


        }

        if(data is Map && data['INDEX'] != null) {
          FrontPlayerController().backIndex = data['INDEX'];
        }


      }
    );
  }
  
  factory PlayerListener() {
    return _instance;
  }

  void listen(Track track) {
    _track = track;

    for(MapEntry<Track, bool> me in GlobalQueue.queue.value) {
      me.key.selecting = false;
    }
    track.playing = true;
    
  }

}