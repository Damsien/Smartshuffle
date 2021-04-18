import 'dart:ffi';

import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

import 'api_path.dart';

import 'package:http/http.dart';
import 'dart:io';
import 'dart:convert';

import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'api_auth.dart';

class API {
  static final API _instance = API._internal();
  String _token;
  bool _isLoggedIn;

  factory API() {
    return _instance;
  }

  API._internal();

  get isLoggedIn {
    return _isLoggedIn;
  }

  ///
  ///Getter
  ///

  Future<List<Playlist>> getPlaylistsList() async {
    Response response =
        await get(APIPath.getPlaylistsList(), headers: _prepareHeader());
    Map json = jsonDecode(response.body);

    String next = json['next'];

    List<Playlist> list = new List();

    do {
      next = json['next'];
      _playlistList(list, json);

      if (json['next'] != null) {
        response = await get(next, headers: _prepareHeader());
        json = jsonDecode(response.body);
      }
    } while (next != null);
    return list;
  }

  Future<List<Track>> getPlaylistSongs(Playlist playlist) async {
    Response response = await get(APIPath.getPlaylistSongs(playlist),
        headers: _prepareHeader());
    Map json = jsonDecode(response.body);

    String next = json['next'];

    List<Track> tracks = new List();

    do {
      next = json['next'];
      _songsList(tracks, json);

      if (json['next'] != null) {
        response = await get(next, headers: _prepareHeader());
        json = jsonDecode(response.body);
      }
    } while (next != null);

    return tracks;
  }

  ///
  ///Setter
  ///
  void setPlaylistName(Playlist p) {
    String body = '{"name": "' + p.name + '"}';
    put(APIPath.getPlaylist(p), headers: _prepareHeader(), body: body);
  }

  ///
  ///Public
  ///
  Future login() async {
    var token = await APIAuth.login();
    if (token == null) {
      _isLoggedIn = false;
    } else {
      _isLoggedIn = true;
      _token = token;
    }
    print(token);
  }

  void disconnect() async {
    _isLoggedIn = await APIAuth.logout();
  }

  ///
  ///Private
  ///
  Map<String, String> _prepareHeader() {
    return {
      HttpHeaders.contentTypeHeader: "application/json", // or whatever
      HttpHeaders.authorizationHeader: "Bearer $_token",
    };
  }

  void _playlistList(List<Playlist> list, Map json) {
    List<dynamic> items = json['items'];
    for (int i = 0; i < items.length; i++) {
      String id = items[i]['id'];
      String name = items[i]['name'];
      String trackUri = items[i]['tracks']['href'];
      String ownerId =
          items[i]['owner']['external_urls']['spotify'].split('user/')[1];
      String ownerName = items[i]['owner']['display_name'];
      String imageUrl = 'https://source.unsplash.com/random';
      try {
        imageUrl = items[i]['images'][0]['url'];
      } catch (e) {}
      list.add(Playlist(
          id: id,
          name: name,
          uri: trackUri,
          ownerId: ownerId,
          ownerName: ownerName,
          imageUrl: imageUrl,
          service: ServicesLister.SPOTIFY));
    }
  }

  void _songsList(List<Track> list, Map json) {
    List<dynamic> items = json['items'];
    for (int i = 0; i < items.length; i++) {
      String name = "None";
      String artist = "None";
      String id = null;
      //* Le format d'image est 64x64
      String imageUrlLittle = null;
      //* Le format d'image est 
      String imageUrlLarge = null;
      String addDate = null;
      try {
        id = items[i]['track']['id'];
        name = items[i]['track']['name'];
        addDate = items[i]['added_at'];
        artist = _getAllArtist(items[i]['track']['album']['artists']);
        imageUrlLittle = items[i]['track']['album']['images'][2]['url'];
        imageUrlLarge = items[i]['track']['album']['images'][0]['url'];
      } catch (e) {
        imageUrlLittle = "https://source.unsplash.com/random";
      }
      if (id != null) {
        list.add(Track(
            id: id,
            name: name,
            service: ServicesLister.SPOTIFY,
            imageUrlLittle: imageUrlLittle,
            imageUrlLarge: imageUrlLarge,
            artist: artist));
      }
    }
  }

  String _getAllArtist(dynamic json) {
    String artists = "";
    for (int i = 0; i < json.length - 1; i++) {
      artists += json[i]['name'] + ", ";
    }
    artists += json[json.length - 1]['name'];
    return artists;
  }
}
