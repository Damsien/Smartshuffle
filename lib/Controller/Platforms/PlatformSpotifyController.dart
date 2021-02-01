import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
import 'package:smartshuffle/View/Pages/Profile/Platforms/PlatformsConnection.dart';
import 'package:smartshuffle/View/Pages/Profile/Platforms/PlatformsInformation.dart';


class PlatformSpotifyController extends PlatformsController {
  
  PlatformSpotifyController(Platform platform) : super(platform);

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
    platform.platformInformations['icon'] = 'assets/logo/icons/spotify_icon.png';
    platform.platformInformations['color'] = Colors.green[800];
    return platform.platformInformations;
  }

  @override
  getUserInformations() {
    return platform.userInformations;
  }

  @override
  List<PlaylistInformations> getPlaylists() {
    return platform.playlists;
  }




  @override
  connect() {
    platform.userInformations['isConnected'] = true;
    this.updateStates();
  }

  @override
  disconnect() {
    platform.userInformations['isConnected'] = false;
    this.updateStates();
  }

  @override
  updateInformations() {
    return null;
  }




}