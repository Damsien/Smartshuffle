

import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
import 'package:smartshuffle/Model/Object/TrackInformations.dart';

class Platform {
  
  String name;
  Map platformInformations = new Map();
  Map userInformations = {
      'name': 'unknow',
      'account': 'xxx@xxx.com',
      'isConnected': false
    };
  List<PlaylistInformations> playlists = new List<PlaylistInformations>();

  Platform(String name, {Map platformInformations, Map userInformations, List<PlaylistInformations> playlists}) {
    this.name = name;
    if(platformInformations != null) this.platformInformations = platformInformations;
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

  int addPlaylist(PlaylistInformations playlist) {
    int id = playlists.length+1;
    playlists.add(playlist..setId(id));
    return id;
  }

  PlaylistInformations removePlaylist(int playlistId) {
    PlaylistInformations deletedPlaylist;
    deletedPlaylist = playlists.elementAt(playlistId-1);
    playlists.removeAt(playlistId-1);
    return deletedPlaylist;
  }

  void addAppUri(String uri) {
    platformInformations['uri'] = uri;
  }


}