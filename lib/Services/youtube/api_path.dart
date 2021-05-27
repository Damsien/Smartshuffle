import 'package:smartshuffle/Model/Object/Playlist.dart';

class APIPath {
  static Uri getPlaylistsList() {
    return Uri.https("www.googleapis.com", "/youtube/v3/playlists", {"part": "snippet", "maxResults": "50", "mine": "true"});
  }

  static Uri getPlaylistSongs(Playlist playlist) {
    String id = playlist.id;
    return Uri.https("www.googleapis.com", "/youtube/v3/playlistItems", {"part": "snippet", "playlistId": "$id"});
  }
}
