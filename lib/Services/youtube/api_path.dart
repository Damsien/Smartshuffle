import 'package:smartshuffle/models/Playlist.dart';

class APIPath {
  static String getPlaylistsList() {
    return "https://www.googleapis.com/youtube/v3/playlists?part=snippet&maxResults=50&mine=true";
  }

  static String getPlaylistSongs(Playlist playlist) {
    String id = playlist.id;
    return "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=$id";
  }
}
