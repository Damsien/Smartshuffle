import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/BackPlayer.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Model/Object/UsefullWidget/page_controller.dart';

void _entrypoint() => AudioServiceBackground.run(() => AudioPlayerTask());
class FrontPlayerController {

  FrontPlayerController._singleton();
  factory FrontPlayerController() {
    return _instance;
  }

  static final FrontPlayerController _instance = FrontPlayerController._singleton();


  //Objects
  Playlist currentPlaylist = Playlist(
    ownerId: '',
    service: null,
    id: null,
    name: ''
  );
  ValueNotifier<Track> currentTrack = ValueNotifier<Track>(Track(
    service: ServicesLister.DEFAULT,
    artist: '',
    name: '',
    id: null,
    imageUrlLittle: '',
    imageUrlLarge: '',)
  );


  // Controllers
  CustomPageController pageCtrl = CustomPageController(keepPage: false);


  // Misc
  bool isShuffle = true;
  bool isRepeatOnce = false;
  bool isRepeatAlways = false;

  State viewState;

  double botBarHeight;
  final double bot_bar_height = 56;


  // PUBLIC

  void onInitPage() {
    _initPageController();
    GlobalQueue.queue.value.add(MapEntry(currentTrack.value, false));
  }

  void onBuildPage({State view}) {
    if(view != null) {
      setView(view);
    }
  }

  void setView(State view) {
    viewState = view;
  }

  /* ============================================ */

  /// Create queue depending of [playlist], [isShuffle] and potentially [track] and set up all the tabs
  void createQueueAndPlay(Playlist playlist, {
    bool isShuffle,
    Track track
  }) {
    if(isShuffle == null) {
      isShuffle = this.isShuffle;
    }

    //Init queue
    _createQueue(playlist, isShuffle: isShuffle, track: track);

    //Play track
    if (track != null) {

      _playTrack(track);
      if(pageCtrl.hasClients) {
        if(isShuffle) {
          pageCtrl.jumpToPage(0);
        } else {
          pageCtrl.jumpToPage(GlobalQueue.currentQueueIndex);
        }
      }

    } else {

      _playTrack(GlobalQueue.queue.value[0].key);
      if(pageCtrl.hasClients) {
        pageCtrl.jumpToPage(0);
      }

    }

    _loadBackQueue(GlobalQueue.queue.value);
  }


  /// Skip page and current track to play next track and change audio source if isn't [backProvider]
  void nextTrack({@required bool backProvider}) {
    Track nextTrack;

    isRepeatOnce = false;
    isRepeatAlways = false;

    //Update index of queue
    GlobalQueue().setCurrentQueueIndex(GlobalQueue.currentQueueIndex+1);
    //Get the next track
    nextTrack = GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key;
    //Move to the next page
    pageCtrl.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn).then((value) {
      _playTrack(nextTrack);
    });

    if(!backProvider) {
      AudioService.skipToNext();
    }
  }

  /// Skip page and current track to play previous track and change audio source if isn't [backProvider]
  void previousTrack({@required bool backProvider}) {
    Track previousTrack;

    isRepeatOnce = false;
    isRepeatAlways = false;

    //Update index of queue
    GlobalQueue().setCurrentQueueIndex(GlobalQueue.currentQueueIndex-1);
    //Get the previous track
    previousTrack = GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key;
    //Move to the previous page
    pageCtrl.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn).then((value) {
      _playTrack(previousTrack);
    });

    if(!backProvider) {
      AudioService.skipToPrevious();
    }
  }

  /// Set [isRepeatOnce] and [isRepeatAlways]
  /// Test the difference between the current isShuffle and the [isShuffle] state to regenerate queue if needed
  void setPlayType({bool isShuffle, bool isRepeatOnce, bool isRepeatAlways}) {
    if(isRepeatOnce != null) this.isRepeatOnce = isRepeatOnce;
    if(isRepeatAlways != null) this.isRepeatAlways = isRepeatAlways;

    if(isShuffle != null && isShuffle != this.isShuffle) {
      _createQueue(currentPlaylist, isShuffle: isShuffle, track: currentTrack.value);
      pageCtrl.jumpToPage(0);
    }
  }



  // PRIVATE

  /// Set the current track to [track] and initialize back player listener for it
  void _playTrack(Track track) {
    _seekAllTrackToZero();
    currentTrack.value = track;
    
    //Listen to track changes in the notification back player
    viewState.setState(() {
      PlayerListener().listen(track);
    });
  }

  /// Transfer current [frontQueue] to the back player notification
  Future<void> _loadBackQueue(frontQueue) async {
    if(!AudioService.connected) {
      await AudioService.connect();
    }

    Map<String, List<String>> queue = Map<String, List<String>>();
    queue['name'] = List<String>();
    queue['artist'] = List<String>();
    queue['image'] = List<String>();
    queue['id'] = List<String>();
    queue['service'] = List<String>();
    queue['duration'] = List<String>();
    for(MapEntry<Track, bool> me in frontQueue) {
      queue['name'].add(me.key.name);
      queue['artist'].add(me.key.artist);
      queue['image'].add(me.key.imageUrlLarge);
      queue['id'].add(me.key.id);
      queue['service'].add(me.key.serviceName);
      queue['duration'].add(me.key.totalDuration.value.toString());
    }

    await AudioService.start(
      backgroundTaskEntrypoint: _entrypoint
    );
    await AudioService.customAction('LAUNCH_QUEUE', {'queue': queue});
  }

  /// Create queue depending of [playlist] selected
  /// Queue generation depends of [isShuffle] parameter to have an ordered list or not
  /// Can depends of [track] if start with a specific track is wanted
  void _createQueue(Playlist playlist, {
    @required bool isShuffle,
    Track track
  }) {
    currentPlaylist = playlist;

    this.isShuffle = isShuffle;

    if (track != null) {

      if(isShuffle) {
        GlobalQueue().generateNonPermanentQueue(playlist, true, selectedTrack: track);
      } else {
        GlobalQueue().generateNonPermanentQueue(playlist, false, selectedTrack: track);
      }

    } else {

      if(isShuffle) {
        GlobalQueue().generateNonPermanentQueue(playlist, true);
      } else {
        GlobalQueue().generateNonPermanentQueue(playlist, false);
      }

    }
  }

  /// Initialize player's tracks in multible tabs form on the frontend side of the app
  void _initPageController() {
    //Listeners
    pageCtrl.addListener(() {
      if(!pageCtrl.blockNotifier) {

        if(pageCtrl.page.round() > GlobalQueue.currentQueueIndex) {
          //Next page
          nextTrack(backProvider: false);
        } else if(pageCtrl.page.round() < GlobalQueue.currentQueueIndex) {
          //Previous page
          previousTrack(backProvider: false);
        }

      }
    });
  }

  /// Reset all tracks position to set to 0
  void _seekAllTrackToZero() {
    for(MapEntry me in GlobalQueue.queue.value) {
      Track tr = me.key;
      tr.seekTo(Duration.zero, false);
    }
  }

}