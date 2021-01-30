

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';

class PlatformDefaultController extends PlatformsController {
  
  PlatformDefaultController(Platform platform) : super(platform);

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
    Map infos = platform.platformInformations;
    infos['logo'] = 'assets/logo/smartshuffle.png';
    infos['icon'] = 'assets/logo/icons/smartshuffle.png';
    infos['color'] = Colors.yellow;
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