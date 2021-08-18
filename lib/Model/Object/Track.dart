import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/AppManager/DatabaseController.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Util.dart';

class Track {

  static const String DEFAULT_IMAGE_URL = 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Solid_purple.svg/2048px-Solid_purple.svg.png';

  String _id;
  String _title;
  String _artist;
  String _album;
  ValueNotifier<Duration> _currentDuration = ValueNotifier<Duration>(Duration(seconds: 0));
  ValueNotifier<Duration> _totalDuration = ValueNotifier<Duration>(Duration(seconds: 30));
  ServicesLister _service;
  String _imageUrlLittle = DEFAULT_IMAGE_URL;
  String _imageUrlLarge = DEFAULT_IMAGE_URL;
  DateTime _addedDate = DateTime.now();
  
  static const String PLAYMODE_RESUME = "resume";
  static const String PLAYMODE_PAUSE = "pause";

  ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isSelected = ValueNotifier<bool>(false);

  Track _streamTrack;
  File _file;

  Track(
    {
      @required String title,
      @required String artist,
      @required ServicesLister service,
      @required id,
      @required Duration totalDuration,
      String album,
      @required String imageUrlLittle,
      @required String imageUrlLarge,
      DateTime addedDate,
      Track streamTrack
    }
  ) {
    _id = id;
    _title = title;
    _artist = artist;
    _album = album;
    _service = service;
    if (imageUrlLittle != null) _imageUrlLittle = imageUrlLittle;
    if (imageUrlLarge != null) _imageUrlLarge = imageUrlLarge;
    if (addedDate != null) _addedDate = addedDate;
    if (totalDuration != null) _totalDuration.value = totalDuration;
    _streamTrack = streamTrack;
  }

  /*  SETTERS AND GETTER  */

  // Id
  set id(String id) {
    _id = id;
    DataBaseController().updateTrack(this);
  }
  String get id => _id;

  // Title
  set title(String title) {
    _title = id;
    DataBaseController().updateTrack(this);
  }
  String get title => _title;

  // Artist
  set artist(String artist) {
    _artist = artist;
    DataBaseController().updateTrack(this);
  }
  String get artist => _artist;

  // Album
  set album(String album) {
    _album = album;
    DataBaseController().updateTrack(this);
  }
  String get album => _album;
  
  // Current duration
  set currentDurationValue(Duration duration) => _currentDuration.value = duration;
  ValueNotifier<Duration> get currentDuration => _currentDuration;

  // Total duration
  set totalDurationValue(Duration totalDuration) {
    _totalDuration.value = totalDuration;
    DataBaseController().updateTrack(this);
  }
  ValueNotifier<Duration> get totalDuration => _totalDuration;
  
  // Image little
  set imageUrlLittle(String totaimageUrlLittlel) {
    _imageUrlLittle = imageUrlLittle;
    DataBaseController().updateTrack(this);
  }
  String get imageUrlLittle => _imageUrlLittle;
  
  // Image large
  set imageUrlLarge(String imageUrlLarge) {
    _imageUrlLarge = imageUrlLarge;
    DataBaseController().updateTrack(this);
  }
  String get imageUrlLarge => _imageUrlLarge;

  // Added date
  set addedDate(DateTime addedDate) {
    _addedDate = addedDate;
    DataBaseController().updateTrack(this);
  }
  DateTime get addedDate => _addedDate;
  
  // Service
  set service(ServicesLister service) {
    _service = service;
    DataBaseController().updateTrack(this);
  }
  ServicesLister get service => _service;
  String get serviceName => PlatformsLister.serviceToString(_service);

  set selecting(bool isSelected) {
    _isSelected.value = isSelected;
    if(!isSelected) seekTo(Duration.zero, false);
  }
  ValueListenable<bool> get isSelected => _isSelected;

  set playing(bool isPlaying) {
    _isPlaying.value = isPlaying;
    this.selecting = isPlaying;
    _isPlaying.notifyListeners();
  }
  ValueListenable<bool> get isPlaying => _isPlaying;

  Track get streamTrack => _streamTrack;

  Future<File> loadFile() async {
    if(_file != null) {
      return _file;
    } else {
      MapEntry<Track, File> me = await PlatformsLister.platforms[_service].getFile(this);
      _streamTrack = me.key;
      _totalDuration = _streamTrack.totalDuration;
      _totalDuration.notifyListeners();
      DataBaseController().updateTrack(this);
      return _file = me.value;
    }
  }

  @override
  String toString() {
    return "{$_title - $_artist}";
  }


  /*  CONTROLS  */

  bool playPause() {
    _isPlaying.value ? _isPlaying.value = false : _isPlaying.value = true;
    if(_isPlaying.value) _backPlayer(PLAYMODE_RESUME);
    else _backPlayer(PLAYMODE_PAUSE);
    return _isPlaying.value;
  }

  bool resumeOnly() {
    _isPlaying.value = true;
    return _isPlaying.value;
  }

  bool pauseOnly() {
    _isPlaying.value = false;
    return _isPlaying.value;
  }

  Future<void> _backPlayer(String playMode) async {
    PlatformsController ctrl = PlatformsLister.platforms[_service];
    switch(playMode) {
      // case PLAYMODE_PLAY : {
      //   if(_file == null) await loadFile();
      //   ctrl.play(_file, this);
      // } break;
      case PLAYMODE_RESUME: ctrl.resume(_file); break;
      case PLAYMODE_PAUSE: ctrl.pause(); break;
    }
  }

  void seekTo(Duration position, bool influence) {
    _currentDuration.value = position;
    if(influence) {
      PlatformsController ctrl = PlatformsLister.platforms[_service];
      ctrl.seekTo(position);
    }
  }


  // Object persistence

  factory Track.fromMap(Map<String, dynamic> json) => Track(
    id: json['trackid'],
    title: json['title'],
    artist: json['artist'],
    album: json['album'],
    imageUrlLittle: json['imageurllittle'],
    imageUrlLarge: json['imageurllarge'],
    service: PlatformsLister.nameToService(json['service']),
    totalDuration: Util.parseDuration(json['duration']),
    streamTrack: json['streamtrack'],
    addedDate: DateTime.parse(json['adddate'])
  );

  Map<String, dynamic> toMap() =>
  {
    'trackid': _id,
    'service': serviceName,
    'title': _title,
    'artist': _artist,
    'album': _album,
    'imageurllittle': _imageUrlLittle,
    'imageurllarge': _imageUrlLarge,
    'duration': _totalDuration.value.toString(),
    'adddate': _addedDate.toString(),
    'streamtrack_id': _streamTrack == null ? '' : _streamTrack.id ,
    'streamtrack_service': _streamTrack == null ? '' : _streamTrack.serviceName
  };




}
