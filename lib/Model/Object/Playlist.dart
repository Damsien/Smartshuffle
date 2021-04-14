import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

class Playlist {
  String id;
  String name;
  String uri;
  String ownerId;
  String ownerName;
  String imageUrl;
  ServicesLister service;

  List<MapEntry<Track, DateTime>> tracks =
      new List<MapEntry<Track, DateTime>>();

  Map<String, bool> sortDirection = {'title': null, 'last_added': null, 'artist': null};

  Playlist(
      {@required String name,
      @required String id,
      @required ServicesLister service,
      @required String ownerId,
      String imageUrl,
      String uri,
      String ownerName,
      List<MapEntry<Track, DateTime>> tracks}) {
    this.name = name;
    this.ownerId = ownerId;
    this.id = id;
    this.imageUrl = imageUrl;
    this.uri = uri;
    this.ownerName = ownerName;
    this.service = service;
    if (tracks != null) this.tracks = tracks;
  }

  ///Les paramètres à comparer pour savoir si ils sont égales
  @override
  List<Object> get props => [name, id];

  String addTrack(Track track) {
    tracks.add(MapEntry(track, DateTime.now()));
    MapEntry newTrack = tracks.removeAt(tracks.length - 1);
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
    for (MapEntry<Track, DateTime> track in tracks) {
      finalTracks.add(track.key);
    }
    return finalTracks;
  }

  List<Track> setTracks(List<Track> tracks) {
    List<Track> allTracks = tracks;
    this.tracks.clear();
    for (Track track in allTracks) {
      this.tracks.add(MapEntry(track, DateTime.now()));
    }
    return allTracks;
  }

  List<Track> addTracks(List<Track> tracks) {
    List<Track> allTracks = tracks;
    for (Track track in allTracks) {
      bool exist = false;
      for (Track rTrack in getTracks()) {
        if (rTrack.id == track.id) exist = true;
      }
      if (!exist) this.addTrack(track);
    }
    return allTracks;
  }

  ServicesLister setService(ServicesLister service) {
    this.service = service;
  }

  List<Track> reorder(int oldIndex, int newIndex) {
    MapEntry elem = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, elem);
    //Save in system
    return getTracks();
  }

  List<Track> sort(String value) {
    if (value == 'last_added') {
      if(this.sortDirection[value] == null || !this.sortDirection[value]) {
        tracks.sort((a, b) {
          int _a = int.parse(a.value.year.toString() +
              a.value.month.toString() +
              a.value.day.toString());
          int _b = int.parse(b.value.year.toString() +
              b.value.month.toString() +
              b.value.day.toString());
          return _a.compareTo(_b);
        });
        for(String me in this.sortDirection.keys) {
          this.sortDirection[me] = null;
        }
        this.sortDirection[value] = true;
      } else {
        tracks.sort((a, b) {
          int _a = int.parse(a.value.year.toString() +
              a.value.month.toString() +
              a.value.day.toString());
          int _b = int.parse(b.value.year.toString() +
              b.value.month.toString() +
              b.value.day.toString());
          return _b.compareTo(_a);
        });
        for(String me in this.sortDirection.keys) {
          this.sortDirection[me] = null;
        }
        this.sortDirection[value] = false;
      }
    }

    if (value == 'title') {
      if(this.sortDirection[value] == null || !this.sortDirection[value]) {
        tracks.sort((a, b) {
          String _a = a.key.name;
          String _b = b.key.name;

          return _a.compareTo(_b);
        });
        for(String me in this.sortDirection.keys) {
          this.sortDirection[me] = null;
        }
        this.sortDirection[value] = true;
      } else {
        tracks.sort((a, b) {
          String _a = a.key.name;
          String _b = b.key.name;

          return _b.compareTo(_a);
        });
        for(String me in this.sortDirection.keys) {
          this.sortDirection[me] = null;
        }
        this.sortDirection[value] = false;
      }
    }

    if (value == 'artist') {
      if(this.sortDirection[value] == null || !this.sortDirection[value]) {
        tracks.sort((a, b) {
          String _a = a.key.artist;
          String _b = b.key.artist;

          return _a.compareTo(_b);
        });
        for(String me in this.sortDirection.keys) {
          this.sortDirection[me] = null;
        }
        this.sortDirection[value] = true;
      } else {
        tracks.sort((a, b) {
          String _a = a.key.artist;
          String _b = b.key.artist;

          return _b.compareTo(_a);
        });
        for(String me in this.sortDirection.keys) {
          this.sortDirection[me] = null;
        }
        this.sortDirection[value] = false;
      }
    }

    return getTracks();
  }
}
