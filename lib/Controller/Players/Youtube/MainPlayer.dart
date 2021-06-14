

import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart' as SM;
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/Youtube/SearchAlgorithm.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerTask extends BackgroundAudioTask {

  Map<MapEntry<String, Track>, bool> _allTracks = Map<MapEntry<String, Track>, bool>();

  void setAllTracksPlatform(PlatformsController ctrl) {
    for (SM.Playlist play in ctrl.platform.playlists.value) {
      for (MapEntry<Track, DateTime> tr in play.tracks) {
        _allTracks[MapEntry('${tr.key.serviceName}/${tr.key.id}', tr.key)] = false;
      }
    }
  }

  void setTrackPlaying(Track track) {
    print('here');
    if(_allTracks.containsValue(true)) {
      Track track = _allTracks.keys.firstWhere((k) => _allTracks[k] == true, orElse: () => null).value;
      track.setIsPlaying(false);
    }
    track.setIsPlaying(true);
    _allTracks[MapEntry('${track.serviceName}/${track.id}', track)] = true;
    print('currenttrack');
    print(_allTracks[_allTracks.keys.firstWhere((k) => _allTracks[k] == true, orElse: () => null).value]);
  }


  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    final mediaItem = MediaItem(
        id: params['file'],
        album: params['track_artist'],
        title: params['track_title'],
        artUri: Uri.parse(params['track_image']),
        duration: Duration(seconds: params['track_duration_seconds'])
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
    await _player.setUrl(mediaItem.id);
    return super.onStart(params);
  }

  @override
  Future<void> onStop() async {
    AudioServiceBackground.setState(
      controls: [],
      playing: false,
      processingState: AudioProcessingState.stopped
    );
    Track track = _allTracks.keys.firstWhere((k) => _allTracks[k] == true, orElse: () => null).value;
    track.setIsPlaying(false);
    await _player.stop();
    return super.onStop();
  }

  @override
  Future<void> onPause() async {
    print('onPause');
    print(AudioServiceBackground.mediaItem.title);
    AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.ready
    );
    await _player.pause();
    Track track = _allTracks.keys.firstWhere((k) => _allTracks[k] == true, orElse: () => null).value;
    print('heeere');
    track.pauseOnly();
    print('heeere2');
    print(track);
    print('heeere3');
    return super.onPause();
  }

  @override
  Future<void> onPlay() async {
    print('onPlay');
    AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.ready
    );
    await _player.play();
    Track track = _allTracks.keys.firstWhere((k) => _allTracks[k] == true, orElse: () => null).value;
    track.resumeOnly();
    print(track);
    return super.onPlay();
  }

  @override
  Future<void> onSeekTo(Duration position) async {
    // _currentTrack.seekTo(position, false);
    await _player.seek(position);
    return super.onSeekTo(position);
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
    Track tr = await SearchAlgorithm().search(artiste: track.artist, title: track.name);
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