import 'package:smartshuffle/models/Playlist.dart';

class PlaylistsController {
  static List<Playlist> playlists = new List();

  static void addPlaylist(Playlist playlist) {
    playlists.add(playlist);
  }

  static void addPlaylists(List<Playlist> _playlists) {
    playlists.addAll(_playlists);
  }

//TODO: supprimer une playlist
  static void deletePlaylist(Playlist playlist) {}

//TODO: supprimer plusieurs playlist
  static void deletePlaylists(List<Playlist> _playlists) {}
}
