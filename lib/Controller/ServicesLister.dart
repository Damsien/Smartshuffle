import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformSpotifyController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformYoutubeController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';


enum ServicesLister {
  DEFAULT,
  SPOTIFY,
  YOUTUBE
}

class PlatformsLister {

  static LinkedHashMap<ServicesLister, PlatformsController> platforms = 
  {
    ServicesLister.DEFAULT: new PlatformDefaultController(Platform("SmartShuffle")),
    ServicesLister.SPOTIFY: new PlatformSpotifyController(Platform("Spotify", platformInformations: {'package': 'com.spotify.music'})),
    ServicesLister.YOUTUBE: new PlatformYoutubeController(Platform("Youtube", platformInformations: {'package': 'com.google.android.youtube'}))
  } as LinkedHashMap;

  static List<PlatformsController> getAllControllers() {
    List<PlatformsController> plat = List<PlatformsController>();
    platforms.forEach((key, value) {
      plat.add(value);
    });
    return plat;
  }

  static ServicesLister nameToService(String name) {
    if(name == "DEFAULT") return ServicesLister.DEFAULT;
    if(name == "SPOTIFY") return ServicesLister.SPOTIFY;
    if(name == "YOUTUBE") return ServicesLister.YOUTUBE;
  }

  static Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

}
