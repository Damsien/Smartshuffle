

import 'package:flutter/widgets.dart';

class TrackInformations {

  int id;
  String name;
  String artist;
  String album;
  Duration duration;
  Image image;
  var data;

  TrackInformations(String name, String artist, Duration duration, data, {String album, Image image}) {
    this.name = name;
    this.artist = artist;
    this.duration = duration;
    this.data = data;
    if(album != null) this.album = album;
    if(image != null) this.image = image;
  }

  void setId(int id) {
    this.id = id;
  }

}