

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
  getPlatformInformations() {
    platform.platformInformations['logo'] = 'assets/logo/smartshuffle.png';
    platform.platformInformations['icon'] = 'assets/logo/icons/smartshuffle.png';
    platform.platformInformations['color'] = Colors.yellow;
    return platform.platformInformations;
  }

  @override
  getUserInformations() {
    platform.userInformations['isConnected'] = true;
    platform.userInformations['ownerId'] = "";
    return platform.userInformations;
  }

  @override
  Future<List<Playlist>> getPlaylists({bool refreshing}) {
    Completer<List<Playlist>> completer = Completer<List<Playlist>>();
    completer.complete(platform.playlists);
    return completer.future;
  }

  @override
  Future<List<Track>> getTracks(Playlist playlist) {
    Completer<List<Track>> completer = Completer<List<Track>>();
    completer.complete(playlist.getTracks());
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
  Playlist addPlaylist({Playlist playlist, @required String name, @required String ownerId, String ownerName, String imageUrl, String playlistUri, List<MapEntry<Track, DateTime>> tracks}) {
    if(playlist != null) {
      for(Playlist play in this.platform.playlists) {
        if(play.id == playlist.id) return null;
      }
      return this.platform.addPlaylist(playlist)..setService(ServicesLister.DEFAULT);
    }
    return this.platform.addPlaylist(Playlist(
     name: name, 
     ownerId: ownerId,
     ownerName: ownerName,
     id: this.platform.playlists.length.toString(),
     service: ServicesLister.DEFAULT,
     imageUrl: imageUrl, 
     uri: playlistUri,
     tracks: tracks
    ));
  }

  @override
  Playlist removePlaylist(int playlistIndex) {
    return this.platform.removePlaylist(playlistIndex);
  }

  @override
  Playlist mergePlaylist(Playlist toMergeTo, Playlist toMerge) {
    return toMergeTo..addTracks(toMerge.getTracks());
  }

}