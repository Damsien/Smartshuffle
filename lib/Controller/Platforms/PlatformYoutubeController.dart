

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/View/Pages/Profile/Platforms/PlatformsConnection.dart';
import 'package:smartshuffle/View/Pages/Profile/Platforms/PlatformsInformation.dart';

class PlatformYoutubeController extends PlatformsController {
  
  
  PlatformYoutubeController(Platform platform) : super(platform);


  @override
  getButtonView() {
    return PlatformsConnection.youtubeButton();
  }

  @override
  getInformationView() {
    return PlatformsInformation.youtubeInformation();
  }

  getPlatformInformations() {
    Map infos = platform.platformInformations;
    infos['logo'] = 'assets/logo/youtube_logo.png';
    infos['icon'] = 'assets/logo/icons/youtube_icon.png';
    infos['color'] = Colors.red[500];
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