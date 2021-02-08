import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

class Playlist {

  String id;
  String name;
  String uri;
  Image image;
  ServicesLister service;

  List<MapEntry<Track, DateTime>> tracks = new List<MapEntry<Track, DateTime>>();

  Playlist({@required String name, @required String id, @required ServicesLister service, Image image, String uri, List<MapEntry<Track, DateTime>> tracks}) {
    this.name = name;
    if(id != null) this.id = id;
    if(image != null) this.image = image;
    if(tracks != null) this.tracks = tracks;
    if(uri != null) this.uri = uri;
    if(service != null) this.service = service;
  }

  ///Les paramètres à comparer pour savoir si ils sont égales
  @override
  List<Object> get props => [name, id];

  String addTrack(Track track) {
    tracks.add(MapEntry(track, DateTime.now()));
    MapEntry newTrack = tracks.removeAt(tracks.length-1);
    tracks.insert(0, newTrack);
    return track.id;
  }

  Track removeTrack(int index) {
    Track deletedTrack = tracks.removeAt(index).key;
    return deletedTrack;
  }

  void setId(String id) {
    this.id = id;
  }

  void rename(String name) {
    this.name = name;
  }


  List<Track> getTracks() {
    List<Track> finalTracks = new List<Track>();
    for(MapEntry track in tracks) {
      finalTracks.add(track.key);
    }
    return finalTracks;
  }


  List<Track> setTracks(List<Track> tracks) {
    List<Track> allTracks = tracks;
    for(Track track in allTracks) {
      this.tracks.add(MapEntry(track, DateTime.now())); 
    }
  }


  List<Track> reorder(int oldIndex, int newIndex) {
    MapEntry elem = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, elem);
    //Save in system
    return getTracks();
  }

}