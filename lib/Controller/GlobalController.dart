import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Controller/Players/PlayersController.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

abstract class GlobalController {

  
  /*  PLAYER CONTROLLER */

  static getPlayerController() {
    return PlayersController;
  }


  /*  PLATFORM SERVICES */
  
  static getPlatformServices(String platform) {
    for(MapEntry plat in PlatformsLister.platforms.entries) {
      if(plat.key == platform)
        return plat.value;
    }
  }

  

  /*  USER'S SERVICES */

  //Add the track to the app's playlist
  static addTrackToPlaylist(String platform, playlistId, Track track) {
    PlatformsLister.platforms[platform].addTrackToPlaylist(playlistId, track);
  }
  //Remove the track from the app's playlist
  static removeTrackFromPlaylist(String platform, playlistId, trackId) {
    PlatformsLister.platforms[platform].removeTrackFromPlaylist(playlistId, trackId);
  }


}