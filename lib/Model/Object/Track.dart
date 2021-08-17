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

  String id;
  String title;
  String artist;
  String album;
  ValueNotifier<Duration> _currentDuration = ValueNotifier<Duration>(Duration(seconds: 0));
  ValueNotifier<Duration> totalDuration = ValueNotifier<Duration>(Duration(seconds: 30));
  ServicesLister service;
  String imageUrlLittle = DEFAULT_IMAGE_URL;
  String imageUrlLarge = DEFAULT_IMAGE_URL;
  DateTime addedDate;

  // static const String PLAYMODE_PLAY = "play";
  static const String PLAYMODE_RESUME = "resume";
  static const String PLAYMODE_PAUSE = "pause";

  ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isSelected = ValueNotifier<bool>(false);

  Track streamTrack;
  File _file;

  Track(
    {
      @required this.id,
      @required this.title,
      @required this.artist,
      @required this.service,
      @required totalDuration,
      @required this.imageUrlLittle,
      @required this.imageUrlLarge,
      this.album,
      this.addedDate,
      this.streamTrack
    }
  ) {
    this.totalDuration.value = totalDuration;
  }
  
  set currentDuration(Duration duration) => _currentDuration.value = duration;
  get currentDuration => _currentDuration;

  String get serviceName => Util.serviceToString(service);

  Future<File> loadFile() async {
    if(_file != null) {
      return _file;
    } else {
      MapEntry<Track, File> me = await PlatformsLister.platforms[service].getFile(this);
      streamTrack = me.key;
      totalDuration = streamTrack.totalDuration;
      totalDuration.notifyListeners();
      DataBaseController().updateTrack(this);
      return _file = me.value;
    }
  }

  set isSelected(bool isSelected) {
    _isSelected.value = isSelected;
    if(!isSelected) seekTo(Duration.zero, false);
  }
  get isSelected => _isSelected;

  set isPlaying(bool isPlaying) {
    _isPlaying.value = isPlaying;
    this.isSelected = isPlaying;
    _isPlaying.notifyListeners();
  }
  get isPlaying => _isPlaying;

  @override
  String toString() {
    return "{$title - $artist}";
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
    PlatformsController ctrl = PlatformsLister.platforms[service];
    switch(playMode) {
      case PLAYMODE_RESUME: ctrl.resume(_file); break;
      case PLAYMODE_PAUSE: ctrl.pause(); break;
    }
  }

  void seekTo(Duration position, bool influence) {
    _currentDuration.value = position;
    if(influence) {
      PlatformsController ctrl = PlatformsLister.platforms[service];
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
    'trackid': id,
    'service': serviceName,
    'title': title,
    'artist': artist,
    'album': album,
    'imageurllittle': imageUrlLittle,
    'imageurllarge': imageUrlLarge,
    'duration': totalDuration.value.toString(),
    'adddate': addedDate.toString(),
    'streamtrack_id': streamTrack == null ? '' : streamTrack.id ,
    'streamtrack_service': streamTrack == null ? '' : streamTrack.serviceName
  };




}
