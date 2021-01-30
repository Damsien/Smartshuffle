import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Model/Object/TrackInformations.dart';

class PlaylistInformations {

  int id;
  String name;
  Image image;
  List<TrackInformations> tracks = new List<TrackInformations>();

  PlaylistInformations(String name, {Image image, List<TrackInformations> tracks}) {
    this.name = name;
    if(image != null) this.image = image;
    if(tracks != null) this.tracks = tracks;
  }

  int addTrack(TrackInformations track) {
    int id = tracks.length+1;
    tracks.add(track..setId(id));
    return id;
  }

  TrackInformations removeTrack(int trackId) {
    TrackInformations deletedTrack;
    deletedTrack = tracks.elementAt(trackId-1);
    tracks.removeAt(trackId-1);
    return deletedTrack;
  }

  void setId(int id) {
    this.id = id;
  }

}