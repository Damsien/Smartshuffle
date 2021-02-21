import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';

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

    String nextPageToken = json['nextPageToken'];

    List<Playlist> list = new List();

    do {
      nextPageToken = json['nextPageToken'];
      _playlistList(list, json);

      if (nextPageToken != null) {
        response = await get(
            APIPath.getPlaylistsList() + "&pageToken=" + nextPageToken,
            headers: _prepareHeader());
        json = jsonDecode(response.body);
      }
    } while (nextPageToken != null);

    return list;
  }

  Future<List<Track>> getPlaylistSongs(Playlist playlist) async {
    Response response = await get(APIPath.getPlaylistSongs(playlist),
        headers: _prepareHeader());
    Map json = jsonDecode(response.body);

    String nextPageToken = json['nextPageToken'];

    List<Track> tracks = new List();

    do {
      nextPageToken = json['nextPageToken'];
      _songsList(tracks, json);

      if (nextPageToken != null) {
        response = await get(
            APIPath.getPlaylistSongs(playlist) + "&pageToken=" + nextPageToken,
            headers: _prepareHeader());
        json = jsonDecode(response.body);
      }
    } while (nextPageToken != null);

    return tracks;
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

  void _playlistList(List<Playlist> list, Map json) {
    List<dynamic> items = json['items'];
    for (int i = 0; i < items.length; i++) {
      String id = items[i]['id'];
      String name = items[i]['snippet']['title'];
      String ownerId = items[i]['snippet']['channelId'];
      String ownerName = items[i]['channelTitle'];
      //*Correspond à au format minimal 120x90
      String imageUrl = items[i]['snippet']['thumbnails']['default']['url'];

      list.add(Playlist(
          id: id,
          name: name,
          service: ServicesLister.YOUTUBE,
          ownerId: ownerId,
          ownerName: ownerName,
          imageUrl: imageUrl));
    }
  }

  void _songsList(List<Track> list, Map json) {
    List<dynamic> items = json['items'];
    for (int i = 0; i < items.length; i++) {
      String name = items[i]['snippet']['title'];
      String id = items[i]['id'];
      String imageUrl = items[i]['snippet']['thumbnails']['default']['url'];
      list.add(Track(
          id: id,
          name: name,
          service: ServicesLister.YOUTUBE,
          imageUrl: imageUrl,
          artist: 'unknow'));
    }
  }
}
