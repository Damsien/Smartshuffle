import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/BackPlayer.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Model/Object/UsefullWidget/page_controller.dart';

class FrontPlayerController {

  FrontPlayerController._singleton();
  factory FrontPlayerController() {
    return _instance;
  }

  static final FrontPlayerController _instance = FrontPlayerController._singleton();


  //Objects
  PlatformsController _currentPltfCtrl;
  Playlist _currentPlaylist;
  ValueNotifier<Track> _currentTrack = ValueNotifier<Track>(null);

  // Controllers
  CustomPageController _pageCtrl = CustomPageController(keepPage: false);


  // Misc
  bool _isShuffle = true;
  bool _isRepeatOnce = false;
  bool _isRepeatAlways = false;


  // PUBLIC

  void onInitPage() {
    _initPageController();
  }

  void onBuildPage() {

  }


  void createQueueAndPlay(Playlist playlist, {
    @required PlatformsController ctrl,
    @required bool isShuffle,
    @required bool isRepeatOnce,
    @required bool isRepeatAlways,
    Track track
  }) {
    _currentPlaylist = playlist;
    _currentPltfCtrl = ctrl;

    _isShuffle = isShuffle;
    _isRepeatOnce = isRepeatOnce;
    _isRepeatAlways = isRepeatAlways;

    if (track != null) {

      if(_isShuffle) {
        GlobalQueue().generateNonPermanentQueue(playlist, true, selectedTrack: track);
        _pageCtrl.jumpToPage(0);
      } else {
        GlobalQueue().generateNonPermanentQueue(playlist, false, selectedTrack: track);
        _pageCtrl.jumpToPage(GlobalQueue.currentQueueIndex);
      }
      playTrack(track);

    } else {

      if(_isShuffle) {
        GlobalQueue().generateNonPermanentQueue(playlist, true);
      } else {
        GlobalQueue().generateNonPermanentQueue(playlist, false);
      }
      _pageCtrl.jumpToPage(0);
      playTrack(GlobalQueue.queue.value[0].key);

    }
    
  }

  void playTrack(Track track) {
    _currentTrack.value = track;
    
    //Listen to track changes in the notification back player
    PlayerListener().listen(track);
  }


  /// Skip page and current track to play next track and change audio source if isn't [backProvider]
  void nextTrack({@required bool backProvider}) {
    Track nextTrack;

    //Update index of queue
    GlobalQueue().setCurrentQueueIndex(GlobalQueue.currentQueueIndex+1);
    //Get the next track
    nextTrack = GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key;

    playTrack(nextTrack);

    if(!backProvider) {
      AudioService.skipToNext();
    }
  }

  /// Skip page and current track to play previous track and change audio source if isn't [backProvider]
  void previousTrack({@required bool backProvider}) {
    Track previousTrack;

    //Update index of queue
    GlobalQueue().setCurrentQueueIndex(GlobalQueue.currentQueueIndex-1);
    //Get the previous track
    previousTrack = GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].key;
    
    playTrack(previousTrack);

    if(!backProvider) {
      AudioService.skipToPrevious();
    }
  }



  // PRIVATE

  void _initPageController() {
    //Listener
    _pageCtrl.addListener(() {
      if(!_pageCtrl.blockNotifier) {

        if(_pageCtrl.page.round() > GlobalQueue.currentQueueIndex) {
          //Next page
          nextTrack(backProvider: false);
        } else if(_pageCtrl.page.round() < GlobalQueue.currentQueueIndex) {
          //Previous page
          previousTrack(backProvider: false);
        }

      }
    });
  }

}