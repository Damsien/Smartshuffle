import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';

class Track {

  String id;
  String name;
  String artist;
  String album;
  Duration duration;
  ServicesLister service;
  String imageUrl;

  Track({@required String name,
   @required String artist,
   @required ServicesLister service,
   @required id,
   Duration duration, String album, String imageUrl}) {
    this.id = id;
    this.name = name;
    this.artist = artist;
    this.duration = duration;
    if(album != null) this.album = album;
    if(imageUrl != null) this.imageUrl = imageUrl;
    if(service != null) this.service = service;
  }

  void setId(String id) {
    this.id = id;
  }

}