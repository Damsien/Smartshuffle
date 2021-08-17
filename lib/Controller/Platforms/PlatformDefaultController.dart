import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

class PlatformDefaultController extends PlatformsController {
  PlatformDefaultController(Platform platform, {bool isBack}) : super(platform, isBack: isBack) {
    platform.userInformations['isConnected'] = true;
    platform.platformInformations['logo'] = 'assets/logo/smartshuffle.png';
    platform.platformInformations['icon'] =
        'assets/logo/icons/smartshuffle.png';
    platform.platformInformations['main_color'] = Colors.purple[400];

    features = {
      PlatformsCtrlFeatures.PLAYLIST_ADD: true,
      PlatformsCtrlFeatures.PLAYLIST_GET: true,
      PlatformsCtrlFeatures.PLAYLIST_CLONE: false,
      PlatformsCtrlFeatures.PLAYLIST_MERGE: false,
      PlatformsCtrlFeatures.PLAYLIST_REMOVE: true,
      PlatformsCtrlFeatures.PLAYLIST_RENAME: true,
      PlatformsCtrlFeatures.TRACK_ADD_ANOTHER_PLAYLIST: true,
      PlatformsCtrlFeatures.TRACK_ADD: true,
      PlatformsCtrlFeatures.TRACK_GET: true,
      PlatformsCtrlFeatures.TRACK_REMOVE: true
    };
  }

  @override
  get platformInformations {
    return platform.platformInformations;
  }

  @override
  get userInformations {
    return platform.userInformations;
  }

  @override
  Future<List<Playlist>> getPlaylists({bool refreshing}) async {
    super.getPlaylists(refreshing: refreshing);
    return Future.sync(() => platform.playlists.value);
  }

  @override
  ValueNotifier<List<Playlist>> getPlaylistsUpdate() {
    return platform.playlists;
  }

  @override
  Future<List<Track>> getTracks(Playlist playlist) {
    Completer<List<Track>> completer = Completer<List<Track>>();
    completer.complete(playlist.getTracks);
    return completer.future;
  }

  @override
  connect() {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  disconnect() {
    // TODO: implement disconnect
    throw UnimplementedError();
  }


  @override
  FutureOr<Playlist> addPlaylist(
      {Playlist playlist,
      String name,
      String ownerId,
      String ownerName,
      String imageUrl,
      String playlistUri,
      List<MapEntry<Track, DateTime>> tracks}) {
    if (playlist != null) {
      for (Playlist play in this.platform.playlists.value) {
        if (play.id == playlist.id) return null;
      }
      playlist.service = ServicesLister.DEFAULT;
      return this.platform.addPlaylist(playlist..setTracks(playlist.getTracks, isNew: true), isNew: true);
    }
    return this.platform.addPlaylist(
      Playlist(
        name: name,
        ownerId: ownerId,
        ownerName: ownerName,
        id: this.platform.playlists.value.length.toString(),
        service: ServicesLister.DEFAULT,
        imageUrl: imageUrl,
        uri: (playlistUri != null ? Uri.parse(playlistUri) : Uri.http("", ""))
      ),
      isNew: true
    );
  }

  @override
  Playlist removePlaylist(int playlistIndex) {
    return this.platform.removePlaylist(playlistIndex);
  }

  @override
  Playlist mergePlaylist(Playlist toMergeTo, Playlist toMerge) {
    return toMergeTo..addTracks(toMerge.getTracks, isNew: true);
  }

  void renamePlaylist(Playlist playlist, String name) {}

  @override
  Future<MapEntry<Track,File>> getFile(Track tr) {
    // TODO: implement stream
    throw UnimplementedError();
  }

  // @override
  // pause() {
  //   // TODO: implement pause
  //   throw UnimplementedError();
  // }

  // @override
  // play(String uri) {
  //   // TODO: implement play
  //   throw UnimplementedError();
  // }

  // @override
  // resume() {
  //   // TODO: implement resume
  //   throw UnimplementedError();
  // }
  
  // @override
  // seekTo(Duration duration) {
  //   // TODO: implement seekTo
  //   throw UnimplementedError();
  // }

}
