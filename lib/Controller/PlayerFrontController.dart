

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/ViewGetter/PlayerView.dart';

/*class PlayerFrontController extends StatefulWidget {
  final String title;
  static _PlayerFrontController state;

  PlayerFrontController({Key key, this.title}) : super(key: key);

  static PlayerFrontController getInstance() {
    if(state == null) state = createStateStatic();
    return PlayerFrontController();
  }

  static _PlayerFrontController createStateStatic() => _PlayerFrontController();

  @override
  _PlayerFrontController createState() => _PlayerFrontController();
}*/

class PlayerFrontController extends State<StatefulWidget> with TickerProviderStateMixin {

  // Map<String, Function> functions;

  bool _isShuffle = true;
  bool _isRepeatOnce = false;
  bool _isRepeatAlways = false;

  bool _blockAnimation = false;
  


  Map<ServicesLister, PlatformsController> userPlatforms =
      new Map<ServicesLister, PlatformsController>();
  Track selectedTrack = Track(
      service: ServicesLister.DEFAULT,
      artist: '',
      name: '',
      id: null,
      imageUrl: '');
  Playlist selectedPlaylist = Playlist(
    ownerId: '',
    service: ServicesLister.DEFAULT,
    id: null,
    name: ''
  );
  PlatformsController selectedPlatform = PlatformsLister.platforms[ServicesLister.DEFAULT];
  
  PanelController _panelCtrl = PanelController();
  TabController _songsTabCtrl;
  double botBarHeight;

  int _tabIndex = 0;
  bool _isPanelDraggable = true;


  setPlaying(Track track, bool queueCreate, {Playlist playlist, PlatformsController platformCtrl, bool isShuffle, bool isRepeatOnce, bool isRepeatAlways}) {

    if(isShuffle != null) _isShuffle = isShuffle;
    if(isRepeatOnce != null) _isRepeatOnce = isRepeatOnce;
    if(isRepeatAlways != null) _isRepeatAlways = isRepeatAlways;
    if(playlist != null) this.selectedPlaylist = playlist;
    if(platformCtrl != null) this.selectedPlatform = platformCtrl;

    for (MapEntry<ServicesLister, PlatformsController> elem in PlatformsLister.platforms.entries) {
      if (elem.value.getUserInformations()['isConnected'] == true)
        this.userPlatforms[elem.key] = elem.value;
    }

    setState(() {

      for (PlatformsController ctrl in this.userPlatforms.values) {
        for (Playlist play in ctrl.platform.playlists) {
          for (MapEntry<Track, DateTime> tr in play.tracks) {
            tr.key.setIsPlaying(false);
          }
        }
      }

      if (track != null) {
        track.setIsPlaying(true);
        this.selectedTrack = track;

        if(queueCreate) {

          if(_isShuffle) {
            GlobalQueue.generateNonPermanentQueue(playlist, true, selectedTrack: track);
            _blockAnimation = true;
            _songsTabCtrl.index = 0;
            _tabIndex = _songsTabCtrl.index;
          } else {
            print("here");
            GlobalQueue.generateNonPermanentQueue(playlist, false, selectedTrack: track);
            _blockAnimation = true;
            _songsTabCtrl.index = GlobalQueue.currentQueueIndex;
            _tabIndex = _songsTabCtrl.index;
            _blockAnimation = false;
          }

        } else {
          
          // Next or Previous

        }

      } else {

        if(queueCreate) {

          if(_isShuffle) {
            GlobalQueue.generateNonPermanentQueue(playlist, true);
            _blockAnimation = true;
            _songsTabCtrl.index = 0;
            _tabIndex = _songsTabCtrl.index;
            this.selectedTrack = GlobalQueue.queue[0].key;
            this.selectedTrack.setIsPlaying(true);
          } else {
            GlobalQueue.generateNonPermanentQueue(playlist, false);
            _blockAnimation = true;
            _songsTabCtrl.index = 0;
            _tabIndex = _songsTabCtrl.index;
            this.selectedTrack = GlobalQueue.queue[0].key;
            this.selectedTrack.setIsPlaying(true);
          }

        } else {
          
          // Next or Previous

        }

      }

    });

    for (PlatformsController ctrl in PlatformsLister.platforms.values) {
      ctrl.updateStates();
    }

  }

  void seekAllTrackToZero() {
    for(MapEntry me in GlobalQueue.queue) {
      Track tr = me.key;
      tr.seekTo(Duration(seconds: 0));
    }
  }

  void moveToNextTrack() {
    Track nextTrack;
    int lastIndex;
    if (GlobalQueue.currentQueueIndex + 1 < GlobalQueue.queue.length) {
      nextTrack = GlobalQueue.queue[GlobalQueue.currentQueueIndex + 1].key;
      GlobalQueue.currentQueueIndex++;
      lastIndex = GlobalQueue.currentQueueIndex-1;
    } else {
      nextTrack = GlobalQueue.queue[0].key;
      GlobalQueue.currentQueueIndex = 0;
      lastIndex = GlobalQueue.queue.length-1;
    }
    
    if(GlobalQueue.queue[lastIndex].value) {
      GlobalQueue.moveFromPermanentToNoPermanent(lastIndex);
    }

    _isRepeatOnce = false;
    _isRepeatAlways = false;
    setPlaying(nextTrack, false);
  }

  void moveToPreviousTrack() {
    Track previousTrack;
    if (GlobalQueue.currentQueueIndex - 1 >= 0) {
      previousTrack = GlobalQueue.queue[GlobalQueue.currentQueueIndex - 1].key;
      GlobalQueue.currentQueueIndex--;
    } else {
      previousTrack = this.selectedTrack;
      GlobalQueue.currentQueueIndex = 0;
    }
    _isRepeatOnce = false;
    _isRepeatAlways = false;
    GlobalQueue.reBuildQueue();
    setPlaying(previousTrack, false);
  }

  tabControllerBuilder() {
    
    if(_songsTabCtrl == null || GlobalQueue.queue.length != _songsTabCtrl.length) {

      _songsTabCtrl = TabController(length: GlobalQueue.queue.length, initialIndex: GlobalQueue.currentQueueIndex, vsync: this);
      _songsTabCtrl.addListener(() {

        setState(() {

          seekAllTrackToZero();
          if(_songsTabCtrl.index == 1 && (_tabIndex == _songsTabCtrl.length-1 || _tabIndex == 0)) {
            _tabIndex = 0;
            _blockAnimation = false;
          }
          if(!_blockAnimation) {
            if(_songsTabCtrl.index > _tabIndex) {
              _tabIndex = _songsTabCtrl.index;
              moveToNextTrack();
            } else if(_songsTabCtrl.index < _tabIndex) {
              _tabIndex = _songsTabCtrl.index;
              moveToPreviousTrack();
            }
          }
          _blockAnimation = false;
        });
        //tabControllerBuilder();

      });

    }


    if(this.selectedTrack.currentDuration >= this.selectedTrack.totalDuration) {
      setState(() {
        seekAllTrackToZero();
        if(_isRepeatOnce) {
          this.selectedTrack.seekTo(Duration(seconds: 0));
          _isRepeatOnce = false;
        } else if(_isRepeatAlways) {
          this.selectedTrack.seekTo(Duration(seconds: 0));
        } else if(_songsTabCtrl.index < _songsTabCtrl.length-1) {
          _songsTabCtrl.animateTo(_songsTabCtrl.index+1);
        } else {
          _blockAnimation = true;
          _songsTabCtrl.animateTo(0);
          moveToNextTrack();
        }
      });
    }

  }



  void skipNextButton() {
    if(_songsTabCtrl.index < _songsTabCtrl.length-1) {
      _songsTabCtrl.animateTo(_songsTabCtrl.index+1);
    } else {
      _blockAnimation = true;
      _songsTabCtrl.index = 0;
      _tabIndex = _songsTabCtrl.index;
      _blockAnimation = false;
      moveToNextTrack();
    }
  }


  void repeatButtonOnTap() {
    setState(() {
      if(_isRepeatOnce && !_isRepeatAlways) {
        _isRepeatOnce = false;
        _isRepeatAlways = true;
      } else if(_isRepeatAlways && !_isRepeatOnce) {
        _isRepeatAlways = false;
        _isRepeatOnce = false;
      } else if(!_isRepeatOnce && !_isRepeatAlways) {
        _isRepeatOnce = true;
        _isRepeatAlways = false;
      }
    });
  }

  void shuffleButtonOnTap() {
    setState(() {
      if(_isShuffle) {
        _isShuffle = false;
        this.setPlaying(this.selectedTrack, true, playlist: this.selectedPlaylist, platformCtrl: this.selectedPlatform);
      } else {
        _isShuffle = true;
        this.setPlaying(this.selectedTrack, true, playlist: this.selectedPlaylist, platformCtrl: this.selectedPlatform);
      }
    });
  }

  IconData repeatButtonIcon() {
    if(!_isRepeatOnce && !_isRepeatAlways) return Icons.repeat;
    else if(_isRepeatOnce && !_isRepeatAlways) return Icons.repeat_one;
    else if(_isRepeatAlways && !_isRepeatOnce) return Icons.repeat;
  }

  Color repeatButtonColor() {
    if(!_isRepeatOnce && !_isRepeatAlways) return Colors.white;
    else if(_isRepeatOnce && !_isRepeatAlways) return Colors.cyanAccent;
    else if(_isRepeatAlways && !_isRepeatOnce) return Colors.cyanAccent;
  }

  Color shuffleButtonColor() {
    if(_isShuffle) return Colors.cyanAccent;
    else return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    
    if(_panelCtrl.isAttached && this.selectedTrack.id != null && !_panelCtrl.isPanelShown) {
      _panelCtrl.show();
    }

    tabControllerBuilder();

    Map<String, Function> functions = {
      'skip_button_next': skipNextButton,
      'repeat_button_ontap': repeatButtonOnTap,
      'repeat_button_icon': repeatButtonIcon,
      'repeat_button_color': repeatButtonColor,
      'shuffle_button_ontap': shuffleButtonOnTap,
      'shuffle_button_color': shuffleButtonColor
    };
    Map<String, Object> attributes = {
      'selectedTrack': this.selectedTrack,
      '_isPanelDraggable': _isPanelDraggable,
      '_panelCtrl': _panelCtrl,
      '_songsTabCtrl': _songsTabCtrl,
      'selectedPlatform': this.selectedPlatform,
      'botBarHeight': this.botBarHeight
    };

    PlayerView playerViewInstance = PlayerView.getInstance(this, functions, attributes);
    playerViewInstance.constantBuilder();
    playerViewInstance.sizeBuilder();

    return playerViewInstance.buildPanel();
    
  }


}