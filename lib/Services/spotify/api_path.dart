import 'package:smartshuffle/Model/Object/Playlist.dart';

class APIPath {
  static Uri getPlaylistsList() {
    return Uri.https("api.spotify", "/v1/me/playlist");
  }

  static Uri getPlaylistSongs(Playlist playlist) {
    return playlist.uri;
  }

  static Uri getUserProfile() {
    return Uri.https("api.spotify", "/v1/me");
  }

  static Uri getPlaylist(Playlist playlist) {
    return Uri.https("api.spotify", "/v1/me/playlist/"+playlist.id);
  }
}
