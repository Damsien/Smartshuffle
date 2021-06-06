import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';

class Track {

  static const String DEFAULT_IMAGE_URL = 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Solid_yellow.svg/512px-Solid_yellow.svg.png';

  String _id;
  String _name;
  String _artist;
  String _album;
  ValueNotifier<Duration> _currentDuration = ValueNotifier<Duration>(Duration(seconds: 0));
  Duration _totalDuration = Duration(minutes: 3);
  ServicesLister _service;
  String _imageUrlLittle = DEFAULT_IMAGE_URL;
  String _imageUrlLarge = DEFAULT_IMAGE_URL;
  DateTime _addDate;

  static const String PLAYMODE_PLAY = "play";
  static const String PLAYMODE_RESUME = "resume";
  static const String PLAYMODE_PAUSE = "pause";

  ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isSelected = ValueNotifier<bool>(false);

  StreamSubscription streamSub;

  Track(
      {@required String name,
      @required String artist,
      @required ServicesLister service,
      @required id,
      @required Duration totalDuration,
      String album,
      @required String imageUrlLittle,
      @required String imageUrlLarge,
      DateTime addDate}) {
        
    _id = id;
    _name = name;
    _artist = artist;
    _album = album;
    if (imageUrlLittle != null) _imageUrlLittle = imageUrlLittle;
    if (imageUrlLarge != null) _imageUrlLarge = imageUrlLarge;
    _service = service;
    if (addDate != null) _addDate = addDate;
    else _addDate = DateTime.now();
    if (totalDuration != null) _totalDuration = totalDuration;
  }

  ValueListenable<bool> get isSelected => _isSelected;
  ValueListenable<bool> get isPlaying => _isPlaying;

  get id => _id;

  get name => _name;
  get artist => _artist;
  get album => _album;
  
  void setCurrentDuration(Duration duration) => _currentDuration.value = duration;
  get currentDuration => _currentDuration;
  get totalDuration => _totalDuration;
  
  get imageUrlLittle => _imageUrlLittle;
  get imageUrlLarge => _imageUrlLarge;

  DateTime get addedDate => _addDate;
  
  String get serviceName => _service.toString().split(".")[1];  
  Stream get serviceStream => PlatformsLister.platforms[_service].stream;


  bool setIsSelected(bool isSelected) {
    _isSelected.value = isSelected;
    if(isSelected) {
      streamSub = serviceStream.listen((event) {
        _isPlaying.value = !event.isPaused;
        _isPlaying.notifyListeners();
      });
    } else {
      streamSub?.cancel();
    }
    return _isSelected.value;
  }

  bool setIsPlaying(bool isPlaying) {
    _isPlaying.value = isPlaying;
    if(isPlaying) _backPlayer(PLAYMODE_PLAY);
    setIsSelected(isPlaying);
    _isPlaying.notifyListeners();
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
    switch(playMode) {
      case PLAYMODE_PLAY : ctrl.play(_id); break;
      case PLAYMODE_RESUME: ctrl.resume(); break;
      case PLAYMODE_PAUSE: ctrl.pause(); break;
    }
  }

  void seekTo(Duration duration, bool influence) {
    _currentDuration.value = duration;
    if(influence) {
      PlatformsController ctrl = PlatformsLister.platforms[_service];
      ctrl.seekTo(duration);
    }
  }

}
