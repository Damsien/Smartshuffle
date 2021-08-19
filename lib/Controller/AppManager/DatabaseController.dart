import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/AppManager/AppInit.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseController {

  DataBaseController._singleton();
  static final DataBaseController _instance = DataBaseController._singleton();

  factory DataBaseController() {
    return _instance;
  }

  static Database _db;
  Batch _batch;
  ValueNotifier<bool> isOperationFinished = ValueNotifier<bool>(false);

  Future<Database> get database async => await _initFrontDatabase();

  Future<Database> get backDatabase async => await _initDatabase();

  Future<bool> databaseExists(String path) =>
    databaseFactory.databaseExists(path);

  Future<Database> _initFrontDatabase() async {
    Database database = await _initDatabase();
    await GlobalAppController.storageInit();
    return database;
  }

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
        try {
          await _batch.commit(noResult: true);
        } catch(e) {}
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
        userinformations_email TEXT,
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
    await db.execute('''
      CREATE TABLE queue(
        track_id TEXT NOT NULL,
        track_service TEXT NOT NULL,
        position INTEGER NOT NULL
      );
    ''');
  }

  Future<void> removePlatform(Platform platform) async {
    await removePlaylistFromPlatform(platform);
    await _db.delete('platform', where: 'name = ?', whereArgs: [platform.name]);
  }

  Future<void> removePlaylistFromPlatform(Platform platform) async {
    for(Playlist playlist in platform.playlists.value) {
      removePlaylist(playlist);
    }
  }

  Future<void> removePlaylist(Playlist playlist) async {
    await _db.delete('playlist', where: 'id = ? AND service = ?', whereArgs: [playlist.id, PlatformsLister.serviceToString(playlist.service)]);
    await _db.delete('link_playlist_track', where: 'playlist_id = ? AND playlist_service = ?', whereArgs: [playlist.id, PlatformsLister.serviceToString(playlist.service)]);
  }

  Future<void> removeLink(Playlist playlist, Track track) async {
    await _db.delete('link_playlist_track',
      where: 'track_id = ? AND track_service = ? AND playlist_id = ? AND playlist_service = ?',
      whereArgs: [track.id, track.serviceName, playlist.id, PlatformsLister.serviceToString(playlist.service)]
    );
  }

  Future<void> resetQueue() async {
    await _db.delete('queue');
  }

  Future<void> removeTrack(Track track) async {
    await _db.delete('track', where: 'trackid = ? AND service = ?', whereArgs: [track.id, track.serviceName]);
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
    await _db.update('playlist', playlist.toMap(), where: 'id = ? AND service = ?', whereArgs: [playlist.id, PlatformsLister.serviceToString(playlist.service)]);
  }

  Future<void> updateQueue(Track track, int position) async {
    Map obj = track.toMap();
    await _db.update('queue', {'track_id': obj['trackid'], 'track_service': obj['service'], 'position': position},
      where: 'posision = ?', whereArgs: [position]
    );
  }

  Future<void> updateTrack(Track track) async {
    await _db.update('track', track.toMap(), where: 'trackid = ? AND service = ?', whereArgs: [track.id, track.serviceName]);
  }

  Future<void> insertPlatform(Platform platform) async {
    await _db.insert('platform', platform.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  void insertPlaylist(Platform platform, Playlist playlist) {
    Map obj = playlist.toMap();
    obj['platform_name'] = platform.name;
    _batch.insert('playlist', obj, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  void insertTrackInQueue(Track track, int position) {
    Map obj = track.toMap();
    _batch.insert('queue', {'track_id': obj['trackid'], 'track_service': obj['service'], 'position': position});
  }

  void insertTrack(Playlist playlist, Track track) {
    _batch.insert('track', track.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    addRelation(playlist, track);
  }

  void addRelation(Playlist playlist, Track track) {
    _batch.insert('link_playlist_track',
      {'track_id': track.id, 'track_service': track.serviceName, 'playlist_id': playlist.id, 'playlist_service': PlatformsLister.serviceToString(playlist.service)},
      conflictAlgorithm: ConflictAlgorithm.ignore
    );
  }

  Future<Map<String, Platform>> getPlatforms() async {
    Map<String, Platform> finalMap = Map<String, Platform>();

    var query = await _db.query('platform');
    for(Map map in query) {
      Platform platform = Platform.fromMap(map);
      finalMap[platform.name] = platform;
    }
    return finalMap;
  }

  Future<List<Playlist>> getPlaylists(Platform platform) async {
    var query = await _db.query('playlist', distinct: true, where: 'platform_name = ?', whereArgs: [platform.name]);
    List<Playlist> playlists = query.isNotEmpty ?
      query.map((e) => Playlist.fromMap(e)).toList() : [];
    return playlists;
  }

  Future<List<Track>> getQueue() async {
    Database db = await DataBaseController().database;
    var query = await db.rawQuery('''
      SELECT DISTINCT track.*
      FROM track
      INNER JOIN queue
      ON track.trackid = queue.track_id AND track.service = queue.track_service;
    ''');
    List<Track> tracks = query.isNotEmpty ?
      query.map((e) => Track.fromMap(e)).toList() : [];
    return tracks;
  }

  Future<List<Track>> getTracks(Playlist playlist) async {
    // var query = await _db.query('link_playlist_track',
    //  where: 'playlist_id = ? AND playlist_service = ?',
    //  whereArgs: [playlist.id, serviceToString(playlist.service)],
    //  columns: ['track_id', 'track_service']
    // );
    // List<List<Map<String, Object>>> objects = List<List<Map<String, Object>>>();
    // for(Map track in query) {
    //   objects.add(
    //   await _db.query('track',
    //     where: 'trackid = ? AND service = ?',
    //     whereArgs: [track['track_id'], track['track_service']]
    //     )
    //   );
    // }
    // final objects = (await batch.commit()).cast<Map>();
    // List<Track> tracks = List<Track>();
    // for(List<Map> e in objects) {
    //   Map<String, dynamic> track = Map<String, dynamic>();
    //   for(MapEntry me in e[0].entries) {
    //     track[me.key] = me.value;
    //   }
    //   track['streamtrack'] = await getTrack(track['streamtrack_id'], track['streamtrack_service']);
    //   tracks.add(Track.fromMap(track));
    // }
    var query = await _db.rawQuery('''
      SELECT DISTINCT track.*
      FROM track
      INNER JOIN link_playlist_track
      ON track.trackid = link_playlist_track.track_id AND track.service = link_playlist_track.track_service
      WHERE
        link_playlist_track.playlist_id = "${playlist.id}" AND link_playlist_track.playlist_service = "${PlatformsLister.serviceToString(playlist.service)}";
    ''');
    List<Track> tracks = query.isNotEmpty ?
      query.map((e) => Track.fromMap(e)).toList() : [];
    return tracks;
  }

  Future<Track> getTrack(String id, String serviceName) async {
    Database db = await DataBaseController().database;
    var query = await db.query('track', where: 'trackid = ? AND service = ?', whereArgs: [id, serviceName], limit: 1);
    List<Track> tracks = query.isNotEmpty ?
      query.map((e) => Track.fromMap(e)).toList() : [];
    return tracks.isNotEmpty ? tracks[0] : null;
  }

}