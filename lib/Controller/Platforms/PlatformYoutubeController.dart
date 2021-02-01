import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
import 'package:smartshuffle/View/Pages/Profile/Platforms/PlatformsConnection.dart';
import 'package:smartshuffle/View/Pages/Profile/Platforms/PlatformsInformation.dart';
import 'package:smartshuffle/Services/youtube/api_controller.dart'
    as ytController;

class PlatformYoutubeController extends PlatformsController {
  PlatformYoutubeController(Platform platform) : super(platform);

  ytController.API yt = new ytController.API();

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
  List<PlaylistInformations> getPlaylists() {
    return platform.playlists;
  }

  @override
  connect() async {
    await yt.login();
    platform.userInformations['isConnected'] = yt.isLoggedIn;
    this.updateStates();
  }

  @override
  disconnect() async {
    await yt.disconnect();
    platform.userInformations['isConnected'] = yt.isLoggedIn;
    this.updateStates();
  }

  @override
  updateInformations() {
    return null;
  }
}
