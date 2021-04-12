import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';

class Track {
  String id;
  String name;
  String artist;
  String album;
  Duration currentDuration = Duration(seconds: 45);
  Duration totalDuration = Duration(minutes: 3);
  ServicesLister service;
  String imageUrl;
  String addDate;

  bool isPlaying = false;

  Track(
      {@required String name,
      @required String artist,
      @required ServicesLister service,
      @required id,
      Duration totalDuration,
      String album,
      String imageUrl,
      String addDate}) {
    this.id = id;
    this.name = name;
    this.artist = artist;
    if (totalDuration != null) this.totalDuration = totalDuration;
    this.album = album;
    this.imageUrl = imageUrl;
    this.service = service;
    this.addDate = addDate;
  }

  bool setIsPlaying(bool isPlaying) {
    return this.isPlaying = isPlaying;
  }

  void setId(String id) {
    this.id = id;
  }

  @override
  String toString() {
    return "{$name - $artist}";
  }


  /*  CONTROLS  */

  bool playPause() {
    isPlaying ? isPlaying= false : isPlaying = true;
    // TODO playPause
    return isPlaying;
  }

  void seekTo(Duration duration) {
    currentDuration = duration;
    // TODO seekTo
  }

}
