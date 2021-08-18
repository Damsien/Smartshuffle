import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformSpotifyController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformYoutubeController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';


enum ServicesLister {
  SMARTSHUFFLE,
  SPOTIFY,
  YOUTUBE
}

class PlatformsLister {

  static Map<ServicesLister, String> tokens = {};

  static Map<ServicesLister, PlatformsController> platforms = Map<ServicesLister, PlatformsController>();

  static void initBackPlayer() {
    platforms =
    {
      ServicesLister.SMARTSHUFFLE: new PlatformDefaultController(Platform("Smartshuffle"), isBack: true),
      ServicesLister.SPOTIFY: new PlatformSpotifyController(Platform("Spotify", platformInformations: {'package': 'com.spotify.music'}), isBack: true),
      ServicesLister.YOUTUBE: new PlatformYoutubeController(Platform("Youtube", platformInformations: {'package': 'com.google.android.youtube'}), isBack: true)
    };
  }

  static ServicesLister nameToService(String name) {
    if(name == "SMARTSHUFFLE" || name == "Smartshuffle") return ServicesLister.SMARTSHUFFLE;
    if(name == "SPOTIFY" || name == "Spotify") return ServicesLister.SPOTIFY;
    if(name == "YOUTUBE" || name == "Youtube") return ServicesLister.YOUTUBE;
  }
  
  static String serviceToString(ServicesLister service) => service.toString().split(".")[1];

  static String serviceToName(ServicesLister service) => service.toString().split(".")[1].split("")[0].toUpperCase()+service.toString().split(".")[1].substring(1).toLowerCase();

}
