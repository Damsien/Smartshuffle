import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';

class MusicController {
  static final MusicController _instance = MusicController._internal();
  Track _currentSong;
  List<Track> _songs = new List();
  List<Track> _queue = new List();
  Playlist _playlist;

  factory MusicController() {
    return _instance;
  }

  MusicController._internal();

  Track get currentSong {
    return _currentSong;
  }

  List<Track> get queue {
    return _queue;
  }

  Playlist get playlist {
    return _playlist;
  }

  void play(Track s, Playlist p) {
    _songs = p.getTracks();
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

  void addToQueue(Track s) {
    _queue.add(s);
  }

  void removeFromQueue(Track s) {
    _queue.remove(s);
  }
}
