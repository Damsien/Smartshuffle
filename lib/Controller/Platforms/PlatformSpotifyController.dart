import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/Pages/Profile/Platforms/PlatformsConnection.dart';
import 'package:smartshuffle/View/Pages/Profile/Platforms/PlatformsInformation.dart';
import 'package:smartshuffle/Services/spotify/api_controller.dart' as spotify;

class PlatformSpotifyController extends PlatformsController {
  PlatformSpotifyController(Platform platform) : super(platform);

  spotify.API spController = new spotify.API();

  @override
  getButtonView() {
    return PlatformsConnection.spotifyButton();
  }

  @override
  getInformationView() {
    return PlatformsInformation.spotifyInformation();
  }

  @override
  getPlatformInformations() {
    platform.platformInformations['logo'] = 'assets/logo/spotify_logo.png';
    platform.platformInformations['icon'] =
        'assets/logo/icons/spotify_icon.png';
    platform.platformInformations['color'] = Colors.green[800];
    return platform.platformInformations;
  }

  @override
  getUserInformations() {
    return platform.userInformations;
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    return platform.setPlaylist(await spController.getPlaylistsList());
  }

  @override
  connect() async {
    await spController.login();
    platform.userInformations['isConnected'] = spController.isLoggedIn;
    //platform.userInformations['isConnected'] = true;
    this.updateStates();
  }

  @override
  disconnect() {
    spController.disconnect();
    platform.userInformations['isConnected'] = spController.isLoggedIn;
    //platform.userInformations['isConnected'] = false;
    this.updateStates();
  }

  @override
  updateInformations() {
    return null;
  }

  @override
  Playlist addPlaylist(String name, {Image image, String playlistUri, List<MapEntry<Track, DateTime>> tracks}) {
    // TODO: implement removePlaylist
    throw UnimplementedError();
  }

  @override
  Playlist removePlaylist(int playlistIndex) {
    // TODO: implement removePlaylist
    throw UnimplementedError();
  }
}
