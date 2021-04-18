import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';

class Track with ChangeNotifier {
  String id;
  String name;
  String artist;
  String album;
  Duration currentDuration = Duration(seconds: 0);
  Duration totalDuration = Duration(minutes: 3);
  ServicesLister service;
  String imageUrlLittle;
  String imageUrlLarge;
  String addDate;

  ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

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
    this.id = id;
    this.name = name;
    this.artist = artist;
    if (totalDuration != null) this.totalDuration = totalDuration;
    this.album = album;
    this.imageUrlLittle = imageUrlLittle;
    this.imageUrlLarge = imageUrlLarge;
    this.service = service;
    this.addDate = addDate;
  }

  bool setIsPlaying(bool isPlaying) {
    this.isPlaying.value = isPlaying;
    notifyListeners();
    return this.isPlaying.value;
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
    isPlaying.value ? isPlaying.value = false : isPlaying.value = true;
    // TODO playPause
    return isPlaying.value;
  }

  void seekTo(Duration duration) {
    currentDuration = duration;
    // TODO seekTo
  }

}
