import 'dart:async';
import 'dart:io';

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

  File _file;

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

  String get id => _id;

  String get name => _name;
  String get artist => _artist;
  String get album => _album;
  
  void setCurrentDuration(Duration duration) => _currentDuration.value = duration;
  ValueNotifier<Duration>  get currentDuration => _currentDuration;
  Duration  get totalDuration => _totalDuration;
  
  String get imageUrlLittle => _imageUrlLittle;
  String get imageUrlLarge => _imageUrlLarge;


  DateTime get addedDate => _addDate;
  
  ServicesLister get service => _service;
  String get serviceName => _service.toString().split(".")[1];  
  // Stream get serviceStream => _stream;

  Future _loadFile() async {
    _file = await PlatformsLister.platforms[_service].getFile(this);
  }

  bool setIsSelected(bool isSelected) {
    _isSelected.value = isSelected;
    return _isSelected.value;
  }

  bool setIsPlaying(bool isPlaying) {
    print('isp');
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
    print("frerf");
    _isPlaying.value ? _isPlaying.value = false : _isPlaying.value = true;
    if(_isPlaying.value) _backPlayer(PLAYMODE_RESUME);
    else _backPlayer(PLAYMODE_PAUSE);
    return _isPlaying.value;
  }

  bool resumeOnly() {
    _isPlaying.value = true;
    _isPlaying.notifyListeners();
    print(_isPlaying);
    return _isPlaying.value;
  }

  bool pauseOnly() {
    _isPlaying.value = false;
    _isPlaying.notifyListeners();
    return _isPlaying.value;
  }

  void _backPlayer(String playMode) async {
    PlatformsController ctrl = PlatformsLister.platforms[_service];
    switch(playMode) {
      case PLAYMODE_PLAY : {
        await _loadFile();
        ctrl.play(_file, this);
      } break;
      case PLAYMODE_RESUME: ctrl.resume(_file); break;
      case PLAYMODE_PAUSE: ctrl.pause(); break;
    }
    ctrl.mediaPlayerListener(this);
  }

  void seekTo(Duration position, bool influence) {
    _currentDuration.value = position;
    if(influence) {
      PlatformsController ctrl = PlatformsLister.platforms[_service];
      ctrl.seekTo(position);
    }
  }

}
