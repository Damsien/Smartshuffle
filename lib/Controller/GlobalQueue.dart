import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/Players/BackPlayer.dart';
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
    int lastIndex = currentQueueIndex;

    if(value < 0) {
      currentQueueIndex = queue.value.length-1;
    } else if(value >= queue.value.length) {
      currentQueueIndex = 0;
    } else {
      currentQueueIndex = value;
    }

    //Is inevitably next track
    if(queue.value[currentQueueIndex].value) GlobalQueue().moveFromPermanentToNoPermanent(currentQueueIndex);

    // for(int i=lastIndex; i<(currentQueueIndex-lastIndex)+1; i++) {
    //   print('    boucl');
    //   //If is in permanent queue is true
    //   if(queue.value[i].value) {
    //     //Move last track from permanent queue to no permanent queue
    //     // if(value < 0) {
    //     //   GlobalQueue().moveFromPermanentToNoPermanent(queue.value.length-1);
    //     // } else {
    //       GlobalQueue().moveFromPermanentToNoPermanent(i);
    //     // }
    //   }
    // }
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

    
    // print("==== Queue ====");
    // int i=0;
    // for(MapEntry me in queue.value) {
    //   if(i == currentQueueIndex)
    //     print(me.key.toString() + " | isPermanent ? " + me.value.toString() + "  *");
    //   else
    //     print(me.key.toString() + " | isPermanent ? " + me.value.toString());
    //   i++;
    // }
    // print("==== End Q ====");
    
    


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
    
    //Insert into back player queue
    int lastPermanentIndex = 1;
    for(int i=0; i<queue.value.length; i++) {
      if(queue.value[i].value) lastPermanentIndex = i;
    }
    AudioService.customAction('INSERT_ITEM', {
      'index': lastPermanentIndex,
      'track': {
        'id': queue.value[lastPermanentIndex].key.id,
        'name': queue.value[lastPermanentIndex].key.title,
        'artist': queue.value[lastPermanentIndex].key.artist,
        'imagelarge': queue.value[lastPermanentIndex].key.imageUrlLarge,
        'imagelittle': queue.value[lastPermanentIndex].key.imageUrlLittle,
        'service': queue.value[lastPermanentIndex].key.serviceName
      }
    });
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
    print('insert $index');
    noPermanentQueue.value.insert(index, permanentQueue.value[0]);
    permanentQueue.value.removeAt(0);
    reBuildQueue();
  }

  void removeLastPermanent() {
    permanentQueue.value.removeAt(0);
    reBuildQueue();

    //Remove into back player queue
    int lastPermanentIndex = 1;
    for(int i=0; i<queue.value.length; i++) {
      if(queue.value[i].value) lastPermanentIndex = i;
    }
    AudioService.customAction('REMOVE_ITEM', {
      'index': lastPermanentIndex
    });
  }

  void _resetNoPermanentQueue() {
    noPermanentQueue.value.clear();
    // setCurrentQueueIndex(0);
    //reBuildQueue();
  }

  void _resetQueue() {
    permanentQueue.value.clear();
    noPermanentQueue.value.clear();
    queue.value.clear();
  }

  void reorder(int oldIndex, int oldList, int newIndex, int newList) {

    //Back player reorder variables
    int bOldIndex;
    int bOldList = oldList;
    int bNewIndex;
    int bNewList = newList;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldList == 0 && newList == 0 && permanentQueue.value.isEmpty) {
      bOldList = 1;
      bNewList = 1;
    }
          print('============');
          print(oldIndex);
          print(oldList);
          print(newIndex);
          print(newList);
    switch(bOldList) {
      case 0: {
        switch(newList) {
          case 0: {
            Track track = permanentQueue.value.removeAt(oldIndex);
            permanentQueue.value.insert(newIndex, track);
            bOldIndex = oldIndex;
            bNewIndex = newIndex;
          } break;
          case 1: {
            Track track = permanentQueue.value.removeAt(oldIndex);
            noPermanentQueue.value.insert(newIndex+currentQueueIndex+1-permanentQueue.value.length, track);
            bOldIndex = oldIndex;
            bNewIndex = permanentQueue.value.length+newIndex;
          } break;
        }
      } break;
      case 1: {
        switch(bNewList) {
          case 0: {
            Track track = noPermanentQueue.value.removeAt(oldIndex+currentQueueIndex+1-permanentQueue.value.length);
            permanentQueue.value.insert(newIndex, track);
            bOldIndex = permanentQueue.value.length+oldIndex;
            bNewIndex = newIndex;
          } break;
          case 1: {
            Track track = noPermanentQueue.value.removeAt(oldIndex+currentQueueIndex+1-permanentQueue.value.length);
            noPermanentQueue.value.insert(newIndex+currentQueueIndex+1-permanentQueue.value.length, track);
            bOldIndex = permanentQueue.value.length+oldIndex;
            bNewIndex = permanentQueue.value.length+newIndex;
          } break;
        }
      } break;
    }
    reBuildQueue();

    //Back player reorder variables
    AudioService.customAction('REORDER_ITEM', {
      'old_index': bOldIndex,
      'new_index': bNewIndex
    });
  }

  
  
}