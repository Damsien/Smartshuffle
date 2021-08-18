import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart' as YTB;
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';

import 'dart:io';

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
  static final storage = new FlutterSecureStorage();

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

    List<Playlist> list = <Playlist>[];

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

    List<Track> tracks = <Track>[];

    do {
      nextPageToken = response.nextPageToken;
      tracks.addAll(await _songsList(response));
      
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

  Future login({String storeToken}) async {
    if(storeToken == null) {
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
        storage.write(key: 'youtube', value: token);
      }
    } else {
      _isLoggedIn = true;
      _token = storeToken;
    }
  }

  void disconnect() async {
    _isLoggedIn = await APIAuth.logout();
    await storage.delete(key: 'youtube');
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
  Duration _toDuration(String isoString) {
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

  Future<List<Track>> _songsList(YTB.PlaylistItemListResponse songs) async {
    List<Track> list = [];

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
      Duration duration = _toDuration(response.items[0].contentDetails.duration);
      Track track = Track(
          id: id,
          title: name,
          artist: artist,
          imageUrlLittle: imageUrlLittle,
          imageUrlLarge: imageUrlLarge,
          totalDuration: duration,
          service: ServicesLister.YOUTUBE,);

      list.add(track);
    }
    
    return list;
  }
}
