import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Players/BackPlayer.dart';
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
