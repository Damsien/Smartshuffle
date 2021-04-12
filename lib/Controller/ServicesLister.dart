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
  static List<Track> queue = List<Track>();
  static int currentQueueIndex = 0;

  static reBuildQueue() {
    queue.clear();
    for(Track t in permanentQueue) {
      queue.add(t);
    }
    for(Track t in noPermanentQueue) {
      queue.add(t);
    }
  }

  static shuffleNoPermanentQueue(Playlist playlist) {
    List<Track> tracks = playlist.getTracks();
    tracks.shuffle();
    for(Track tr in tracks) {
      if(!queue.contains(tr)) addToNoPermanentQueue(tr);
    }
    currentQueueIndex = 0;
    queue.removeAt(0);
  }

  static orderedNoPermanentQueue(Playlist playlist, Track selectedTrack) {
    List<Track> tracks = playlist.getTracks();
    if(selectedTrack != null) {
      tracks = tracks.sublist(tracks.indexOf(selectedTrack));
    }
    for(Track tr in tracks) {
      if(!queue.contains(tr)) addToNoPermanentQueue(tr);
    }
    currentQueueIndex = 0;
    queue.removeAt(0);
  }

  static generateNonPermanentQueue(Playlist playlist, bool isShuflle, {Track selectedTrack}) {
    resetNoPermanentQueue();
    if(isShuflle) shuffleNoPermanentQueue(playlist);
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

  /*static Track moveToNextTrack(Track selectedTrack) {
    GlobalQueue.currentQueueIndex = GlobalQueue.queue.indexOf(selectedTrack) + 1;
    return GlobalQueue.queue[GlobalQueue.currentQueueIndex];
  }*/

  static resetNoPermanentQueue() {
    noPermanentQueue.clear();
    reBuildQueue();
  }

  static resetQueue() {
    permanentQueue.clear();
    noPermanentQueue.clear();
    queue.clear();
  }

  static reorder(int oldIndex, int newIndex) {
    Track track = queue.removeAt(oldIndex);
    queue.insert(newIndex, track);
  }

  
  
}