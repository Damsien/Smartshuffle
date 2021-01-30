

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
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
    Map infos = platform.platformInformations;
    infos['logo'] = 'assets/logo/spotify_logo.png';
    infos['icon'] = 'assets/logo/icons/spotify_icon.png';
    infos['color'] = Colors.green[800];
    return infos;
  }

  @override
  getUserInformations() {
    return platform.userInformations;
  }

  @override
  List getPlaylists() {
    return platform.playlists;
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




}