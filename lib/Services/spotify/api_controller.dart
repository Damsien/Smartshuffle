import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/models/Song.dart';

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

  Future<List<Playlist>> getPlaylistsList() async {
    Response response =
        await get(APIPath.getPlaylistsList(), headers: _prepareHeader());
    Map json = jsonDecode(response.body);
    return _playlistList(json);
  }

  Future<List<Track>> getPlaylistSongs(Playlist playlist) async {
    Response response = await get(APIPath.getPlaylistSongs(playlist),
        headers: _prepareHeader());
    Map json = jsonDecode(response.body);
    return _songsList(json);
  }

  Map<String, String> _prepareHeader() {
    return {
      HttpHeaders.contentTypeHeader: "application/json", // or whatever
      HttpHeaders.authorizationHeader: "Bearer $_token",
    };
  }

  Future login() async {
    var token = await APIAuth.login();
    if (token == null) {
      _isLoggedIn = false;
    } else {
      _isLoggedIn = true;
      _token = token;
    }
  }

  void disconnect() async {
    _isLoggedIn = await APIAuth.logout();
  }

  List<Playlist> _playlistList(Map json) {
    List<Playlist> list = new List();
    List<dynamic> items = json['items'];
    for (int i = 0; i < items.length; i++) {
      String id = items[i]['id'];
      String name = items[i]['name'];
      String trackUri = items[i]['tracks']['href'];
      String ownerId = items[i]['owner']['external_urls']['spotify'].split('user/')[1];
      String ownerName = items[i]['owner']['display_name'];
      String imageUrl = items[i]['images'][0]['url'];
      list.add(Playlist(id: id, name: name, uri: trackUri, ownerId: ownerId, ownerName: ownerName, imageUrl: imageUrl, service: ServicesLister.SPOTIFY));
    }
    return list;
  }

  List<Track> _songsList(Map json) {
    List<Track> list = new List();
    List<dynamic> items = json['items'];
    for (int i = 0; i < items.length; i++) {
      String name = "None";
      String artist = "None";
      String id = null;
      //* Le format d'image est 640x640
      String imageUrl = null;
      try {
        id = items[i]['track']['id'];
        name = items[i]['track']['name'];
        artist = items[i]['track']['album']['artists'][0]['name'];
        imageUrl = items[i]['track']['album']['images'][0]['url'];
      } catch (e) {}
      if(id != null) {
        list.add(Track(
          id: id,
          name: name,
          service: ServicesLister.SPOTIFY,
          imageUrl: imageUrl,
          artist: artist));
      }
    }
    return list;
  }
}
