import 'dart:collection';

import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformSpotifyController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformYoutubeController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';

class PlatformsLister {

  static LinkedHashMap platforms = 
  {
    "default": new PlatformDefaultController(Platform("SmartShuffle")),
    "spotify": new PlatformSpotifyController(Platform("Spotify")),
    "youtube": new PlatformYoutubeController(Platform("Youtube"))
  } as LinkedHashMap;



}