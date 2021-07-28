import 'dart:collection';
import 'dart:math';
import 'dart:isolate' as isolate;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smartshuffle/Controller/DatabaseController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformSpotifyController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformYoutubeController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

import 'package:smartshuffle/Services/spotify/api_controller.dart' as SP;
import 'package:smartshuffle/Services/youtube/api_controller.dart' as YT;


enum ServicesLister {
  DEFAULT,
  SPOTIFY,
  YOUTUBE
}

String serviceToString(ServicesLister service) => service.toString().split(".")[1];


class GlobalAppController {

  static List<PlatformsController> getAllControllers() {
    List<PlatformsController> plat = List<PlatformsController>();
    PlatformsLister.platforms.forEach((key, value) {
      plat.add(value);
    });
    return plat;
  }

  static Future<void> storageInit() async {
    final storage = FlutterSecureStorage();
    
    Map<String, Platform> platforms = await DataBaseController().getPlatforms();

    if(platforms['SmartShuffle'] != null) {
      PlatformsLister.platforms[ServicesLister.DEFAULT] = new PlatformDefaultController(platforms['Smartshuffle']);
    } else {
      PlatformsLister.platforms[ServicesLister.DEFAULT] = new PlatformDefaultController(Platform("Smartshuffle"));
    }

    // if(await storage.containsKey(key: serviceToString(ServicesLister.SPOTIFY).toLowerCase())) {
    if(platforms['Spotify'] != null && platforms['Spotify'].userInformations['isConnected']) {
      String spToken = await storage.read(key: serviceToString(ServicesLister.SPOTIFY).toLowerCase());
      PlatformsLister.tokens[ServicesLister.SPOTIFY] = spToken;
      await SP.API().login(storeToken: spToken);

      PlatformsLister.platforms[ServicesLister.SPOTIFY] = new PlatformSpotifyController(platforms['Spotify']);
    } else {
      PlatformsLister.platforms[ServicesLister.SPOTIFY] = new PlatformSpotifyController(Platform("Spotify", platformInformations: {'package': 'com.spotify.music'})
      , isBack: AudioService.running);
    }

    // if(await storage.containsKey(key: serviceToString(ServicesLister.YOUTUBE).toLowerCase())) {
    if(platforms['Youtube'] != null && platforms['Youtube'].userInformations['isConnected']) {
      String ytToken = await storage.read(key: serviceToString(ServicesLister.YOUTUBE).toLowerCase());
      PlatformsLister.tokens[ServicesLister.YOUTUBE] = ytToken;
      print(' ytOktenenenen');
      await YT.API().login(storeToken: ytToken);

      PlatformsLister.platforms[ServicesLister.YOUTUBE] = new PlatformYoutubeController(platforms['Youtube']);
    } else {
      PlatformsLister.platforms[ServicesLister.YOUTUBE] = new PlatformYoutubeController(Platform("Youtube", platformInformations: {'package': 'com.google.android.youtube'})
      , isBack: AudioService.running);
    }
  }

  static Future<void> initApp(State state) async {
    await DataBaseController().database;
    state.setState(() {});
    PlatformsController.updateStates();
  }

}

class PlatformsLister {

  static Map<ServicesLister, String> tokens = {};

  static Map<ServicesLister, PlatformsController> platforms = Map<ServicesLister, PlatformsController>();
  // {
  //   ServicesLister.DEFAULT: new PlatformDefaultController(Platform("SmartShuffle")),
  //   ServicesLister.SPOTIFY: new PlatformSpotifyController(Platform("Spotify", platformInformations: {'package': 'com.spotify.music'})),
  //   ServicesLister.YOUTUBE: new PlatformYoutubeController(Platform("Youtube", platformInformations: {'package': 'com.google.android.youtube'}))
  // };

  static void initBackPlayer() {
    platforms =
    {
      ServicesLister.DEFAULT: new PlatformDefaultController(Platform("SmartShuffle"), isBack: true),
      ServicesLister.SPOTIFY: new PlatformSpotifyController(Platform("Spotify", platformInformations: {'package': 'com.spotify.music'}), isBack: true),
      ServicesLister.YOUTUBE: new PlatformYoutubeController(Platform("Youtube", platformInformations: {'package': 'com.google.android.youtube'}), isBack: true)
    };
  }

  static ServicesLister nameToService(String name) {
    if(name == "DEFAULT") return ServicesLister.DEFAULT;
    if(name == "SPOTIFY") return ServicesLister.SPOTIFY;
    if(name == "YOUTUBE") return ServicesLister.YOUTUBE;
  }

}
