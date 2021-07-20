import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsPopupItems.dart';

class Playlist {

  static const String DEFAULT_IMAGE_URL = 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Solid_yellow.svg/512px-Solid_yellow.svg.png';

  String _id;
  String _name;
  Uri _uri;
  String _ownerId;
  String _ownerName;
  String _imageUrl = DEFAULT_IMAGE_URL;
  ServicesLister _service;

  List<MapEntry<Track, DateTime>> _tracks =
      new List<MapEntry<Track, DateTime>>();

  Map<String, bool> _sortDirection = {'title': null, 'last_added': null, 'artist': null};

  Playlist(
      {@required String name,
      @required String id,
      @required ServicesLister service,
      @required String ownerId,
      String imageUrl,
      Uri uri,
      String ownerName,
      List<MapEntry<Track, DateTime>> tracks}) {
    _id = id;
    _name = name;
    _ownerId = ownerId;
    if(imageUrl != null) _imageUrl = imageUrl;
    _uri = uri;
    _ownerName = ownerName;
    _service = service;
    if (tracks != null) _tracks = tracks;
  }

  String get id => _id;
  String get name => _name;
  String get ownerId => _ownerId;
  String get ownerName => _ownerName;
  String get imageUrl => _imageUrl;
  Map<String, bool> get sortDirection => _sortDirection;
  Uri get uri => _uri;
  ServicesLister  get service => _service;
  List<MapEntry<Track, DateTime>> get tracks => _tracks;

  ///Les paramètres à comparer pour savoir si ils sont égales
  @override
  List<Object> get props => [name, id];

  String addTrack(Track track) {
    tracks.add(MapEntry(track, DateTime.now()));
    MapEntry newTrack = tracks.removeAt(tracks.length - 1);
    tracks.insert(0, newTrack);
    DataBaseController().insertTrack(this, track);
    return track.id;
  }

  Track removeTrack(int index) {
    Track deletedTrack = tracks.removeAt(index).key;
    return deletedTrack;
  }

  void setId(String id) {
    _id = id;
  }

  void rename(String name) {
    _name = name;
  }

  List<Track> get getTracks {
    List<Track> finalTracks = new List<Track>();
    for (MapEntry<Track, DateTime> track in _tracks) {
      finalTracks.add(track.key);
    }
    return finalTracks;
  }

  List<Track> setTracks(List<Track> tracks) {
    List<Track> allTracks = tracks;
    _tracks.clear();
    for (Track track in allTracks) {
      _tracks.add(MapEntry(track, track.addedDate));
    }
    return allTracks;
  }

  List<Track> addTracks(List<Track> tracks) {
    List<Track> allTracks = tracks;
    for (Track track in allTracks) {
      bool exist = false;
      for (Track rTrack in getTracks) {
        if (rTrack.id == track.id) exist = true;
      }
      if (!exist) this.addTrack(track);
    }
    return allTracks;
  }

  NetworkImage _updateImage() {
    if(_imageUrl == Playlist.DEFAULT_IMAGE_URL) {
      if(_tracks.length >= 1) {
        _imageUrl = _tracks[0].key.imageUrlLarge;
      }
    }
  }

  ServicesLister setService(ServicesLister service) {
    _service = service;
  }

  List<Track> reorder(int oldIndex, int newIndex) {
    MapEntry elem = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, elem);
    //Save in system
    return getTracks;
  }

  List<Track> sort(String value) {
    
    if (value == PopupMenuConstants.SORTMODE_LASTADDED) {
      if(_sortDirection[value] == null || !_sortDirection[value]) {
        tracks.sort((a, b) {
          int _a = int.parse(a.value.year.toString() +
              a.value.month.toString() +
              a.value.day.toString());
          int _b = int.parse(b.value.year.toString() +
              b.value.month.toString() +
              b.value.day.toString());
          return _a.compareTo(_b);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = true;
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
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = false;
      }
    }

    if (value == PopupMenuConstants.SORTMODE_TITLE) {
      if(_sortDirection[value] == null || !_sortDirection[value]) {
        tracks.sort((a, b) {
          String _a = a.key.title;
          String _b = b.key.title;

          return _a.compareTo(_b);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = true;
      } else {
        tracks.sort((a, b) {
          String _a = a.key.title;
          String _b = b.key.title;

          return _b.compareTo(_a);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = false;
      }
    }

    if (value == PopupMenuConstants.SORTMODE_ARTIST) {
      if(_sortDirection[value] == null || !_sortDirection[value]) {
        tracks.sort((a, b) {
          String _a = a.key.artist;
          String _b = b.key.artist;

          return _a.compareTo(_b);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = true;
      } else {
        tracks.sort((a, b) {
          String _a = a.key.artist;
          String _b = b.key.artist;

          return _b.compareTo(_a);
        });
        for(String me in _sortDirection.keys) {
          _sortDirection[me] = null;
        }
        _sortDirection[value] = false;
      }
    }

    return getTracks;
  }

  bool isMine(Track track) {
    return getTracks.contains(track);
  }



  // Object persistence

  factory Playlist.fromMap(Map<String, dynamic> json) => Playlist(
    id: json['id'],
    ownerId: json['ownerid'],
    ownerName: json['ownername'],
    service: PlatformsLister.nameToService(json['service']),
    name: json['name'],
    imageUrl: json['imageurl'],
    uri: Uri.parse(json['uri'])
  );

  Map<String, dynamic> toMap() =>
  {
    'id': _id,
    'service': _service.toString().split(".")[1],
    'name': name,
    'ownerid': ownerId,
    'ownername': ownerName,
    'imageurl': imageUrl,
    'uri': uri.toFilePath(windows: false)
  };
}
