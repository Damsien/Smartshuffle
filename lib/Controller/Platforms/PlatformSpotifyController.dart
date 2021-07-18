import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/BackPlayer.dart';
import 'package:smartshuffle/Controller/Players/Youtube/YoutubeRetriever.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Services/spotify/api_controller.dart' as spotify;
import 'package:spotify_sdk/spotify_sdk.dart';

class PlatformSpotifyController extends PlatformsController {
  PlatformSpotifyController(Platform platform) : super(platform) {
    platform.platformInformations['logo'] = 'assets/logo/spotify_logo.png';
    platform.platformInformations['icon'] =
        'assets/logo/icons/spotify_icon.png';
    platform.platformInformations['main_color'] = Colors.green[800];
    platform.platformInformations['secondary_color'] = Colors.green[200];
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
      play.setTracks(await spController.getPlaylistSongs(play));
      finalPlaylists.add(play);
    }
    for (int i = 0; i < platform.playlists.value.length; i++) {
      if (platform.playlists.value[i].getTracks.length == 0 || refreshing == true) {
        finalPlaylists[i]
            .setTracks(await spController.getPlaylistSongs(finalPlaylists[i]));
      }
      else
        finalPlaylists[i].setTracks(platform.playlists.value[i].getTracks);
    }
    List<Playlist> platPlaylists = platform.setPlaylist(finalPlaylists);
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
      playlist.setTracks(finalTracks);
    }

    return playlist.getTracks;
  }

  @override
  connect() async {
    await spController.login();
    platform.userInformations['isConnected'] = spController.isLoggedIn;
    platform.userInformations['name'] = spController.displayName;
    platform.userInformations['email'] = spController.email;
    this.updateStates();
  }

  @override
  disconnect() {
    spController.disconnect();
    platform.userInformations['isConnected'] = spController.isLoggedIn;
    this.updateStates();
  }

  @override
  updateInformations() {
    return null;
  }

  @override
  Playlist addPlaylist(
      {Playlist playlist,
      String name,
      String ownerId,
      String ownerName,
      String imageUrl,
      String playlistUri,
      List<MapEntry<Track, DateTime>> tracks}) {
    // TODO: implement removePlaylist
    throw UnimplementedError();
  }

  @override
  Playlist removePlaylist(int playlistIndex) {
    // TODO: implement removePlaylist
    throw UnimplementedError();
  }

  @override
  Playlist mergePlaylist(Playlist toMergeTo, Playlist toMerge) {
    // TODO: implement mergePlaylist
    throw UnimplementedError();
  }

  @override
  void renamePlaylist(Playlist playlist, String name) {
    playlist.rename(name);
    spotify.API().setPlaylistName(playlist);
  }

  @override
  Future<MapEntry<Track,File>> getFile(Track tr) async => await YoutubeRetriever().streamByName(tr);

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
