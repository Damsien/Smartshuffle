

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';

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
  List<PlaylistInformations> getPlaylists() {
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