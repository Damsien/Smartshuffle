import 'dart:collection';
import 'dart:math';

import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformSpotifyController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformYoutubeController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';


enum ServicesLister {
  DEFAULT,
  SPOTIFY,
  YOUTUBE
}

class PlatformsLister {

  static LinkedHashMap platforms = 
  {
    ServicesLister.DEFAULT: new PlatformDefaultController(Platform("SmartShuffle")),
    ServicesLister.SPOTIFY: new PlatformSpotifyController(Platform("Spotify", platformInformations: {'package': 'com.spotify.music'})),
    ServicesLister.YOUTUBE: new PlatformYoutubeController(Platform("Youtube", platformInformations: {'package': 'com.google.android.youtube'}))
  } as LinkedHashMap;

}

class GlobalQueue {
  
  static List<Track> permanentQueue = List<Track>();
  static List<Track> noPermanentQueue = List<Track>();
  static List<MapEntry<Track, bool>> queue = List<MapEntry<Track, bool>>(); //bool : isPermanent ?
  static int currentQueueIndex = 0;

  static reBuildQueue() {
    queue.clear();
    for(Track t in noPermanentQueue) {
      queue.add(MapEntry(t, false));
    }
    for(Track t in permanentQueue.reversed) {
      queue.insert(currentQueueIndex+1, MapEntry(t, true));
    }

    /*print("=======");
    int i=0;
    for(MapEntry me in queue) {
      if(i == currentQueueIndex+1)
        print(me.key.toString() + "  *");
      else
        print(me.key);
      i++;
    }*/

  }

  static shuffleNoPermanentQueue(Playlist playlist, Track selectedTrack) {
    List<Track> tracks = playlist.getTracks();
    tracks.shuffle();
    if(selectedTrack != null) noPermanentQueue.insert(0, selectedTrack);
    for(Track tr in tracks) {
      if(!noPermanentQueue.contains(tr))  addToNoPermanentQueue(tr);
    }
    currentQueueIndex = 0;
  }

  static orderedNoPermanentQueue(Playlist playlist, Track selectedTrack) {
    List<Track> tracks = playlist.getTracks();
    if(selectedTrack != null) {
      currentQueueIndex = tracks.indexOf(selectedTrack);
    } else {
      currentQueueIndex = 0;
    }
    for(Track tr in tracks) {
      addToNoPermanentQueue(tr);
    }
  }

  static generateNonPermanentQueue(Playlist playlist, bool isShuflle, {Track selectedTrack}) {
    resetNoPermanentQueue();
    if(isShuflle) shuffleNoPermanentQueue(playlist, selectedTrack);
    else orderedNoPermanentQueue(playlist, selectedTrack);
    reBuildQueue();
  }

  static addToPermanentQueue(Track track) {
    permanentQueue.add(track);
    reBuildQueue();
  }

  static insertInPermanentQueue(int index, Track track) {
    permanentQueue.insert(index, track);
    reBuildQueue();
  }

  static replaceInPermanentQueue(int index, Track track) {
    if(index >= permanentQueue.length) permanentQueue.add(track);
    else permanentQueue[index] = track;
    reBuildQueue();
  }

  static addToNoPermanentQueue(Track track) {
    noPermanentQueue.add(track);
    reBuildQueue();
  }

  static moveFromPermanentToNoPermanent(int index) {
    print(permanentQueue[0]);
    noPermanentQueue.insert(index, permanentQueue[0]);
    permanentQueue.removeAt(0);
  }

  static resetNoPermanentQueue() {
    noPermanentQueue.clear();
    currentQueueIndex = 0;
    //reBuildQueue();
  }

  static resetQueue() {
    permanentQueue.clear();
    noPermanentQueue.clear();
    queue.clear();
  }

  static reorder(int oldIndex, int newIndex) {
    MapEntry<Track, bool> track = queue.removeAt(oldIndex);
    queue.insert(newIndex, track);
  }

  
  
}
