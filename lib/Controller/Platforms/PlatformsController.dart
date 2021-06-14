import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Players/Youtube/MainPlayer.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/ProfileView.dart';
import 'package:palette_generator/palette_generator.dart';


void _entrypoint() => AudioServiceBackground.run(() => AudioPlayerTask());
abstract class PlatformsController {
  Map<String, State> states = new Map<String, State>();
  Platform platform;

  PlatformsController(Platform platform) {
    this.platform = platform;
    this.updateInformations();
  }

  /*  STATE MANAGER */

  setPlaylistsPageState(State state) {
    states['PlaylistsPage'] = state;
  }

  setSearchPageState(State state) {
    states['SearchPage'] = state;
  }

  setProfilePageState(State state) {
    states['ProfilePage'] = state;
  }

  void updateState(String stringState) {
    State<dynamic> state = states[stringState];
    state.setState(() {
      state.widget.createState().key = UniqueKey();
    });
  }

  void updateStates() {
    for (MapEntry state in states.entries) {
      state.value.setState(() {
        state.value.widget.createState().key = UniqueKey();
      });
    }
  }

  updateInformations();

  /*  VIEWS   */

  Widget getView({@required ServicesLister service, @required ProfileViewType view, Map parameters}) {
    return ProfileView.getView(service: service, view: view, parameters: parameters);
  }

  /*  INFORMATIONS  */

  getPlatformInformations();

  getUserInformations();

  @protected
  void setAllTracks() {
    AudioPlayerTask().setAllTracksPlatform(this);
  }

  Future<List<Playlist>> getPlaylists({bool refreshing});

  Future<List<Track>> getTracks(Playlist playlist);

  ValueNotifier<List<Playlist>> getPlaylistsUpdate();

  /*  CONNECTION    */

  connect();

  disconnect();

  /*  USER'S SERVICES */

  //Add the track to the app's playlist
  String addTrackToPlaylist(int playlistIndex, Track track, bool force) {
    return this.platform.addTrackToPlaylistByIndex(playlistIndex, track, force);
  }

  //Remove the track from the app's playlist
  Track removeTrackFromPlaylist(int playlistIndex, int trackIndex) {
    return this
        .platform
        .removeTrackFromPlaylistByIndex(playlistIndex, trackIndex);
  }

  //Add the track to the app's playlist
  Playlist addPlaylist(
      {Playlist playlist,
      @required String name,
      @required String ownerId,
      String ownerName,
      String imageUrl,
      String playlistUri,
      List<MapEntry<Track, DateTime>> tracks});
  //Remove the track from the app's playlist
  Playlist removePlaylist(int playlistIndex);

  Playlist mergePlaylist(Playlist toMergeTo, Playlist toMerge);

  void renamePlaylist(Playlist playlist, String name);


  /*  MEDIA PLAYER CONTROLS  */
  
  Future<Color> _getImagePalette (ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator
      .fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor.color;
  }

  String _colorToHexString(Color color) {
    return '0xFF${color.value.toRadixString(16).substring(2, 8)}';
  }

  play(File file, Track track) async {
    print('play');
    // await AudioService.stop();
    await AudioService.start(
     backgroundTaskEntrypoint: _entrypoint,
     androidNotificationColor: int.parse(_colorToHexString(await _getImagePalette(NetworkImage(track.imageUrlLarge)))),
     params: {
      'file': file.path,
      'track_title': track.name,
      'track_artist': track.artist,
      'track_image': track.imageUrlLarge,
      'track_duration_seconds': track.totalDuration.inSeconds,
     });
  }

  resume(File file) {
    print('play');
    AudioService.play();
  }

  pause() {
    print('pause');
    AudioService.pause();
  }


  seekTo(Duration position) {
    AudioService.seekTo(position);
  }

  /*  STREAM  */

  Future<File> getFile(Track tr);

}
