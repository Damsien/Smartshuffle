import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smartshuffle/Controller/DatabaseController.dart';
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

  static const String SCREEN_VISIBLE = "screen_visible";
  static const String SCREEN_IDLE = "screen_idle";

  ValueNotifier<String> screenState = ValueNotifier<String>(SCREEN_VISIBLE);

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
    title: '',
    id: null,
    imageUrlLittle: '',
    imageUrlLarge: '',)
  );
  FlutterSecureStorage _storage = FlutterSecureStorage();


  // Controllers
  CustomPageController pageCtrl = CustomPageController(keepPage: false);
  // PanelController panelCtrl = PanelController();

  // Misc
  bool isShuffle = true;
  bool isRepeatOnce = false;
  bool isRepeatAlways = false;

  Map<String, State> views = Map<String, State>();
  bool isPlayerReady = false;

  double botBarHeight;
  final double bot_bar_height = 56;

  int backIndex = 0;


  // PUBLIC

  void onInitPage() {
    _initPageController();
    _screenStateListener();

    // Init queue
    _storage.read(key: 'current_queue_index').then((value) => _initQueue(int.parse(value)));

    // Fake track to avoid panel controller error on first app runtime
    GlobalQueue.queue.value.add(MapEntry(currentTrack.value, false));
  }

  void onBuildPage({State view}) {
    if(view != null) {
      addView('player' ,view);
    }
  }

  void addView(String name, State view) {
    views['player'] = view;
  }

  /* ============================================ */

  /// Create queue depending of [playlist], [isShuffle] and potentially [track] and set up all the tabs
  Future<void> createQueueAndPlay(Playlist playlist, {
    bool isShuffle,
    Track track
  }) async {

    if(track.id != currentTrack.value.id) {

      if(isShuffle == null) {
        isShuffle = this.isShuffle;
      }

      //Init queue
      await _createQueue(playlist, isShuffle: isShuffle, track: track);

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

    } else {

      currentTrack.value.setIsSelected(true);

    }

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
    pageCtrl.jumpToPage(GlobalQueue.currentQueueIndex);

    _playTrack(nextTrack);

    if(!backProvider) {
      AudioService.customAction('SKIP_NEXT');
    }
  }

  /// Skip page and current track to play previous track and change audio source if isn't [backProvider]
  /// Seek position to zero if the current position is less or equal than 2 seconds and is [isSeekToZero]
  void previousTrack({@required bool backProvider, @required bool isSeekToZero}) {

    if(isSeekToZero && currentTrack.value.currentDuration.value.inSeconds > 2) {

      currentTrack.value.seekTo(Duration.zero, true);

    } else {

      Track previousTrack;

      isRepeatOnce = false;
      isRepeatAlways = false;

      //Update index of queue
      GlobalQueue().setCurrentQueueIndex(GlobalQueue.currentQueueIndex-1);
      //Get the previous track
      previousTrack = GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key;
      //Move to the previous page
      pageCtrl.jumpToPage(GlobalQueue.currentQueueIndex);

      _playTrack(previousTrack);

      if(!backProvider) {
        AudioService.customAction('SKIP_PREVIOUS');
      }

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

  void _initQueue(int index) async {
    List<Track> tracks = await DataBaseController().getQueue();

    if(tracks.length != 0) {
      GlobalQueue.queue.value.removeAt(0);
      GlobalQueue.noPermanentQueue.value = tracks;
      for(Track track in tracks) {
        GlobalQueue.queue.value.add(MapEntry(track, false));
      }
      GlobalQueue.currentQueueIndex = index;

      Track track = GlobalQueue.queue.value[index].key;
      _playTrack(track);
      currentTrack.value = track;

      await _loadBackQueue(GlobalQueue.queue.value);

      AudioService.pause();
    }
  }

  /// Set the current track to [track] and initialize back player listener for it
  void _playTrack(Track track) {
    _seekAllTrackToZero();
    currentTrack.value = track;
    _storage.write(key: 'current_queue_index', value: GlobalQueue.currentQueueIndex.toString());
    
    //Listen to track changes in the notification back player
    views['player'].setState(() {
      PlayerListener().listen(track);
    });
  }

  /// Transfer current [frontQueue] to the back player notification
  Future<void> _loadBackQueue(frontQueue) async {
    
    isPlayerReady = false;
    //Reload front player state to show it
    views['player'].setState(() {});

    if(!AudioService.connected) {
      await AudioService.connect();
    }

    Map<String, List<String>> queue = Map<String, List<String>>();
    queue['name'] = List<String>();
    queue['artist'] = List<String>();
    queue['imageurllarge'] = List<String>();
    queue['imageurllittle'] = List<String>();
    queue['id'] = List<String>();
    queue['service'] = List<String>();
    queue['duration'] = List<String>();
    for(MapEntry<Track, bool> me in frontQueue) {
      queue['name'].add(me.key.title);
      queue['artist'].add(me.key.artist);
      queue['imageurllarge'].add(me.key.imageUrlLarge);
      queue['imageurllittle'].add(me.key.imageUrlLarge);
      queue['id'].add(me.key.id);
      queue['service'].add(me.key.serviceName);
      queue['duration'].add(me.key.totalDuration.value.toString());
    }

    await AudioService.stop();
    await AudioService.start(
      backgroundTaskEntrypoint: _entrypoint
    );
    await AudioService.customAction('LAUNCH_QUEUE', {'queue': queue});

    //Front player can be displayed when the back player is completely initialized
    isPlayerReady = true;
    //Reload front player state to show it
    views['player'].setState(() {});
  }

  /// Create queue depending of [playlist] selected
  /// Queue generation depends of [isShuffle] parameter to have an ordered list or not
  /// Can depends of [track] if start with a specific track is wanted
  Future<void> _createQueue(Playlist playlist, {
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

    GlobalQueue().queueDatabase();
  }

  /// Listen to screen state update
  void _screenStateListener() {
    String lastScreenState = SCREEN_IDLE;
    
    screenState.addListener(() async {
      if(lastScreenState == SCREEN_IDLE && screenState.value == SCREEN_VISIBLE && isPlayerReady) {

        // if (
        //   panelCtrl.isAttached
        //   && FrontPlayerController().currentTrack.value.id != null
        //   && !panelCtrl.isPanelShown
        //   && FrontPlayerController().isPlayerReady
        // ) {
        //   panelCtrl.show();
        // }

        await AudioService.customAction('INDEX_QUEUE_REQUEST');
        var track = GlobalQueue.queue.value[backIndex];

        if(currentTrack.value.id != track.key.id || currentTrack.value.serviceName != track.key.serviceName) {
          int index = GlobalQueue.queue.value.indexOf(track);
          GlobalQueue().setCurrentQueueIndex(index);
          pageCtrl.jumpToPage(GlobalQueue.currentQueueIndex);
          _playTrack(GlobalQueue.queue.value[index].key);

          views.forEach((key, value) {
            value.setState(() {});
          });
        }
      }
      lastScreenState = screenState.value;
    });
  }

  /// Initialize player's tracks in multiple tabs form on the frontend side of the app
  void _initPageController() {
    //Listeners
    pageCtrl.addListener(() {

      //If is the finger sliding action only
      if(!pageCtrl.blockNotifier) {
        
        if(pageCtrl.page.round() > GlobalQueue.currentQueueIndex) {
          //Next page
          nextTrack(backProvider: false);
        } else if(pageCtrl.page.round() < GlobalQueue.currentQueueIndex) {
          //Previous page
          previousTrack(backProvider: false, isSeekToZero: false);
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