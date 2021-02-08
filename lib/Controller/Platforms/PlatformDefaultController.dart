

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

class PlatformDefaultController extends PlatformsController {
  
  PlatformDefaultController(Platform platform) : super(platform) {
    platform.userInformations['isConnected'] = true;
  }

  @override
  getButtonView() {
    return Container();
  }

  @override
  getInformationView() {
    return Container();
  }

  @override
  getPlatformInformations() {
    platform.platformInformations['logo'] = 'assets/logo/smartshuffle.png';
    platform.platformInformations['icon'] = 'assets/logo/icons/smartshuffle.png';
    platform.platformInformations['color'] = Colors.yellow;
    return platform.platformInformations;
  }

  @override
  getUserInformations() {
    platform.userInformations['isConnected'] = true;
    return platform.userInformations;
  }

  @override
  Future<List<Playlist>> getPlaylists() {
    Completer<List<Playlist>> completer = Completer<List<Playlist>>();
    completer.complete(platform.playlists);
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
  Playlist addPlaylist(String name, {Image image, String playlistUri, List<MapEntry<Track, DateTime>> tracks}) {
    return this.platform.addPlaylist(Playlist(
     name: name, 
     id: this.platform.playlists.length.toString(),
     service: ServicesLister.DEFAULT,
     image: image, 
     uri: playlistUri,
     tracks: tracks
    ));
  }

  @override
  Playlist removePlaylist(int playlistIndex) {
    return this.platform.removePlaylist(playlistIndex);
  }

}