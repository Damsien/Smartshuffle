

import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
import 'package:smartshuffle/Model/Object/TrackInformations.dart';

class Platform {
  
  String name;
  Map platformInformations = new Map();
  Map userInformations = {
      'name': 'unknow',
      'account': 'xxx@xxx.com',
      'isConnected': true
    };
  List<PlaylistInformations> playlists = new List<PlaylistInformations>();

  Platform(String name, {Map platformInformations, Map userInformations, List<PlaylistInformations> playlists}) {
    this.name = name;
    if(platformInformations != null) {
      for(MapEntry plat in platformInformations.entries) {
        this.platformInformations[plat.key] = plat.value;
      }
    }
    if(userInformations != null) this.userInformations = userInformations;
    if(playlists != null) this.playlists = playlists;
    this.platformInformations['name'] = this.name;
  }

  int addTrackToPlaylist(int playlistId, TrackInformations track) {
    int id;
    for(PlaylistInformations playlist in playlists) {
      if(playlist.id == playlistId) id = playlist.addTrack(track);
    }
    return id;
  }

  TrackInformations removeTrackFromPlaylist(int playlistId, int trackId) {
    TrackInformations deletedTrack;
    for(PlaylistInformations playlist in playlists) {
      if(playlist.id == playlistId) {
        deletedTrack = playlist.removeTrack(trackId);
      }
    }
    return deletedTrack;
  }

  PlaylistInformations addPlaylist(PlaylistInformations playlist) {
    for(PlaylistInformations playlist in playlists) {
      playlist.id = playlist.id+1;
    }
    playlists.add(playlist..setId(1));
    PlaylistInformations newPlaylist = playlists.removeAt(playlists.length-1);
    playlists.insert(0, newPlaylist);
    return newPlaylist;
  }

  PlaylistInformations removePlaylist(int playlistId) {
    PlaylistInformations deletedPlaylist = playlists.removeAt(playlistId-1);
    for(int i=playlistId-1; i<playlists.length; i++) {
      playlists.elementAt(i).id = i+1;
    }
    return deletedPlaylist;
  }

  void addAppUri(String uri) {
    platformInformations['uri'] = uri;
  }

  List<PlaylistInformations> reorder(int oldIndex, int newIndex) {
    int id = playlists.elementAt(oldIndex).id;
    for(int i=id; i<playlists.length; i++) {
      playlists.elementAt(i).id = i;
    }
    PlaylistInformations elem = playlists.removeAt(oldIndex);
    for(int i=newIndex; i<playlists.length; i++) {
      playlists.elementAt(i).id = i+2;
    }
    playlists.insert(newIndex, elem);
    elem.id = newIndex+1;
    //Save in system
    return playlists;
  }


}