import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Players/Youtube/MainPlayer.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/ProfileView.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:protobuf/protobuf.dart';


abstract class PlatformsController {
  Map<String, State> states = new Map<String, State>();
  Map<String, Track> allTracks = Map<String, Track>();
  Platform platform;

  PlatformsController(Platform platform) {
    this.platform = platform;
    this.updateInformations();
  }

  /*  STATE MANAGER */

  setPlaylistsPageState(State state) {
    states['PlaylistsPage'] = state;
  }

  setSearchPageState(State state) {
    states['SearchPage'] = state;
  }

  setProfilePageState(State state) {
    states['ProfilePage'] = state;
  }

  void updateState(String stringState) {
    State<dynamic> state = states[stringState];
    state.setState(() {
      state.widget.createState().key = UniqueKey();
    });
  }

  void updateStates() {
    for (MapEntry state in states.entries) {
      state.value.setState(() {
        state.value.widget.createState().key = UniqueKey();
      });
    }
  }

  updateInformations();

  /*  VIEWS   */

  Widget getView({@required ServicesLister service, @required ProfileViewType view, Map parameters}) {
    return ProfileView.getView(service: service, view: view, parameters: parameters);
  }

  /*  INFORMATIONS  */

  getPlatformInformations();

  getUserInformations();

  Future<List<Playlist>> getPlaylists({bool refreshing});

  Future<List<Track>> getTracks(Playlist playlist);

  Map<String, Track> getAllPlatformTracks() {
    Map<String, Track> allTracks = Map<String, Track>();
    for(Playlist playlist in platform.playlists.value) {
      for(Track track in playlist.getTracks) {
        allTracks[track.id] = track;
      }
    }
    return this.allTracks = allTracks;
  }

  ValueNotifier<List<Playlist>> getPlaylistsUpdate();

  void mediaPlayerListener(Track track) {
    AudioService.playbackStateStream.listen(
      (data) {        
        if(data.playing == true && !track.isPlaying.value) track.resumeOnly();
        else if(data.playing == false && track.isPlaying.value) track.pauseOnly();
      }
    );
    AudioService.queueStream.listen(
      (data) {
        
      }
    );
    AudioService.positionStream.listen(
      (data) {
        if(data.inMilliseconds < GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key.totalDuration.value.inMilliseconds-200) {
          track.seekTo(data, false);
        }
      }
    );
    AudioService.customEventStream.listen(
      (data) {
        if(data == '[Isolate] onStop') {
          track.setIsPlaying(false);
        }
      }
    );
  }

  /*  CONNECTION    */

  connect();

  disconnect();

  /*  USER'S SERVICES */

  //Add the track to the app's playlist
  String addTrackToPlaylist(int playlistIndex, Track track, bool force) {
    return this.platform.addTrackToPlaylistByIndex(playlistIndex, track, force);
  }

  //Remove the track from the app's playlist
  Track removeTrackFromPlaylist(int playlistIndex, int trackIndex) {
    return this
        .platform
        .removeTrackFromPlaylistByIndex(playlistIndex, trackIndex);
  }

  //Add the track to the app's playlist
  Playlist addPlaylist(
      {Playlist playlist,
      @required String name,
      @required String ownerId,
      String ownerName,
      String imageUrl,
      String playlistUri,
      List<MapEntry<Track, DateTime>> tracks});
  //Remove the track from the app's playlist
  Playlist removePlaylist(int playlistIndex);

  Playlist mergePlaylist(Playlist toMergeTo, Playlist toMerge);

  void renamePlaylist(Playlist playlist, String name);


  /*  MEDIA PLAYER CONTROLS  */

  play(File file, Track track) async {
    // if(GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key != null) {
    //   GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key.setIsPlaying(false);
    // }
    // GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key = track;
    for(MapEntry<Track, bool> me in GlobalQueue.queue.value) {
      me.key.setIsPlaying(false);
    }

    if(!AudioService.connected) {
      await AudioService.connect();
    }

    Map<String, List<String>> queue = Map<String, List<String>>();
    queue['name'] = List<String>();
    queue['artist'] = List<String>();
    queue['image'] = List<String>();
    queue['id'] = List<String>();
    queue['service'] = List<String>();
    for(MapEntry<Track, bool> me in GlobalQueue.queue.value) {
      queue['name'].add(me.key.name);
      queue['artist'].add(me.key.artist);
      queue['image'].add(me.key.imageUrlLarge);
      queue['id'].add(me.key.id);
      queue['service'].add(me.key.serviceName);
    }

    print('       START');
    // await AudioService.start(
    //  backgroundTaskEntrypoint: _entrypoint,
    //  androidNotificationColor: notificationColor,
    //  androidEnableQueue: true,
    //  params: {
    //   'file': file.path,
    //   'track_title': track.name,
    //   'track_artist': track.artist,
    //   'track_image': track.imageUrlLarge,
    //   'track_duration_seconds': track.totalDuration.value.inSeconds,
    //   'track_id': track.id,
    //   'track_service_name': track.serviceName
    // });
    await AudioService.customAction('LAUNCH_QUEUE', {'queue': queue});
  }

  resume(File file) {
    AudioService.play();
  }

  pause() {
    AudioService.pause();
  }


  seekTo(Duration position) {
    AudioService.seekTo(position);
  }

  /*  STREAM  */

  Future<MapEntry<Track, File>> getFile(Track tr);

}
