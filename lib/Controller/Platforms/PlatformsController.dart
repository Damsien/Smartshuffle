import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/AppManager/DatabaseController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Model/Util.dart';
import 'package:smartshuffle/View/Pages/Librairie/PlaylistsPage.dart';


enum PlatformsCtrlFeatures {
  PLAYLIST_ADD,
  PLAYLIST_RENAME,
  PLAYLIST_GET,
  PLAYLIST_CLONE,
  PLAYLIST_MERGE,
  PLAYLIST_REMOVE,
  TRACK_ADD_ANOTHER_PLAYLIST,
  TRACK_ADD,
  TRACK_GET,
  TRACK_REMOVE
}

abstract class PlatformsController {
  Map<String, Track> allTracks = Map<String, Track>();
  Platform platform;

  Map<PlatformsCtrlFeatures, bool> features = Map<PlatformsCtrlFeatures, bool>();

  PlatformsController(Platform platform, {bool isBack}) {
    this.platform = platform;
    if(isBack == null || isBack == false) {
      DataBaseController().insertPlatform(platform);
    }
  }

  /*  INFORMATIONS  */

  get platformInformations;

  get userInformations;


  /* DATA */

  FutureOr<List<Playlist>> getPlaylists({bool refreshing}) async {
    if((refreshing == null || !refreshing)) {
      if(platform.playlists.value.isNotEmpty) {
        return platform.playlists.value;
      }
      List<Playlist> playlists = await DataBaseController().getPlaylists(platform);
      if(playlists.isNotEmpty) {
        platform.setPlaylist(playlists, isNew: false);
        for(Playlist play in platform.playlists.value) {
          play.setTracks(await DataBaseController().getTracks(play), isNew: false);
        }
        return platform.playlists.value;
      } else {
        return null;
      }
    }
    return null;
  }

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

  /*  CONNEXION    */

  connect() {
    DataBaseController().updatePlatform(platform);
    // ignore: invalid_use_of_protected_member
    StatesManager.states['ProfilePage'].setState(() {});
  }

  disconnect() {
    DataBaseController().updatePlatform(platform);
    // ignore: invalid_use_of_protected_member
    StatesManager.states['ProfilePage'].setState(() {});
  }

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
  FutureOr<Playlist> addPlaylist(
      {Playlist playlist,
      String name,
      String ownerId,
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
