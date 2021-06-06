import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

class Platform {
  
  String name;
  Map platformInformations = new Map();
  Map userInformations = {
      'name': 'unknow',
      'account': 'xxx@xxx.com',
      'isConnected': false
  };
  ValueNotifier<List<Playlist>> playlists = ValueNotifier<List<Playlist>>(List<Playlist>());

  Platform(String name, {Map platformInformations, Map userInformations, List<Playlist> playlists}) {
    this.name = name;
    if(platformInformations != null) {
      for(MapEntry plat in platformInformations.entries) {
        this.platformInformations[plat.key] = plat.value;
      }
    }
    if(userInformations != null) this.userInformations = userInformations;
    if(playlists != null) this.playlists.value = playlists;
    this.platformInformations['name'] = this.name;
  }




  String addTrackToPlaylistByIndex(int playlistIndex, Track track, bool force) {
    bool exist = false;
    for(Track tr in playlists.value[playlistIndex].getTracks) {
      if(track.id == tr.id) exist = true;
    }
    if(!exist || force)
      return playlists.value.elementAt(playlistIndex).addTrack(track);
    return null;
  }
  
  Track removeTrackFromPlaylistByIndex(int playlistIndex, int trackIndex) {
    Track deletedTrack = playlists.value.elementAt(playlistIndex).removeTrack(trackIndex);
    return deletedTrack;
  }



  Playlist addPlaylist(Playlist playlist) {
    playlists.value.add(playlist);
    Playlist newPlaylist = playlists.value.removeAt(playlists.value.length-1);
    playlists.value.insert(0, newPlaylist);
    return newPlaylist;
  }

  Playlist removePlaylist(int playlistIndex) {
    Playlist deletedPlaylist = playlists.value.removeAt(playlistIndex);
    return deletedPlaylist;
  }



  List<Playlist> setPlaylist(List<Playlist> playlists) {
    return this.playlists.value = playlists;
  }



  void addAppPackage(String package) {
    platformInformations['package'] = package;
  }

  List<Playlist> reorder(int oldIndex, int newIndex) {
    Playlist elem = playlists.value.removeAt(oldIndex);
    playlists.value.insert(newIndex, elem);
    playlists.notifyListeners();
    //Save in system
    return playlists.value;
  }


}