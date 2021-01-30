

import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/PlatformsLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
import 'package:smartshuffle/Model/Object/TrackInformations.dart';

abstract class PlatformsController {

  Platform platform;

  PlatformsController(Platform platform) {
    this.platform = platform;
    this.updateInformations();
  }

  updateInformations();

  /*  VIEWS   */

  Widget getButtonView();

  Widget getInformationView();


  /*  INFORMATIONS  */

  getPlatformInformations();

  getUserInformations();

  List getPlaylists();


  /*  CONNECTION    */

  connect();

  disconnect();


  /*  USER'S SERVICES */

  //Add the track to the app's playlist
  int addTrackToPlaylist(int playlistId, TrackInformations track) {
    return this.platform.addTrackToPlaylist(playlistId, track);
  }
  //Remove the track from the app's playlist
  TrackInformations removeTrackFromPlaylist(int playlistId, int trackId) {
    return this.platform.removeTrackFromPlaylist(playlistId, trackId);
  }
  //Add the track to the app's playlist
  int addPlaylist(PlaylistInformations playlist) {
    return this.platform.addPlaylist(playlist);
  }
  //Remove the track from the app's playlist
  PlaylistInformations removePlaylist(int playlistId) {
    return this.platform.removePlaylist(playlistId);
  }


}