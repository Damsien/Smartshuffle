import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';

class Track with ChangeNotifier {
  String _id;
  String _name;
  String _artist;
  String _album;
  Duration _currentDuration = Duration(seconds: 0);
  Duration _totalDuration = Duration(minutes: 3);
  ServicesLister _service;
  String _imageUrlLittle;
  String _imageUrlLarge;
  String _addDate;

  static const String PLAYMODE_PLAY = "play";
  static const String PLAYMODE_RESUME = "resume";
  static const String PLAYMODE_PAUSE = "pause";

  ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(false);

  Track(
      {@required String name,
      @required String artist,
      @required ServicesLister service,
      @required id,
      Duration totalDuration,
      String album,
      String imageUrlLittle,
      String imageUrlLarge,
      String addDate}) {
    _id = id;
    _name = name;
    _artist = artist;
    if (totalDuration != null) _totalDuration = totalDuration;
    _album = album;
    _imageUrlLittle = imageUrlLittle;
    _imageUrlLarge = imageUrlLarge;
    _service = service;
    _addDate = addDate;
  }

 ValueListenable<bool> get isPlaying => _isPlaying;

  get id => _id;

  get name => _name;
  get artist => _artist;
  get album => _album;
  
  get currentDuration => _currentDuration;
  get totalDuration => _totalDuration;
  
  get imageUrlLittle => _imageUrlLittle;
  get imageUrlLarge => _imageUrlLarge;
  
  get serviceName => _service.toString().split(".")[1];  

  bool setIsPlaying(bool isPlaying) {
    _isPlaying.value = isPlaying;
    notifyListeners();
    if(isPlaying) _backPlayer(PLAYMODE_PLAY);
    return _isPlaying.value;
  }

  void setId(String id) {
    _id = id;
  }

  @override
  String toString() {
    return "{$_name - $_artist}";
  }


  /*  CONTROLS  */

  bool playPause() {
    _isPlaying.value ? _isPlaying.value = false : _isPlaying.value = true;
    if(_isPlaying.value) _backPlayer(PLAYMODE_RESUME);
    else _backPlayer(PLAYMODE_PAUSE);
    return _isPlaying.value;
  }

  void _backPlayer(String playMode) {
    PlatformsController ctrl = PlatformsLister.platforms[_service];
    print(_id);
    switch(playMode) {
      case PLAYMODE_PLAY : ctrl.play(_id); break;
      case PLAYMODE_RESUME: ctrl.resume(); break;
      case PLAYMODE_PAUSE: ctrl.pause(); break;
    }
  }

  void seekTo(Duration duration) {
    _currentDuration = duration;
    // TODO seekTo
  }

}
