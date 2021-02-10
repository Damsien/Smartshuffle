import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/models/Song.dart';

import 'api_path.dart';

import 'package:http/http.dart';
import 'dart:io';
import 'dart:convert';

import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
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
    String token = await APIAuth.login();
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
      String name = items[i]['snippet']['title'];
      list.add(Playlist(id: id, name: name, service: ServicesLister.YOUTUBE));
    }
    return list;
  }

  List<Track> _songsList(Map json) {
    List<Track> list = new List();
    List<dynamic> items = json['items'];
    for (int i = 0; i < items.length; i++) {
      String name = items[i]['snippet']['title'];
      String id = items[i]['id'];
      //* Le format standard d'image est 640x480
      String imageUrl = items[i]['snippet']['thumbnails']['standard']['url'];
      list.add(
          Track(id: id, name: name, service: ServicesLister.YOUTUBE, imageUrl: imageUrl, artist: 'unknow'));
    }
    return list;
  }
}
