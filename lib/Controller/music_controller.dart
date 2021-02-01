import 'package:smartshuffle/models/Song.dart';
import 'package:smartshuffle/models/Playlist.dart';

class MusicController {
  static final MusicController _instance = MusicController._internal();
  Song _currentSong;
  List<Song> _songs = new List();
  List<Song> _queue = new List();
  Playlist _playlist;

  factory MusicController() {
    return _instance;
  }

  MusicController._internal();

  Song get currentSong {
    return _currentSong;
  }

  List<Song> get queue {
    return _queue;
  }

  Playlist get playlist {
    return _playlist;
  }

  void play(Song s, Playlist p) {
    _songs = p.getSongs;
  }

  void next() {
    if (_queue.isNotEmpty) {
      _currentSong = _queue[0];
      removeFromQueue(_currentSong);
    } else {
      int nextIndex = _songs.indexOf(_currentSong) + 1 % (_songs.length);
      _currentSong = nextIndex == 0 ? _songs.first : _songs[nextIndex];
    }
  }

  void previous() {
    int previousIndex = _songs.indexOf(_currentSong) - 1;
    _currentSong = previousIndex < 0 ? _songs.last : _songs[previousIndex];
  }

  void shuffle(Playlist p) {}

  void smartShuffle(Playlist p) {}

  void addToQueue(Song s) {
    _queue.add(s);
  }

  void removeFromQueue(Song s) {
    _queue.remove(s);
  }
}
