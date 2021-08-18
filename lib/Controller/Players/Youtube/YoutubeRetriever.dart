



import 'dart:developer';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartshuffle/Controller/Players/Youtube/SearchAlgorithm.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeRetriever {

  YoutubeRetriever._singleton();

  static final YoutubeRetriever _instance = YoutubeRetriever._singleton();

  YoutubeExplode _yt = YoutubeExplode();
  AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  factory YoutubeRetriever() {
    return _instance;
  }

  Future<MapEntry<Track, File>> streamByName(Track track) async {
    Track tr = await SearchAlgorithm().search(tArtist: track.artist, tTitle: track.title, tDuration: track.totalDuration.value);
    if(tr.id == null) {
      return MapEntry(tr, null);
    } else {
      return MapEntry(tr, await streamById(tr.id));
    }
  }

  Future<File> streamById(String id) async {

    StreamManifest manifest = await _yt.videos.streamsClient.getManifest(id);
    AudioOnlyStreamInfo streamInfo;
    try {
      streamInfo = manifest.audioOnly.withHighestBitrate();
    } catch(e) {
      return null;
    }

    File file;
    if (streamInfo != null) {
      // Get the actual stream
      var stream = _yt.videos.streamsClient.get(streamInfo);
      
      // Open a file for writing.
      final Directory directory = await getTemporaryDirectory();
      String path = '${directory.path}/$id.mp3';
      print('Path : $path');
      file = File(path);
      var fileStream = file.openWrite();

      // Pipe all the content of the stream into the file.
      try {
        await stream.pipe(fileStream);
      } catch(e) {
        print(e);
        return null;
      }

      // Close the file.
      await fileStream.flush();
      await fileStream.close();
    }
    
    return file;
    
  }

}