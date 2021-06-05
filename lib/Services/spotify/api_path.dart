import 'package:smartshuffle/Model/Object/Playlist.dart';

class APIPath {
  static Uri getPlaylistsList() {
    return Uri.https("api.spotify.com", "/v1/me/playlists");
  }

  static Uri getPlaylistSongs(Playlist playlist) {
    return playlist.uri;
  }

  static Uri getUserProfile() {
    return Uri.https("api.spotify.com", "/v1/me");
  }

  static Uri getPlaylist(Playlist playlist) {
    return Uri.https("api.spotify.com", "/v1/me/playlists/"+playlist.id);
  }
}
