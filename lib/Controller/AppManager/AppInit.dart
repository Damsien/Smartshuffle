import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smartshuffle/Controller/AppManager/DatabaseController.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformSpotifyController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformYoutubeController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Util.dart';

import 'package:smartshuffle/Services/spotify/api_controller.dart' as SP;
import 'package:smartshuffle/Services/youtube/api_controller.dart' as YT;

class GlobalAppController {

  static Future<void> storageInit() async {
    final storage = FlutterSecureStorage();
    
    Map<String, Platform> platforms = await DataBaseController().getPlatforms();

    if(platforms['SmartShuffle'] != null) {
      PlatformsLister.platforms[ServicesLister.DEFAULT] = new PlatformDefaultController(platforms['Smartshuffle']);
    } else {
      PlatformsLister.platforms[ServicesLister.DEFAULT] = new PlatformDefaultController(Platform("Smartshuffle"));
    }

    if(platforms['Spotify'] != null && platforms['Spotify'].userInformations['isConnected']) {
      String spToken = await storage.read(key: Util.serviceToString(ServicesLister.SPOTIFY).toLowerCase());
      PlatformsLister.tokens[ServicesLister.SPOTIFY] = spToken;
      await SP.API().login(storeToken: spToken);

      PlatformsLister.platforms[ServicesLister.SPOTIFY] = new PlatformSpotifyController(platforms['Spotify']);
    } else {
      PlatformsLister.platforms[ServicesLister.SPOTIFY] = new PlatformSpotifyController(Platform("Spotify", platformInformations: {'package': 'com.spotify.music'})
      , isBack: AudioService.running);
    }

    if(platforms['Youtube'] != null && platforms['Youtube'].userInformations['isConnected']) {
      String ytToken = await storage.read(key: Util.serviceToString(ServicesLister.YOUTUBE).toLowerCase());
      PlatformsLister.tokens[ServicesLister.YOUTUBE] = ytToken;
      await YT.API().login(storeToken: ytToken);

      PlatformsLister.platforms[ServicesLister.YOUTUBE] = new PlatformYoutubeController(platforms['Youtube']);
    } else {
      PlatformsLister.platforms[ServicesLister.YOUTUBE] = new PlatformYoutubeController(Platform("Youtube", platformInformations: {'package': 'com.google.android.youtube'})
      , isBack: AudioService.running);
    }
  }

  static Future<void> initApp(State state) async {
    await DataBaseController().database;
    // ignore: invalid_use_of_protected_member
    state.setState(() {});
    StatesManager.updateStates();
  }

}