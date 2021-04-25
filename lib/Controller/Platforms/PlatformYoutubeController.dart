import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Services/youtube/api_controller.dart'
    as ytController;

class PlatformYoutubeController extends PlatformsController {
  PlatformYoutubeController(Platform platform) : super(platform);

  ytController.API yt = new ytController.API();

  getPlatformInformations() {
    platform.platformInformations['logo'] = 'assets/logo/youtube_logo.png';
    platform.platformInformations['icon'] =
        'assets/logo/icons/youtube_icon.png';
    platform.platformInformations['color'] = Colors.red[500];
    return platform.platformInformations;
  }

  @override
  getUserInformations() {
    return platform.userInformations;
  }

  @override
  Future<List<Playlist>> getPlaylists({bool refreshing}) async {
    return platform.setPlaylist(await yt.getPlaylistsList());
  }

  @override
  ValueNotifier<List<Playlist>> getPlaylistsUpdate() {
    return platform.playlists;
  }

  @override
  Future<List<Track>> getTracks(Playlist playlist) async {
    return playlist.setTracks(await yt.getPlaylistSongs(playlist));
  }

  @override
  connect() async {
    await yt.login();
    platform.userInformations['isConnected'] = yt.isLoggedIn;
    //platform.userInformations['isConnected'] = true;
    this.updateStates();
  }

  @override
  disconnect() async {
    yt.disconnect();
    platform.userInformations['isConnected'] = yt.isLoggedIn;
    //platform.userInformations['isConnected'] = false;
    this.updateStates();
  }

  @override
  updateInformations() {
    return null;
  }

  @override
  Playlist addPlaylist(
      {Playlist playlist,
      @required String name,
      @required String ownerId,
      String ownerName,
      String imageUrl,
      String playlistUri,
      List<MapEntry<Track, DateTime>> tracks}) {
    // TODO: implement addPlaylist
    throw UnimplementedError();
  }

  @override
  Playlist removePlaylist(int playlistIndex) {
    // TODO: implement removePlaylist
    throw UnimplementedError();
  }

  @override
  Playlist mergePlaylist(Playlist toMergeTo, Playlist toMerge) {
    // TODO: implement mergePlaylist
    throw UnimplementedError();
  }

  @override
  void renamePlaylist(Playlist playlist, String name) {
    // TODO: implement renamePlaylist
  }

  @override
  pause() {
    // TODO: implement pause
    throw UnimplementedError();
  }

  @override
  play(String youtubeUri) {
    // TODO: implement play
    throw UnimplementedError();
  }

  @override
  resume() {
    // TODO: implement resume
    throw UnimplementedError();
  }

}
