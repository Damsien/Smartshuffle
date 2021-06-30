

import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart' as SM;
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/Youtube/SearchAlgorithm.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
class AudioPlayerTask extends BackgroundAudioTask {

  static const int DEFAULT_LENGTH_QUEUE = 5;
  final AudioPlayer _player = AudioPlayer();
  List<MediaItem> _queue = List<MediaItem>();
  List<Track> trackQueue = List<Track>();
  int currentIndex = 0;

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
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

  @override
  Future<void> onSkipToNext() async {
    await _playTrack(trackQueue[currentIndex]);
    AudioServiceBackground.sendCustomEvent('SKIP_NEXT');
    currentIndex++;
    _queueLoader();
    return super.onSkipToNext();
  }

  @override
  Future<void> onSkipToPrevious() async {
    await _playTrack(trackQueue[currentIndex]);
    AudioServiceBackground.sendCustomEvent('SKIP_PREVIOUS');
    currentIndex--;
    return super.onSkipToPrevious();
  }

  @override
  Future<void> onStop() async {
    AudioServiceBackground.setState(
      controls: [],
      playing: false,
      processingState: AudioProcessingState.stopped
    );
    AudioServiceBackground.sendCustomEvent('STOP');
    await _player.stop();
    return super.onStop();
  }

  @override
  Future<void> onPause() async {
    AudioServiceBackground.setState(
      playing: true,
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
  
  
  Future<Color> _getImagePalette (ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator
      .fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor?.color;
  }

  String _colorToHexString(Color color) {
    if(color != null)
      return '0xFF${color.value.toRadixString(16).substring(2, 8)}';
    else return null;
  }

  Future<int> _getMainImageColor(String imageUrl) async {
    return int.parse(_colorToHexString(await _getImagePalette(NetworkImage(imageUrl))));
  }

  Future<MapEntry<Track, File>> _getFilePath(Track track) async {
    MediaItem searchingItem = _queue.firstWhere((element) => 
      (element.extras['track_id'] == track.id && element.extras['track_service_name'] == track.serviceName),
      orElse: () => null);
    if(searchingItem != null) {
      MapEntry<Track, File> me = MapEntry<Track, File>(
        Track(
          id: searchingItem.id,
          name: track.name,
          artist: track.artist,
          imageUrlLarge: track.imageUrlLarge,
          totalDuration: track.totalDuration.value
        ),
        File.fromUri(Uri.file(searchingItem.id))
      );
      Completer c = Completer();
      c.complete(me);
      return c.future;
    } else {
      File file = await track.loadFile();
      return MapEntry(track, file);
    }
  }

  Future<void> _playTrack(Track track) async {
    // int notificationColor = await _getMainImageColor(track.imageUrlLarge);
    MapEntry<Track, File> foundTrack = await _getFilePath(track);

    // await AudioService.stop();
    final mediaItem = MediaItem(
      id: foundTrack.value.path,
      album: track.artist,
      title: track.name,
      artUri: Uri.parse(track.imageUrlLarge),
      duration: foundTrack.key.totalDuration.value
    );
    // Tell the UI and media notification what we're playing.
    AudioServiceBackground.setMediaItem(mediaItem);

    // Play when ready.
    _player.play();
    // Start loading something (will play when ready).
    print(mediaItem.id);
    await _player.setFilePath(mediaItem.id);
    
    _player.positionStream.listen(
      (position) {
        if(position.inMilliseconds >= _player.duration.inMilliseconds-900) {
          AudioService.skipToNext();
        }
      }
    );

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

      case 'LAUNCH_QUEUE' : {
        trackQueue.clear();
        for(int i=0; i<arguments['queue']['id'].length; i++) {
          trackQueue.add(Track(
            id: arguments['queue']['id'][i],
            name: arguments['queue']['name'][i],
            artist: arguments['queue']['artist'][i],
            imageUrlLarge: arguments['queue']['image'][i],
            service: PlatformsLister.nameToService(arguments['queue']['service'][i]),
            totalDuration: _parseDuration(arguments['queue']['duration'][i])
          ));
        }

        Track firstTrack = trackQueue.first;
        await _playTrack(firstTrack);
        currentIndex++;

      } break;


      case 'INSERT_ITEM' : {
        Track tr = Track(
          id: arguments['track']['id'],
          name: arguments['queue']['id'],
          artist: arguments['queue']['artist'],
          imageUrlLarge: arguments['queue']['image'],
          service: PlatformsLister.nameToService(arguments['queue']['service'])
        );
        trackQueue.insert(arguments['index'], tr);
        _queueLoader();

      } break;


      case 'REMOVE_ITEM' : {
        trackQueue.removeAt(arguments['index']);

      } break;


      case 'REORDER_ITEM' : {
        Track track = trackQueue.removeAt(arguments['old_index']);
        trackQueue.insert(arguments['new_index'], track);
        _queueLoader();

      } break;

    }
    

    return super.onCustomAction(type, arguments);
  }


  Future<List<MediaItem>> _queueLoader() async {
    for(int i=currentIndex; i<currentIndex+DEFAULT_LENGTH_QUEUE; i++) {
      Track track = trackQueue[currentIndex+i];

      if(
        _queue.firstWhere((element) => 
        (element.extras['track_id'] == track.id && element.extras['track_service_name'] == track.serviceName),
        orElse: () => null)
        == null
      ) {
        File file = await track.loadFile();

        MediaItem mi = MediaItem(
          id: file.path,
          album: track.artist,
          title: track.name,
          artUri: Uri.parse(track.imageUrlLarge),
          duration: Duration(seconds: track.totalDuration.value.inSeconds),
          extras: {'track_id': track.id, 'service_name': track.serviceName}
        );

        _queue.add(mi);
      }

    }

    return _queue;

  }


}



class PlayerListener {

  static final PlayerListener _instance = PlayerListener._singleton();
  Track _track;
  Function _skipToNext;
  Function _skipToPrevious;

  PlayerListener._singleton();
  
  factory PlayerListener() {
    return _instance;
  }

  void listen(Track track, Function skipToNext, Function skipToPrevious) {
    _track = track;
    _skipToNext = skipToNext;
    _skipToPrevious = skipToPrevious;

    for(MapEntry<Track, bool> me in GlobalQueue.queue.value) {
      me.key.setIsPlaying(false);
    }
    track.setIsPlaying(true);

    AudioService.playbackStateStream.listen(
      (data) {        
        if(data.playing == true && !track.isPlaying.value) track.resumeOnly();
        else if(data.playing == false && track.isPlaying.value) track.pauseOnly();
      }
    );
    AudioService.positionStream.listen(
      (data) {
        track.seekTo(data, false);
      }
    );
    AudioService.customEventStream.listen(
      (data) {
        switch (data) {

          case 'STOP' : {
            _track.setIsPlaying(false);
          } break;


          case 'SKIP_NEXT' : {
            _skipToNext.call();
          } break;


          case 'SKIP_PREVIOUS' : {
            _skipToPrevious.call();
          } break;

        }
      }
    );
  }

}



class YoutubeRetriever {

  YoutubeRetriever._singleton();

  static final YoutubeRetriever _instance = YoutubeRetriever._singleton();

  YoutubeExplode _yt = YoutubeExplode();
  AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  factory YoutubeRetriever() {
    return _instance;
  }

  Future<MapEntry<Track, File>> streamByName(Track track) async {
    Track tr = await SearchAlgorithm().search(tArtist: track.artist, tTitle: track.name, tDuration: track.totalDuration.value);
    return MapEntry(tr, await streamById(tr.id));
  }

  Future<File> streamById(String id) async {
    StreamManifest manifest = await _yt.videos.streamsClient.getManifest(id);
    AudioOnlyStreamInfo streamInfo = manifest.audioOnly.withHighestBitrate();

    File file;
    if (streamInfo != null) {
      // Get the actual stream
      var stream = _yt.videos.streamsClient.get(streamInfo);
      
      // Open a file for writing.
      final Directory directory = await getTemporaryDirectory();
      String path = '${directory.path}/$id.mp3';
      print('Path : $path');
      file = File(path);
      var fileStream = file.openWrite();

      // Pipe all the content of the stream into the file.
      try {
        await stream.pipe(fileStream);
      } catch(e) {
        print(e);
      }

      // Close the file.
      await fileStream.flush();
      await fileStream.close();
    }
    
    return file;
  }

}