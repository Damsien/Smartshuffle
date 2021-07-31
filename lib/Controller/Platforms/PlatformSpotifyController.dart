import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/composer/v1.dart';
import 'package:smartshuffle/Controller/DatabaseController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/BackPlayer.dart';
import 'package:smartshuffle/Controller/Players/Youtube/YoutubeRetriever.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Services/spotify/api_controller.dart' as spotify;
import 'package:spotify_sdk/spotify_sdk.dart';

class PlatformSpotifyController extends PlatformsController {
  PlatformSpotifyController(Platform platform, {bool isBack}) : super(platform, isBack: isBack) {
    platform.platformInformations['logo'] = 'assets/logo/spotify_logo.png';
    platform.platformInformations['icon'] =
        'assets/logo/icons/spotify_icon.png';
    platform.platformInformations['main_color'] = Colors.green[800];
    platform.platformInformations['secondary_color'] = Colors.green[200];

    features = {
      PlatformsCtrlFeatures.PLAYLIST_ADD: true,
      PlatformsCtrlFeatures.PLAYLIST_GET: true,
      PlatformsCtrlFeatures.PLAYLIST_CLONE: true,
      PlatformsCtrlFeatures.PLAYLIST_MERGE: true,
      PlatformsCtrlFeatures.PLAYLIST_REMOVE: false,
      PlatformsCtrlFeatures.PLAYLIST_RENAME: true,
      PlatformsCtrlFeatures.TRACK_ADD_ANOTHER_PLAYLIST: true,
      PlatformsCtrlFeatures.TRACK_ADD: true,
      PlatformsCtrlFeatures.TRACK_GET: true,
      PlatformsCtrlFeatures.TRACK_REMOVE: true
    };
  }

  spotify.API spController = new spotify.API();

  @override
  getPlatformInformations() {
    return platform.platformInformations;
  }

  @override
  getUserInformations() {
    return platform.userInformations;
  }

  @override
  Future<List<Playlist>> getPlaylists({bool refreshing}) async {
    var parent = await super.getPlaylists(refreshing: refreshing);
    if(parent != null) return parent;
    List<Playlist> finalPlaylists = List<Playlist>();
    List<Playlist> playlists = await spController.getPlaylistsList();
    for (Playlist play in platform.playlists.value) {
      for (int i = 0; i < playlists.length; i++) {
        if (play.id == playlists[i].id) {
          finalPlaylists.add(playlists[i]);
          playlists.removeAt(i);
        }
      }
    }
    for (Playlist play in playlists) {
      play.setTracks(await spController.getPlaylistSongs(play), isNew: true);
      finalPlaylists.add(play);
    }
    for (int i = 0; i < platform.playlists.value.length; i++) {
      if (platform.playlists.value[i].getTracks.length == 0 || refreshing == true) {
        finalPlaylists[i]
            .setTracks(await spController.getPlaylistSongs(finalPlaylists[i]), isNew: true);
      }
      else
        finalPlaylists[i].setTracks(platform.playlists.value[i].getTracks, isNew: true);
    }
    List<Playlist> platPlaylists = platform.setPlaylist(finalPlaylists, isNew: true);
    super.getAllPlatformTracks();
    return platPlaylists;
  }
  
  @override
  ValueNotifier<List<Playlist>> getPlaylistsUpdate() {
    return platform.playlists;
  }

  @override
  Future<List<Track>> getTracks(Playlist playlist) async {
    List<Track> finalTracks = List<Track>();

    if (playlist.getTracks.isEmpty) {
      List<Track> tracks = await spController.getPlaylistSongs(playlist);
      for (Track track in playlist.getTracks) {
        for (int i = 0; i < tracks.length; i++) {
          if (track.id == tracks[i].id) {
            finalTracks.add(tracks[i]);
            tracks.removeAt(i);
          }
        }
      }
      for (Track track in tracks) {
        finalTracks.add(track);
      }
      playlist.setTracks(finalTracks, isNew: true);
    }

    return playlist.getTracks;
  }

  @override
  connect() async {
    await spController.login();
    platform.userInformations['isConnected'] = spController.isLoggedIn;
    platform.userInformations['name'] = spController.displayName;
    platform.userInformations['email'] = spController.email;
    DataBaseController().updatePlatform(platform);
    PlatformsController.updateStates();
  }

  @override
  disconnect() async {
    spController.disconnect();
    platform.userInformations['isConnected'] = spController.isLoggedIn;
    for(int i=0; i<platform.playlists.value.length; i++) {
      platform.removePlaylist(i);
    }
    DataBaseController().updatePlatform(platform);
    PlatformsController.updateStates();
  }

  @override
  updateInformations() {
    return null;
  }

  @override
  String addTrackToPlaylist(int playlistIndex, Track track, bool force) {
    String id = super.addTrackToPlaylist(playlistIndex, track, force);
    String uri = 'spotify:track:$id';
    Playlist playlist = platform.playlists.value.elementAt(playlistIndex);
    spController.addTracks(playlist, [uri]);
    return id;
  }

  @override
  Track removeTrackFromPlaylist(int playlistIndex, int trackIndex) {
    
  }

  @override
  FutureOr<Playlist> addPlaylist(
      {Playlist playlist,
      String name,
      String ownerId,
      String ownerName,
      String imageUrl,
      String playlistUri,
      List<MapEntry<Track, DateTime>> tracks}) async {
    Playlist finalPlaylist = Playlist(
      name: name,
      ownerId: ownerId,
      ownerName: ownerName,
      service: ServicesLister.SPOTIFY,
      imageUrl: imageUrl,
    );
    finalPlaylist = await spController.createPlaylist(finalPlaylist);
    return this.platform.addPlaylist(finalPlaylist, isNew: true);
  }

  @override
  Playlist removePlaylist(int playlistIndex) {
    throw UnimplementedError();
  }

  @override
  Playlist mergePlaylist(Playlist toMergeTo, Playlist toMerge) {
    toMergeTo..addTracks(toMerge.getTracks, isNew: true);
    List<String> uris = List<String>();
    for(Track tr in toMerge.getTracks) {
      uris.add('spotify:track:${tr.id}');
    }
    spController.addTracks(toMergeTo, uris);
    return toMergeTo;
  }

  @override
  void renamePlaylist(Playlist playlist, String name) {
    playlist.rename(name);
    spotify.API().setPlaylistName(playlist);
  }

  @override
  Future<MapEntry<Track,File>> getFile(Track tr) async {
    if(tr.streamTrack == null) {
      return await YoutubeRetriever().streamByName(tr);
    } else {
      return MapEntry(tr.streamTrack, await YoutubeRetriever().streamById(tr.streamTrack.id));
    }
  }

  // @override
  // pause() {
  //   SpotifySdk.pause();
  // }

  // @override
  // play(String spotifyId) {
  //   SpotifySdk.play(spotifyUri: 'spotify:track:$spotifyId');
  // }

  // @override
  // resume() {
  //   SpotifySdk.resume();
  // }

  // @override
  // seekTo(Duration duration) async {
  //   await SpotifySdk.seekTo(positionedMilliseconds: duration.inMilliseconds);
  // }

}
