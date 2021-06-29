

import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart' as SM;
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/Youtube/SearchAlgorithm.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerTask extends BackgroundAudioTask {

  final AudioPlayer _player = AudioPlayer();
  List<MediaItem> _queue = List<MediaItem>();

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    print('                      STARTO');
    final mediaItem = MediaItem(
        id: params['file'],
        album: params['track_artist'],
        title: params['track_title'],
        artUri: Uri.parse(params['track_image']),
        duration: Duration(seconds: params['track_duration_seconds']),
        extras: {
          'track_id': params['track_id']
        }
      );
    // Tell the UI and media notification what we're playing.
    AudioServiceBackground.setMediaItem(mediaItem);
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

    AudioServiceBackground.setQueue(_queue);
    _queue.add(mediaItem);
    // Play when ready.
    _player.play();
    // Start loading something (will play when ready).
    await _player.setFilePath(_queue[0].id);
    
    _player.positionStream.listen(
      (position) {
        if(position.inMilliseconds >= _player.duration.inMilliseconds-900) {
          print('ended');
          // AudioServiceBackground.sendCustomEvent('TRACK_ENDED');
        }
      }
    );

    return super.onStart(params);
  }

  @override
  Future<void> onUpdateQueue(List<MediaItem> queue) async {
    _queue.add(queue[0]);
    await _player.setFilePath(queue[0].id);
    // AudioServiceBackground.setQueue(_queue);
    // try {
    //   await _player.setAudioSource(ConcatenatingAudioSource(
    //     children:
    //         queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
    //   ));
    // } catch (e) {
    //   print(e);
    // }
    return super.onUpdateQueue(queue);
  }

  @override
  Future<void> onSkipToNext() {
    _player.seekToNext();
    // _player.seek(Duration.zero);
    // AudioServiceBackground.sendCustomEvent('SKIP_NEXT_ITEM');
    return super.onSkipToNext();
  }

  @override
  Future<void> onSkipToPrevious() {
    _player.seekToPrevious();
    // _player.seek(Duration.zero);
    // AudioServiceBackground.sendCustomEvent('SKIP_PREVIOUS_ITEM');
    return super.onSkipToPrevious();
  }

  @override
  Future<void> onStop() async {
    AudioServiceBackground.setState(
      controls: [],
      playing: false,
      processingState: AudioProcessingState.stopped
    );
    // AudioServiceBackground.sendCustomEvent('[Isolate] onStop');
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
    // AudioServiceBackground.sendCustomEvent('[Send] onPause');
    // AudioServiceBackground.mediaItem.extras['track'].pauseOnly();
    return super.onPause();
  }

  @override
  Future<void> onPlay() async {
    AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.ready
    );
    await _player.play();
    // AudioServiceBackground.sendCustomEvent('[Send] onResume');
    // AudioServiceBackground.mediaItem.extras['track'].resumeOnly();
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



}



class QueueManager {

  final int DEFAULT_LENGTH_QUEUE = 5;
  List<MediaItem> queue = List<MediaItem>();
  int indexManager = 0;
  Map<String, Function> _functions;

  QueueManager._privateConstructor() {
    // AudioService.queueStream.listen(
    //   (data) {
    //     print(data);
    //   }
    // );
    AudioService.customEventStream.listen(
      (data) {
            print(data);
        switch(data) {
          
          case 'SKIP_NEXT_ITEM' : {
            _functions['skip_next'].call();
          } break;

          case 'SKIP_PREVIOUS_ITEM' : {
            _functions['skip_previous'].call();
          } break;

          case 'TRACK_ENDED' : {
            _functions['track_ended'].call();
          } break;

        }
      }
    );
    // AudioService.positionStream.listen(
    //   (data) {
    //     if(data.inSeconds >= GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key.totalDuration.value.inSeconds-1) {
    //       GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key.seekTo(data, false);
    //     }
    //   }
    // );
  }

  static final QueueManager _instance = QueueManager._privateConstructor();

  factory QueueManager() {
    return _instance;
  }


  void setTrackPlaying(Track track, {Map<String, Function> functions}) async {
    _functions = functions;
    await AudioService.stop();
    await track.setIsPlaying(true);
    if(queue.isNotEmpty) queue.removeAt(0);
    queueLoader();
  }

  Future<List<MediaItem>> queueLoader() async {
    // print('          queueLoader');

    for(int i=0; i<DEFAULT_LENGTH_QUEUE; i++) {
      Track track = GlobalQueue.queue.value[GlobalQueue.currentQueueIndex+i].key;
      File file = await track.loadFile();

      MediaItem mi = MediaItem(
        id: file.path,
        album: track.artist,
        title: track.name,
        artUri: Uri.parse(track.imageUrlLarge),
        duration: Duration(seconds: track.totalDuration.value.inSeconds),
      );

      queue.add(mi);
      await AudioService.addQueueItem(mi);

    }

    return queue;

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