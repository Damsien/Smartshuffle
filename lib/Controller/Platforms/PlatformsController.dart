import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
import 'package:smartshuffle/Model/Object/TrackInformations.dart';

abstract class PlatformsController {

  Map<String, State> states = new Map<String, State>();
  Platform platform;

  PlatformsController(Platform platform) {
    this.platform = platform;
    this.updateInformations();
  }


  /*  STATE MANAGER */

  setPlaylistsPageState(State state) {
    this.states['PlaylistsPage'] = state;
  }

  setSearchPageState(State state) {
    this.states['SearchPage'] = state;
  }

  setProfilePageState(State state) {
    this.states['ProfilePage'] = state;
  }

  void updateState(String stringState) {
    State<dynamic> state = this.states[stringState];
    state.setState(() {
      state.widget.createState().key = UniqueKey();
    });
  }

  void updateStates() {
    for(MapEntry state in this.states.entries) {
      state.value.setState(() {
        state.value.widget.createState().key = UniqueKey();
      });
    }
  }

  updateInformations();

  /*  VIEWS   */

  Widget getButtonView();

  Widget getInformationView();


  /*  INFORMATIONS  */

  getPlatformInformations();

  getUserInformations();

  List<PlaylistInformations> getPlaylists();


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
  PlaylistInformations addPlaylist(PlaylistInformations playlist) {
    return this.platform.addPlaylist(playlist);
  }
  //Remove the track from the app's playlist
  PlaylistInformations removePlaylist(int playlistId) {
    return this.platform.removePlaylist(playlistId);
  }


}