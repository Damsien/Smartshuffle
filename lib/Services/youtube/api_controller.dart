import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart' as YTB;
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
  var _httpClient;
  YTB.YouTubeApi _youtubeApi;

  String _token;
  bool _isLoggedIn;
  String _displayName;
  String _email;

  get displayName => _displayName;
  get email => _email;

  factory API() {
    return _instance;
  }

  API._internal();

  get isLoggedIn {
    return _isLoggedIn;
  }

  Future<List<Playlist>> getPlaylistsList() async {
    // Response response =
    //     await get(APIPath.getPlaylistsList(), headers: _prepareHeader());
    // Map json = jsonDecode(response);

    YTB.PlaylistListResponse response = await _youtubeApi.playlists.list(
      ['snippet'],
      maxResults: 50,
      mine: true
    );

    String nextPageToken = response.nextPageToken;

    List<Playlist> list = new List();

    do {
      nextPageToken = response.nextPageToken;
      _playlistList(list, response);

      if (nextPageToken != null) {
        response = await _youtubeApi.playlists.list(
          ['snippet'],
          maxResults: 50,
          mine: true,
          pageToken: nextPageToken
        );
      }
    } while (nextPageToken != null);

    return list;
  }

  Future<List<Track>> getPlaylistSongs(Playlist playlist) async {
    // Response response = await get(APIPath.getPlaylistSongs(playlist),
    //     headers: _prepareHeader());
    // Map json = jsonDecode(response.body);

    YTB.PlaylistItemListResponse response = await _youtubeApi.playlistItems.list(
      ['snippet'],
      playlistId: playlist.id,
      maxResults: 50
    );

    String nextPageToken = response.nextPageToken;

    List<Track> tracks = new List();

    do {
      nextPageToken = response.nextPageToken;
      _songsList(tracks, response);

      if (nextPageToken != null) {
        response = await _youtubeApi.playlistItems.list(
          ['snippet'],
          playlistId: playlist.id,
          maxResults: 50,
          pageToken: nextPageToken
        );
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
    Map<dynamic, GoogleSignInAccount> infos = await APIAuth.login();
    _httpClient = infos.entries.first.key;
    _youtubeApi = YTB.YouTubeApi(_httpClient);
    String token;
    GoogleSignInAccount user = infos.entries.first.value;
    _displayName = user.displayName;
    _email = user.email;
    if (user == null) {
      _isLoggedIn = false;
    } else {
      _isLoggedIn = true;
      _token = token;
    }
  }

  void disconnect() async {
    _isLoggedIn = await APIAuth.logout();
  }

  void _playlistList(List<Playlist> list, YTB.PlaylistListResponse playlists) {
    List<YTB.Playlist> items = playlists.items;
    for (int i = 0; i < items.length; i++) {
      String id = items[i].id;
      String name = items[i].snippet.title;
      String ownerId = items[i].snippet.channelId;
      String ownerName = items[i].snippet.channelTitle;
      //*Correspond à au format minimal 120x90
      String imageUrl = items[i].snippet.thumbnails.standard.url;

      list.add(Playlist(
          id: id,
          name: name,
          uri: Uri.parse("youtube.com/playlist?list=$id"),
          ownerId: ownerId,
          ownerName: ownerName,
          imageUrl: imageUrl,
          service: ServicesLister.YOUTUBE));
    }
  }

  int _parseTime(String duration, String timeUnit) {
    final timeMatch = RegExp(r"\d+" + timeUnit).firstMatch(duration);

    if (timeMatch == null) {
      return 0;
    }
    final timeString = timeMatch.group(0);
    return int.parse(timeString.substring(0, timeString.length - 1));
  }
  Duration toDuration(String isoString) {
  if (!RegExp(
          r"^(-|\+)?P(?:([-+]?[0-9,.]*)Y)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)W)?(?:([-+]?[0-9,.]*)D)?(?:T(?:([-+]?[0-9,.]*)H)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)S)?)?$")
      .hasMatch(isoString)) {
    throw ArgumentError("String does not follow correct format");
  }

  final weeks = _parseTime(isoString, "W");
  final days = _parseTime(isoString, "D");
  final hours = _parseTime(isoString, "H");
  final minutes = _parseTime(isoString, "M");
  final seconds = _parseTime(isoString, "S");

  return Duration(
    days: days + (weeks * 7),
    hours: hours,
    minutes: minutes,
    seconds: seconds,
  );
}

  void _songsList(List<Track> list, YTB.PlaylistItemListResponse songs) async {
    List<YTB.PlaylistItem> items = songs.items;
    for (int i = 0; i < items.length; i++) {
      String name = items[i].snippet.title;
      String artist = items[i].snippet.videoOwnerChannelTitle;
      if(artist.contains(' - Topic')) artist = artist.split(' - Topic')[0];

      String id = items[i].snippet.resourceId.videoId;
      String imageUrlLittle = items[i].snippet.thumbnails.high.url;
      String imageUrlLarge;
      try {
        imageUrlLarge = items[i].snippet.thumbnails.maxres.url;
      } catch(e) {
        imageUrlLarge = 'https://source.unsplash.com/random';
      }

      YTB.VideoListResponse response = await _youtubeApi.videos.list(
        ['contentDetails'],
        id: [id]
      );
      Duration duration = toDuration(response.items[0].contentDetails.duration);

      list.add(Track(
          id: id,
          name: name,
          artist: artist,
          imageUrlLittle: imageUrlLittle,
          imageUrlLarge: imageUrlLarge,
          totalDuration: duration,
          service: ServicesLister.YOUTUBE,));
    }
  }
}
