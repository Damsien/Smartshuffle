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

  FutureOr<List<Playlist>> getPlaylists({bool refreshing}) async {
    if(refreshing == null || !refreshing) {
      if(await DataBaseController().databaseExists('smartshuffle.db')) {
        platform.setPlaylist(await DataBaseController().getPlaylists(platform), isNew: false);
        for(Playlist play in platform.playlists.value) {
          play.setTracks(await DataBaseController().getTracks(play), isNew: false);
        }
        return platform.playlists.value;
      }
    }
  }

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

  static Database _db;
  Batch _batch;
  ValueNotifier<bool> isOperationFinished = ValueNotifier<bool>(false);

  Future<Database> get database async => await _initDatabase();

  Future<bool> databaseExists(String path) =>
    databaseFactory.databaseExists(path);

  Future<Database> _initDatabase() async {
    String documentsDirectory = await getDatabasesPath();
    String path = documentsDirectory + 'smartshuffle.db';
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpdate,
      onDowngrade: _onUpdate,
      onConfigure: _onConfigure,
    );
    _batch = _db.batch();

    isOperationFinished.addListener(() async {
      if(isOperationFinished.value == true) {
        await _batch.commit(noResult: true);
        isOperationFinished.value = false;
      }
    });

    return _db;
  }

  _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  _onUpdate(Database db, int previousVersion, int currentVersion) {
    _onCreate(db, currentVersion);
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE platform(
        name TEXT NOT NULL PRIMARY KEY,
        userinformations_name TEXT,
        userinformations_account TEXT,
        userinformations_isconnected INTEGER,
        platformInformations_logo TEXT,
        platformInformations_icon TEXT,
        platformInformations_maincolor TEXT,
        platformInformations_package TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE playlist(
        id TEXT NOT NULL,
        service TEXT NOT NULL,
        platform_name TEXT,
        ordersort INTEGER,
        name TEXT,
        ownerid TEXT,
        ownername TEXT,
        imageurl TEXT,
        uri STRING,
        FOREIGN KEY(platform_name) REFERENCES platform(name),
        PRIMARY KEY(id, service)
      );
    ''');
    await db.execute('''
      CREATE TABLE link_playlist_track(
        track_id TEXT,
        track_service TEXT,
        playlist_id TEXT,
        playlist_service TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE track(
        trackid TEXT NOT NULL,
        service TEXT NOT NULL,
        title TEXT,
        artist TEXT,
        album TEXT,
        imageurllittle TEXT,
        imageurllarge TEXT,
        duration TEXT,
        adddate TEXT,
        streamtrack_id TEXT,
        streamtrack_service TEXT,
        PRIMARY KEY(trackid, service)
      );
    ''');
  }

  Future<void> removePlatform(Platform platform) async {
    await _db.delete('platform', where: 'name = ?', whereArgs: [platform.name]);
  }

  Future<void> removePlaylist(Playlist playlist) async {
    await _db.delete('playlist', where: 'id = ? AND service = ?', whereArgs: [playlist.id, serviceToString(playlist.service)]);
    await _db.delete('link_playlist_track', where: 'playlist_id = ? AND playlist_service = ?', whereArgs: [playlist.id, serviceToString(playlist.service)]);
  }

  Future<void> removeLink(Playlist playlist, Track track) async {
    await _db.delete('link_playlist_track',
      where: 'track_id = ? AND track_service = ? AND playlist_id = ? AND playlist_service = ?',
      whereArgs: [track.id, track.serviceName, playlist.id, serviceToString(playlist.service)]
    );
  }

  Future<void> removeTrack(Track track) async {
    await _db.delete('track', where: 'id = ? AND service = ?', whereArgs: [track.id, track.serviceName]);
    await _db.delete('link_playlist_track', where: 'track_id = ? AND track_service = ?', whereArgs: [track.id, track.serviceName]);
  }

  Future<void> updatePlatform(Platform platform) async {
    await _db.update('platform', platform.toMap(), where: 'name = ?', whereArgs: [platform.name]);
  }

  Future<void> updatePlaylistOrder(Platform platform) async {
    List<Playlist> playlists = await getPlaylists(platform);
    await _db.delete('playlist', where: 'platform_name = ?', whereArgs: [platform.name]);
    for(Playlist playlist in playlists) {
      await _db.insert('playlist', playlist.toMap());
    }
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await _db.update('playlist', playlist.toMap(), where: 'id = ? AND service = ?', whereArgs: [playlist.id, serviceToString(playlist.service)]);
  }

  Future<void> updateTrack(Track track) async {
    await _db.update('track', track.toMap(), where: 'id = ? AND service = ?', whereArgs: [track.id, track.serviceName]);
  }

  Future<void> insertPlatform(Platform platform) async {
    Database db = await DataBaseController().database;
    await db.insert('platform', platform.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  void insertPlaylist(Platform platform, Playlist playlist) {
    Map obj = playlist.toMap();
    obj['platform_name'] = platform.name;
    _batch.insert('playlist', obj, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  void insertTrack(Playlist playlist, Track track) {
    _batch.insert('track', track.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    _batch.insert('link_playlist_track',
      {'track_id': track.id, 'track_service': track.serviceName, 'playlist_id': playlist.id, 'playlist_service': serviceToString(playlist.service)},
      conflictAlgorithm: ConflictAlgorithm.ignore
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
    return tracks[0] ?? null;
  }

}