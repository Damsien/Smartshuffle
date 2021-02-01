import 'package:smartshuffle/models/Playlist.dart';

class APIPath {
  static String getPlaylistsList() {
    return "https://api.spotify.com/v1/me/playlists";
  }

  static String getPlaylistSongs(Playlist playlist) {
    return playlist.track_uri;
  }
}
