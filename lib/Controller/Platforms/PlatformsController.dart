import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/ViewGetter/ViewGetter.dart';

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

  Widget getView({@required ServicesLister service, @required ViewType view}) {
    return ViewGetter.getView(service: service, view: view);
  }


  /*  INFORMATIONS  */

  getPlatformInformations();

  getUserInformations();

  Future<List<Playlist>> getPlaylists();

  Future<List<Track>> getTracks(Playlist playlist);


  /*  CONNECTION    */

  connect();

  disconnect();


  /*  USER'S SERVICES */

  //Add the track to the app's playlist
  String addTrackToPlaylist(int playlistIndex, Track track) {
    return this.platform.addTrackToPlaylistByIndex(playlistIndex, track);
  }
  //Remove the track from the app's playlist
  Track removeTrackFromPlaylist(int playlistIndex, int trackIndex) {
    return this.platform.removeTrackFromPlaylistByIndex(playlistIndex, trackIndex);
  }
  //Add the track to the app's playlist
  Playlist addPlaylist({@required String name, @required String ownerId, String ownerName, String imageUrl, String playlistUri, List<MapEntry<Track, DateTime>> tracks});
  //Remove the track from the app's playlist
  Playlist removePlaylist(int playlistIndex);


}