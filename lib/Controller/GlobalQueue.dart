import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/Players/Youtube/MainPlayer.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

class GlobalQueue {
  
  // static Track currentTrack;

  static ValueNotifier<List<Track>> permanentQueue = ValueNotifier<List<Track>>(List<Track>());
  static ValueNotifier<List<Track>> noPermanentQueue = ValueNotifier<List<Track>>(List<Track>());
  static ValueNotifier<List<MapEntry<Track, bool>>> queue = ValueNotifier<List<MapEntry<Track, bool>>>(List<MapEntry<Track, bool>>()); //bool : isPermanent ?
  static int currentQueueIndex = 0;

  static final GlobalQueue _globalQueue = GlobalQueue._instance();

  factory GlobalQueue() {
    return _globalQueue;
  }

  GlobalQueue._instance();

  void setCurrentQueueIndex(int value) {
    currentQueueIndex = value;
    QueueManager().indexManager = currentQueueIndex;
  }

  void reBuildQueue() {
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
    for(MapEntry me in queue.value) {
      if(i == currentQueueIndex)
        print(me.key.toString() + " | isPermanent ? " + me.value.toString() + "  *");
      else
        print(me.key.toString() + " | isPermanent ? " + me.value.toString());
      i++;
    }
    print("==== End Q ====");
    */
    


  }

  void _shuffleNoPermanentQueue(Playlist playlist, Track selectedTrack) {
    List<Track> tracks = playlist.getTracks;
    tracks.shuffle();
    if(selectedTrack != null) noPermanentQueue.value.insert(0, selectedTrack);
    for(Track tr in tracks) {
      if(!noPermanentQueue.value.contains(tr))  addToNoPermanentQueue(tr);
    }
    setCurrentQueueIndex(0);
  }

  void _orderedNoPermanentQueue(Playlist playlist, Track selectedTrack) {
    List<Track> tracks = playlist.getTracks;
    for(Track tr in tracks) {
      addToNoPermanentQueue(tr);
    }
    if(selectedTrack != null) setCurrentQueueIndex(tracks.indexOf(selectedTrack));
    else setCurrentQueueIndex(0);
  }

  void generateNonPermanentQueue(Playlist playlist, bool isShuflle, {Track selectedTrack}) {
    _resetNoPermanentQueue();
    if(isShuflle) _shuffleNoPermanentQueue(playlist, selectedTrack);
    else _orderedNoPermanentQueue(playlist, selectedTrack);
    reBuildQueue();
  }

  void addToPermanentQueue(Track track) {
    permanentQueue.value.add(track);
    reBuildQueue();
  }

  void insertInPermanentQueue(int index, Track track) {
    permanentQueue.value.insert(index, track);
    reBuildQueue();
  }

  void replaceInPermanentQueue(int index, Track track) {
    if(index >= permanentQueue.value.length) permanentQueue.value.add(track);
    else permanentQueue.value[index] = track;
    reBuildQueue();
  }

  void addToNoPermanentQueue(Track track) {
    noPermanentQueue.value.add(track);
    reBuildQueue();
  }

  void moveFromPermanentToNoPermanent(int index) {
    noPermanentQueue.value.insert(index, permanentQueue.value[0]);
    permanentQueue.value.removeAt(0);
  }

  void removeLastPermanent() {
    permanentQueue.value.removeAt(0);
    reBuildQueue();
  }

  void _resetNoPermanentQueue() {
    noPermanentQueue.value.clear();
    setCurrentQueueIndex(0);
    //reBuildQueue();
  }

  void _resetQueue() {
    permanentQueue.value.clear();
    noPermanentQueue.value.clear();
    queue.value.clear();
  }

  void reorder(int oldIndex, int oldList, int newIndex, int newList) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
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