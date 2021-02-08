import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';

class Track {

  String id;
  String name;
  String artist;
  String album;
  Duration duration;
  ServicesLister service;
  Image image;

  Track({@required String name,
   @required String artist,
   @required ServicesLister service,
   @required id,
   Duration duration, String album, Image image}) {
    this.name = name;
    this.artist = artist;
    this.duration = duration;
    if(album != null) this.album = album;
    if(image != null) this.image = image;
    if(service != null) this.service = service;
  }

  void setId(String id) {
    this.id = id;
  }

}