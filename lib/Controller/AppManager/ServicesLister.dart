import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformSpotifyController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformYoutubeController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';


enum ServicesLister {
  DEFAULT,
  SPOTIFY,
  YOUTUBE
}

class PlatformsLister {

  static Map<ServicesLister, String> tokens = {};

  static Map<ServicesLister, PlatformsController> platforms = Map<ServicesLister, PlatformsController>();

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
    else return null;
  }
  

  static List<PlatformsController> get allControllers {
    List<PlatformsController> plat = <PlatformsController>[];
    PlatformsLister.platforms.forEach((key, value) {
      plat.add(value);
    });
    return plat;
  }

  static List<PlatformsController> get allConnectedControllers {
    List<PlatformsController> plat = <PlatformsController>[];
    PlatformsLister.platforms.forEach((key, value) {
      if(value.platform.userInformations['isConnected']) plat.add(value);
    });
    return plat;
  }

}
