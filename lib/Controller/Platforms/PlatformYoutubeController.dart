import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
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
    platform.platformInformations['logo'] = 'assets/logo/youtube_logo.png';
    platform.platformInformations['icon'] = 'assets/logo/icons/youtube_icon.png';
    platform.platformInformations['color'] = Colors.red[500];
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