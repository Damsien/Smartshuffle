import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/*class Song extends Equatable {
  Song(
      {@required this.name,
      @required this.service,
      @required this.id,
      this.artist,
      @required this.imageUrl});
  final String name;
  final String service;
  final String id;
  final String artist;
  final String imageUrl;

  ///!A tester car surrement faux
  ///Transforme une chanson récupérer via l'API Youtube
  ///en un élément exploitable
  factory Song.fromYoutube(Map<String, dynamic> json) {
    final name = json['name'];
    final service = 'youtube';
    final id = json['id'];
    final artist = json['artist'];
    final imageUrl = json['imageUrl'];
    return Song(
        name: name,
        service: service,
        id: id,
        artist: artist,
        imageUrl: imageUrl);
  }

  ///Les paramètres à comparer pour dire si deux chansons sont égales
  @override
  List<Object> get props => [name, service, id, artist, imageUrl];

  String toJson() {
    return jsonEncode({
      'name': name,
      'service': service,
      'href': id,
      'artist': artist,
      'imageUrl': imageUrl
    });
  }
}
*/