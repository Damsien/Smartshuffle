import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Song.dart';

class Playlist extends Equatable {
  Playlist({@required this.name, @required this.id, this.track_uri});
  final String name;
  final String id;
  final String track_uri;
  final List<Song> _songs = List();

  List<Song> get getSongs {
    return _songs;
  }

  ///Les paramètres à comparer pour savoir si ils sont égales
  @override
  List<Object> get props => [name, id];

  ///?Faut-il aussi encoder la liste de chansons
  String toJson() {
    return jsonEncode({'name': name, 'id': id});
  }

  ///Initialize la playlist avec des sons
  ///ou avec l'aide d'un api
  void setSongsList(List<Song> songs) {
    _songs.clear();
    _songs.addAll(songs);
  }

  //TODO:Supprimer un son avec son id et son service
  void removeSong() {}

  void addSong(Song song) {
    _songs.add(song);
  }
}
