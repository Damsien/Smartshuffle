import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Players/BackPlayer.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/ProfileView.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sqflite/sqflite.dart';

import 'package:protobuf/protobuf.dart';


abstract class PlatformsController {
  Map<String, State> states = new Map<String, State>();
  Map<String, Track> allTracks = Map<String, Track>();
  Platform platform;

  PlatformsController(Platform platform) {
    this.platform = platform;
    DataBaseController().insertPlatform(platform);
    this.updateInformations();
  }

  /*  STATE MANAGER */

  setPlaylistsPageState(State state) {
    states['PlaylistsPage'] = state;
  }

  setSearchPageState(State state) {
    states['SearchPage'] = state;
  }

  setProfilePageState(State state) {
    states['ProfilePage'] = state;
  }

  void updateState(String stringState) {
    State<dynamic> state = states[stringState];
    state.setState(() {
      state.widget.createState().key = UniqueKey();
    });
  }

  void updateStates() {
    for (MapEntry state in states.entries) {
      state.value.setState(() {
        state.value.widget.createState().key = UniqueKey();
      });
    }
  }

  updateInformations();

  /*  VIEWS   */

  Widget getView({@required ServicesLister service, @required ProfileViewType view, Map parameters}) {
    return ProfileView.getView(service: service, view: view, parameters: parameters);
  }

  /*  INFORMATIONS  */

  getPlatformInformations();

  getUserInformations();

  Future<List<Playlist>> getPlaylists({bool refreshing});

  Future<List<Track>> getTracks(Playlist playlist);

  Map<String, Track> getAllPlatformTracks() {
    Map<String, Track> allTracks = Map<String, Track>();
    for(Playlist playlist in platform.playlists.value) {
      for(Track track in playlist.getTracks) {
        allTracks[track.id] = track;
      }
    }
    return this.allTracks = allTracks;
  }

  ValueNotifier<List<Playlist>> getPlaylistsUpdate();

  /*  CONNECTION    */

  connect();

  disconnect();

  /*  USER'S SERVICES */

  //Add the track to the app's playlist
  String addTrackToPlaylist(int playlistIndex, Track track, bool force) {
    return this.platform.addTrackToPlaylistByIndex(playlistIndex, track, force);
  }

  //Remove the track from the app's playlist
  Track removeTrackFromPlaylist(int playlistIndex, int trackIndex) {
    return this
        .platform
        .removeTrackFromPlaylistByIndex(playlistIndex, trackIndex);
  }

  //Add the track to the app's playlist
  Playlist addPlaylist(
      {Playlist playlist,
      String name,
      String ownerId,
      String ownerName,
      String imageUrl,
      String playlistUri,
      List<MapEntry<Track, DateTime>> tracks});
  //Remove the track from the app's playlist
  Playlist removePlaylist(int playlistIndex);

  Playlist mergePlaylist(Playlist toMergeTo, Playlist toMerge);

  void renamePlaylist(Playlist playlist, String name);


  /*  MEDIA PLAYER CONTROLS  */

  resume(File file) {
    AudioService.play();
  }

  pause() {
    AudioService.pause();
  }


  seekTo(Duration position) {
    AudioService.seekTo(position);
  }

  /*  STREAM  */

  Future<MapEntry<Track, File>> getFile(Track tr);

}



class DataBaseController {

  DataBaseController._singleton();
  static final DataBaseController _instance = DataBaseController._singleton();

  factory DataBaseController() {
    return _instance;
  }

  static Database _dataBase;
  Future<Database> get database async => await _initDatabase();

  Future<Database> _initDatabase() async {
    String documentsDirectory = await getDatabasesPath();
    String path = documentsDirectory + 'smartshuffle.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate(_dataBase, 1),
      onConfigure: _onConfigure(_dataBase),
    );
  }

  _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE platform(
        name TEXT PRIMARY KEY,
        userinformations_name TEXT,
        userinformations_account TEXT,
        userinformations_isconnected INTEGER,
        platformInformations_logo TEXT,
        platformInformations_icon TEXT,
        platformInformations_maincolor TEXT,
        platformInformations_package TEXT
      );
      CREATE TABLE playlist(
        id TEXT PRIMARY KEY,
        service TEXT PRIMARY KEY,
        platform_name TEXT,
        FOREIGN KEY(platform_name) REFERENCES platform(name),
        name TEXT,
        ownerid TEXT,
        ownername TEXT,
        imageurl TEXT,
        uri STRING
      );
      CREATE TABLE link_playlist_track(
        track_id TEXT,
        track_service TEXT,
        playlist_id TEXT KEY,
        playlist_service TEXT KEY,
        FOREIGN KEY(track_id) REFERENCES track(id),
        FOREIGN KEY(track_service) REFERENCES track(service),
        FOREIGN KEY(playlist_id) REFERENCES playlist(id),
        FOREIGN KEY(playlist_service) REFERENCES playlist(service)
      );
      CREATE TABLE track(
        id TEXT PRIMARY KEY,
        service TEXT PRIMARY KEY,
        playlist_id TEXT,
        playlist_service TEXT,
        FOREIGN KEY(playlist_id) REFERENCES playlist(id),
        FOREIGN KEY(playlist_service) REFERENCES playlist(service),
        title TEXT,
        artist TEXT,
        album TEXT,
        imageurllittle TEXT,
        imageurllarge TEXT,
        duration TEXT,
        adddate DATETIME,
        streamtrack_id TEXT,
        streamtrack_service TEXT,
        FOREIGN KEY(streamtrack_id) REFERENCES track(id),
        FOREIGN KEY(streamtrack_service) REFERENCES track(service)
      );
    ''');
  }

  Future<void> removePlatform(Platform platform) async {
    Database db = await DataBaseController().database;
    await db.delete('platform', where: 'name = ?', whereArgs: [platform.name]);
  }

  Future<void> removePlaylist(Playlist playlist) async {
    Database db = await DataBaseController().database;
    await db.delete('playlist', where: 'id = ? AND service = ?', whereArgs: [playlist.id, serviceToString(playlist.service)]);
    await db.delete('link_playlist_track', where: 'playlist_id = ? AND playlist_service = ?', whereArgs: [playlist.id, serviceToString(playlist.service)]);
  }

  Future<void> removeTrack(Track track) async {
    Database db = await DataBaseController().database;
    await db.delete('track', where: 'id = ? AND service = ?', whereArgs: [track.id, track.serviceName]);
    await db.delete('link_playlist_track', where: 'track_id = ? AND track_service = ?', whereArgs: [track.id, track.serviceName]);
  }

  Future<void> updatePlatform(Platform platform) async {
    Database db = await DataBaseController().database;
    await db.update('platform', platform.toMap(), where: 'name = ?', whereArgs: [platform.name]);
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    Database db = await DataBaseController().database;
    await db.update('playlist', playlist.toMap(), where: 'id = ? AND service = ?', whereArgs: [playlist.id, serviceToString(playlist.service)]);
  }

  Future<void> updateTrack(Track track) async {
    Database db = await DataBaseController().database;
    await db.update('track', track.toMap(), where: 'id = ? AND service = ?', whereArgs: [track.id, track.serviceName]);
  }

  Future<void> insertPlatform(Platform platform) async {
    Database db = await DataBaseController().database;
    await db.insert('platform', platform.toMap());
  }

  Future<void> insertPlaylist(Platform platform, Playlist playlist) async {
    Database db = await DataBaseController().database;
    Map obj = playlist.toMap();
    obj['platform_name'] = platform.name;
    await db.insert('playlist', obj);
  }

  Future<void> insertTrack(Playlist playlist, Track track) async {
    Database db = await DataBaseController().database;
    await db.insert('track', track.toMap());
    await db.insert('link_playlist_track',
      {'track_id': track.id, 'track_service': track.serviceName, 'playlist_id': playlist.id, 'playlist_service': serviceToString(playlist.service)}
    );
  }

  Future<List<Platform>> getPlatforms() async {
    Database db = await DataBaseController().database;
    var query = await db.query('platform');
    List<Platform> platforms = query.isNotEmpty ?
      query.map((e) => Platform.fromMap(e)).toList() : [];
    return platforms;
  }

  Future<List<Playlist>> getPlaylists(Platform platform) async {
    Database db = await DataBaseController().database;
    var query = await db.query('playlist', where: 'platform_name = ?', whereArgs: [platform.name]);
    List<Playlist> playlists = query.isNotEmpty ?
      query.map((e) => Playlist.fromMap(e)).toList() : [];
    return playlists;
  }

  Future<List<Track>> getTracks(Playlist playlist) async {
    Database db = await DataBaseController().database;
    var query = await db.rawQuery('''
      SELECT *
      FROM track T, link_playlist_track L
      WHERE
        T.id = L.track_id AND T.service = L.track_service AND
        L.playlist_id = ${playlist.id} AND L.playlist_service = ${serviceToString(playlist.service)}
    ''');
    List<Track> tracks = query.isNotEmpty ?
      query.map((e) async {
        e['streamtrack'] = await getTrack(e['streamtrack_id'], e['streamtrack_service']);
        Track.fromMap(e);
      }).toList() : [];
    return tracks;
  }

  Future<Track> getTrack(String id, String serviceName) async {
    Database db = await DataBaseController().database;
    var query = await db.query('track', where: 'id = ? AND service = ?', whereArgs: [id, serviceName], limit: 1);
    List<Track> tracks = query.isNotEmpty ?
      query.map((e) => Track.fromMap(e)).toList() : [];
    return tracks[0];
  }

}