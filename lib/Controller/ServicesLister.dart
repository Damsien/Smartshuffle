import 'dart:collection';
import 'dart:math';

import 'package:flutter/widgets.dart';
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
  
  static ValueNotifier<List<Track>> permanentQueue = ValueNotifier<List<Track>>(List<Track>());
  static ValueNotifier<List<Track>> noPermanentQueue = ValueNotifier<List<Track>>(List<Track>());
  static ValueNotifier<List<MapEntry<Track, bool>>> queue = ValueNotifier<List<MapEntry<Track, bool>>>(List<MapEntry<Track, bool>>()); //bool : isPermanent ?
  static int currentQueueIndex = 0;

  static reBuildQueue() {
    queue.value.clear();
    for(Track t in noPermanentQueue.value) {
      queue.value.add(MapEntry(t, false));
    }
    for(Track t in permanentQueue.value.reversed) {
      if(queue.value.isEmpty) queue.value.insert(0, MapEntry(t, true));
      else queue.value.insert(currentQueueIndex+1, MapEntry(t, true));
    }

    noPermanentQueue.value.clear();
    for(MapEntry<Track, bool> me in queue.value) {
      if(!me.value) noPermanentQueue.value.add(me.key);
    }

    queue.notifyListeners();

    /*
    print("==== Queue ====");
    int i=0;
    for(MapEntry me in queue) {
      if(i == currentQueueIndex)
        print(me.key.toString() + " | isPermanent ? " + me.value.toString() + "  *");
      else
        print(me.key.toString() + " | isPermanent ? " + me.value.toString());
      i++;
    }
    print("==== End Q ====");
    */


  }

  static shuffleNoPermanentQueue(Playlist playlist, Track selectedTrack) {
    List<Track> tracks = playlist.getTracks();
    tracks.shuffle();
    if(selectedTrack != null) noPermanentQueue.value.insert(0, selectedTrack);
    for(Track tr in tracks) {
      if(!noPermanentQueue.value.contains(tr))  addToNoPermanentQueue(tr);
    }
    currentQueueIndex = 0;
  }

  static orderedNoPermanentQueue(Playlist playlist, Track selectedTrack) {
    List<Track> tracks = playlist.getTracks();
    for(Track tr in tracks) {
      addToNoPermanentQueue(tr);
    }
    if(selectedTrack != null) {
      currentQueueIndex = tracks.indexOf(selectedTrack);
    } else {
      currentQueueIndex = 0;
    }
  }

  static generateNonPermanentQueue(Playlist playlist, bool isShuflle, {Track selectedTrack}) {
    resetNoPermanentQueue();
    if(isShuflle) shuffleNoPermanentQueue(playlist, selectedTrack);
    else orderedNoPermanentQueue(playlist, selectedTrack);
    reBuildQueue();
  }

  static addToPermanentQueue(Track track) {
    permanentQueue.value.add(track);
    reBuildQueue();
  }

  static insertInPermanentQueue(int index, Track track) {
    permanentQueue.value.insert(index, track);
    reBuildQueue();
  }

  static replaceInPermanentQueue(int index, Track track) {
    if(index >= permanentQueue.value.length) permanentQueue.value.add(track);
    else permanentQueue.value[index] = track;
    reBuildQueue();
  }

  static addToNoPermanentQueue(Track track) {
    noPermanentQueue.value.add(track);
    reBuildQueue();
  }

  static moveFromPermanentToNoPermanent(int index) {
    noPermanentQueue.value.insert(index, permanentQueue.value[0]);
    permanentQueue.value.removeAt(0);
  }

  static resetNoPermanentQueue() {
    noPermanentQueue.value.clear();
    currentQueueIndex = 0;
    //reBuildQueue();
  }

  static resetQueue() {
    permanentQueue.value.clear();
    noPermanentQueue.value.clear();
    queue.value.clear();
  }

  static reorder(int oldIndex, int oldList, int newIndex, int newList) {
    switch(oldList) {
      case 0: {
        switch(newList) {
          case 0: {
            Track track = permanentQueue.value.removeAt(oldIndex);
            permanentQueue.value.insert(newIndex, track);
          } break;
          case 1: {
            Track track = permanentQueue.value.removeAt(oldIndex);
            noPermanentQueue.value.insert(newIndex+currentQueueIndex+1-permanentQueue.value.length, track);
          } break;
        }
      } break;
      case 1: {
        switch(newList) {
          case 0: {
            Track track = noPermanentQueue.value.removeAt(oldIndex+currentQueueIndex+1-permanentQueue.value.length);
            permanentQueue.value.insert(newIndex, track);
          } break;
          case 1: {
            Track track = noPermanentQueue.value.removeAt(oldIndex+currentQueueIndex+1-permanentQueue.value.length);
            noPermanentQueue.value.insert(newIndex+currentQueueIndex+1-permanentQueue.value.length, track);
          } break;
        }
      } break;
    }
    reBuildQueue();
  }

  
  
}
