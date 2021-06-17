

import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
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

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    final mediaItem = MediaItem(
        id: params['file'],
        album: params['track_artist'],
        title: params['track_title'],
        artUri: Uri.parse(params['track_image']),
        duration: Duration(seconds: params['track_duration_seconds']),
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

    // Play when ready.
    _player.play();
    // Start loading something (will play when ready).
    await _player.setFilePath(mediaItem.id);
    return super.onStart(params);
  }

  @override
  Future<void> onStop() async {
    AudioServiceBackground.setState(
      controls: [],
      playing: false,
      processingState: AudioProcessingState.stopped
    );
    print('stoippp');
    AudioServiceBackground.sendCustomEvent('[Send] onStop');
    await _player.stop();
    return super.onStop();
  }

  @override
  Future<void> onPause() async {
    print('[Isolate] onPause');
    print(AudioServiceBackground.mediaItem.title);
    AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.ready
    );
    await _player.pause();
    AudioServiceBackground.sendCustomEvent('[Send] onPause');
    // AudioServiceBackground.mediaItem.extras['track'].pauseOnly();
    return super.onPause();
  }

  @override
  Future<void> onPlay() async {
    print('[Isolate] onPlay');
    AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.ready
    );
    await _player.play();
    print('[Isolate] ${AudioServiceBackground.mediaItem.extras["track_service_name"]}/${AudioServiceBackground.mediaItem.extras["track_id"]}');
    AudioServiceBackground.sendCustomEvent('[Send] onResume');
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


  void setTrackPlaying(Track track) async {
    await AudioService.stop();
    track.setIsPlaying(true);
  }

  Future<List<MediaItem>> queueLoader() async {

    for(int i=queue.length; i<DEFAULT_LENGTH_QUEUE; i++) {
      Track track = GlobalQueue.queue.value[i].key;
      File file = await track.loadFile();

      queue[i] = MediaItem(
        id: file.path,
        album: track.artist,
        title: track.name,
        artUri: Uri.parse(track.imageUrlLarge),
        duration: Duration(seconds: track.totalDuration.inSeconds),
      );
    }

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

  Future<File> streamByName(Track track) async {
    Track tr = await SearchAlgorithm().search(tArtist: track.artist, tTitle: track.name, tDuration: track.totalDuration);
    return await streamById(tr.id);
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
      print(path);
      file = File(path);
      var fileStream = file.openWrite();

      // Pipe all the content of the stream into the file.
      await stream.pipe(fileStream);

      // Close the file.
      await fileStream.flush();
      await fileStream.close();
    }
    
    return file;
  }

}