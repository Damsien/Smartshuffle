import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/BackPlayer.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Util.dart';

class Track {

  static const String DEFAULT_IMAGE_URL = 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Solid_yellow.svg/512px-Solid_yellow.svg.png';

  String _id;
  String _title;
  String _artist;
  String _album;
  ValueNotifier<Duration> _currentDuration = ValueNotifier<Duration>(Duration(seconds: 0));
  ValueNotifier<Duration> _totalDuration = ValueNotifier<Duration>(Duration(seconds: 30));
  ServicesLister _service;
  String _imageUrlLittle = DEFAULT_IMAGE_URL;
  String _imageUrlLarge = DEFAULT_IMAGE_URL;
  DateTime _addDate;

  // static const String PLAYMODE_PLAY = "play";
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
      DateTime addDate,
      Track streamTrack
    }
  ) {
    _id = id;
    _title = title;
    _artist = artist;
    _album = album;
    if (imageUrlLittle != null) _imageUrlLittle = imageUrlLittle;
    if (imageUrlLarge != null) _imageUrlLarge = imageUrlLarge;
    _service = service;
    if (addDate != null) _addDate = addDate;
    else _addDate = DateTime.now();
    if (totalDuration != null) _totalDuration.value = totalDuration;
    if (streamTrack != null) _streamTrack = streamTrack;
  }

  ValueListenable<bool> get isSelected => _isSelected;
  ValueListenable<bool> get isPlaying => _isPlaying;

  String get id => _id;

  String get title => _title;
  String get artist => _artist;
  String get album => _album;
  
  void setCurrentDuration(Duration duration) => _currentDuration.value = duration;
  ValueNotifier<Duration>  get currentDuration => _currentDuration;
  ValueNotifier<Duration>  get totalDuration => _totalDuration;
  
  String get imageUrlLittle => _imageUrlLittle;
  String get imageUrlLarge => _imageUrlLarge;


  DateTime get addedDate => _addDate;
  
  ServicesLister get service => _service;
  String get serviceName => _service.toString().split(".")[1];  
  // Stream get serviceStream => _stream;

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

  bool setIsSelected(bool isSelected) {
    _isSelected.value = isSelected;
    if(!isSelected) seekTo(Duration.zero, false);
    return _isSelected.value;
  }

  Future<bool> setIsPlaying(bool isPlaying) async {
    _isPlaying.value = isPlaying;
    // if(isPlaying) await _backPlayer(PLAYMODE_PLAY);
    setIsSelected(isPlaying);
    _isPlaying.notifyListeners();
    return _isPlaying.value;
  }

  void setId(String id) {
    _id = id;
    DataBaseController().updateTrack(this);
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
    id: json['id'],
    title: json['title'],
    artist: json['artist'],
    album: json['album'],
    imageUrlLittle: json['imageurllittle'],
    imageUrlLarge: json['imageurllarge'],
    service: PlatformsLister.nameToService(json['service']),
    totalDuration: Util.parseDuration(json['duration']),
    streamTrack: json['streamtrack'],
    addDate: DateTime.parse(json['addDate'])
  );

  Map<String, dynamic> toMap() =>
  {
    'id': _id,
    'service': serviceName,
    'title': _title,
    'artist': _artist,
    'album': _album,
    'imageurllittle': _imageUrlLittle,
    'imageurllarge': _imageUrlLarge,
    'totalduration': _totalDuration.value.toString(),
    'adddate': _addDate.toString(),
    'streamtrack_id': _streamTrack == null ? '' : _streamTrack.id ,
    'streamtrack_service': _streamTrack == null ? '' : _streamTrack.serviceName
  };




}
