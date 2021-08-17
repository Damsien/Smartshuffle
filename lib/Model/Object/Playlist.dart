import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/AppManager/DatabaseController.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsPopupItems.dart';

class Playlist {

  static const String DEFAULT_IMAGE_URL = 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Solid_purple.svg/2048px-Solid_purple.svg.png';

  String id;
  String name;
  Uri _uri;
  String ownerId;
  String ownerName;
  String imageUrl = DEFAULT_IMAGE_URL;
  ServicesLister _service;

  List<MapEntry<Track, DateTime>> tracks = <MapEntry<Track, DateTime>>[];

  Map<String, bool> _sortDirection = {'title': null, 'last_added': null, 'artist': null};

  Playlist(
      {@required this.name,
      @required this.id,
      @required ServicesLister service,
      @required this.ownerId,
      this.imageUrl,
      Uri uri,
      this.ownerName,
      this.tracks}) {
        _uri = uri;
        _service = service;
      }

  Map<String, bool> get sortDirection => _sortDirection;

  String addTrack(Track track, {@required bool isNew}) {
    tracks.insert(0, MapEntry(track, DateTime.now()));
    if(isNew) {
      DataBaseController().insertTrack(this, track);
    }
    return track.id;
  }

  Track removeTrack(int index) {
    Track deletedTrack = tracks.removeAt(index).key;
    return deletedTrack;
  }

  set uri(String newUri) {
    _uri = Uri.parse(newUri);
    DataBaseController().updatePlaylist(this);
  }
  get uri => _uri;

  void rename(String newName) {
    name = newName;
    DataBaseController().updatePlaylist(this);
  }

  List<Track> get getTracks {
    List<Track> finalTracks = <Track>[];
    for (MapEntry<Track, DateTime> track in tracks) {
      finalTracks.add(track.key);
    }
    return finalTracks;
  }

  List<Track> setTracks(List<Track> newTracks, {@required bool isNew}) {
    List<Track> allTracks = newTracks;
    tracks.clear();
    for (Track track in allTracks) {
      tracks.add(MapEntry(track, track.addedDate));
      if(isNew) {
        DataBaseController().insertTrack(this, track);
      }
    }
    DataBaseController().isOperationFinished.value = true;
    return allTracks;
  }

  List<Track> addTracks(List<Track> newTracks, {@required bool isNew}) {
    List<Track> allTracks = newTracks;
    for (Track track in allTracks) {
      bool exist = false;
      for (Track rTrack in getTracks) {
        if (rTrack.id == track.id) exist = true;
      }
      if (!exist) {
        this.addTrack(track, isNew: isNew);
      }
    }
    DataBaseController().isOperationFinished.value = true;
    return allTracks;
  }

  String _updateImage() {
    if(imageUrl == Playlist.DEFAULT_IMAGE_URL) {
      if(tracks.length >= 1) {
        imageUrl = tracks[0].key.imageUrlLarge;
      }
    }
    DataBaseController().updatePlaylist(this);
    return imageUrl;
  }

  set service(ServicesLister service) {
    _service = service;
    DataBaseController().updatePlaylist(this);
  }
  get service => _service;

  List<Track> reorder(int oldIndex, int newIndex) {
    MapEntry elem = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, elem);
    //Todo Save in system
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
    DataBaseController().updatePlaylist(this);

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
    'id': id,
    'service': _service.toString().split(".")[1],
    'platform_name': PlatformsLister.platforms[_service].platform.name,
    'ordersort': PlatformsLister.platforms[_service].platform.playlists.value.indexOf(this),
    'name': name,
    'ownerid': ownerId,
    'ownername': ownerName,
    'imageurl': imageUrl,
    'uri': _uri.toString()
  };
}
