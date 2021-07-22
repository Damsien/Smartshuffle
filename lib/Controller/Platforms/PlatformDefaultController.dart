import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

class PlatformDefaultController extends PlatformsController {
  PlatformDefaultController(Platform platform) : super(platform) {
    platform.userInformations['isConnected'] = true;
    platform.platformInformations['logo'] = 'assets/logo/smartshuffle.png';
    platform.platformInformations['icon'] =
        'assets/logo/icons/smartshuffle.png';
    platform.platformInformations['main_color'] = Colors.blueAccent;
  }

  @override
  getPlatformInformations() {
    return platform.platformInformations;
  }

  @override
  getUserInformations() {
    platform.userInformations['isConnected'] = true;
    platform.userInformations['ownerId'] = "";
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
  updateInformations() {
    return null;
  }

  @override
  Playlist addPlaylist(
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
      playlist.setService(ServicesLister.DEFAULT);
      return this.platform.addPlaylist(playlist, isNew: true);
    }
    return this.platform.addPlaylist(Playlist(
      name: name,
      ownerId: ownerId,
      ownerName: ownerName,
      id: this.platform.playlists.value.length.toString(),
      service: ServicesLister.DEFAULT,
      imageUrl: imageUrl,
      uri: (playlistUri != null ? Uri.parse(playlistUri) : Uri.http("", "")),
      tracks: tracks),
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
