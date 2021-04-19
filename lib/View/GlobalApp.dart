import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/Pages/Librairie/PlaylistsPage.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsView.dart';

import 'Pages/Profile/ProfilePage.dart';
import 'Pages/Search/SearchPage.dart';

class GlobalAppMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global',
      debugShowCheckedModeBanner: false,
      home: new _GlobalApp(
          title:
              'Playlist'), //Ouverture de la page agenda lors de l'ouverture de l'app
    );
  }
}

class _GlobalApp extends StatefulWidget {
  final String title;

  _GlobalApp({Key key, this.title}) : super(key: key);

  @override
  GlobalApp createState() => GlobalApp();
}

class GlobalApp extends State<_GlobalApp> with TickerProviderStateMixin {
  PageController pageController;
  List<Widget> pages;

  Map<ServicesLister, PlatformsController> userPlatforms =
      new Map<ServicesLister, PlatformsController>();
  ValueNotifier<Track> selectedTrack = ValueNotifier<Track>(Track(
      service: ServicesLister.DEFAULT,
      artist: '',
      name: '',
      id: null,
      imageUrlLittle: '',
      imageUrlLarge: ''));
  Playlist selectedPlaylist = Playlist(
    ownerId: '',
    service: ServicesLister.DEFAULT,
    id: null,
    name: ''
  );
  PlatformsController selectedPlatform = PlatformsLister.platforms[ServicesLister.DEFAULT];

  bool _isShuffle = true;
  bool _isRepeatOnce = false;
  bool _isRepeatAlways = false;

  bool _blockAnimation = false;

  int selectedIndex;
  Widget currentPage;

  void fakers() {
    PlatformsController ctrl =
        PlatformsLister.platforms[ServicesLister.DEFAULT];
    for (int i = 0; i < 10; i++) {
      ctrl.addPlaylist(
          name: ctrl.platform.name + " n°$i",
          imageUrl: 'https://source.unsplash.com/random',
          ownerId: "",
          ownerName: 'Damien');
    }
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < Random().nextInt(70); j++) {
        ctrl.addTrackToPlaylist(
            i,
            Track(
                name: "Track n°$j",
                artist: "Artist n°$i",
                totalDuration: Duration(
                    minutes: Random().nextInt(4),
                    seconds: Random().nextInt(59)),
                service: ServicesLister.DEFAULT,
                imageUrlLittle: 'https://source.unsplash.com/random',
                imageUrlLarge: 'https://source.unsplash.com/random',
                id: j.toString()),
            true);
      }
    }

    //Queue
    /*GlobalQueue.addToPermanentQueue(PlatformsLister
        .platforms[ServicesLister.DEFAULT].platform.playlists[0]
        .getTracks()[0]);*/
  }

  @override
  void initState() {
    this.fakers();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    this.initPage();
    super.initState();
  }

  void initPage() {
    Widget playlistsPage = new PlaylistsPage(setPlaying: setPlaying);
    Widget searchPage = new SearchPageMain();
    Widget profilePage = new ProfilePage();
    setState(() {
      this.pages = [playlistsPage, searchPage, profilePage];
      this.currentPage = this.pages[0];
      this.selectedIndex = 0;
      this.pageController = PageController(initialPage: selectedIndex);
    });
    for (MapEntry<ServicesLister, PlatformsController> elem
        in PlatformsLister.platforms.entries) {
      elem.value.setPlaylistsPageState(this);
      if (elem.value.getUserInformations()['isConnected'] == true)
        this.userPlatforms[elem.key] = elem.value;
    }
  }

  void onItemTapped(int index) {
    setState(() {
      this.selectedIndex = index;
      this.pageController.jumpToPage(index);
    });
  }

  /*    BACK PLAYER    */

  setPlaying(Track track, bool queueCreate, {Playlist playlist, PlatformsController platformCtrl, bool isShuffle, bool isRepeatOnce, bool isRepeatAlways}) {

    tabControllerBuilder();

    if(isShuffle != null) _isShuffle = isShuffle;
    if(isRepeatOnce != null) _isRepeatOnce = isRepeatOnce;
    if(isRepeatAlways != null) _isRepeatAlways = isRepeatAlways;
    if(playlist != null) this.selectedPlaylist = playlist;
    if(platformCtrl != null) this.selectedPlatform = platformCtrl;

    for (MapEntry<ServicesLister, PlatformsController> elem in PlatformsLister.platforms.entries) {
      if (elem.value.getUserInformations()['isConnected'] == true)
        this.userPlatforms[elem.key] = elem.value;
    }


      for (PlatformsController ctrl in this.userPlatforms.values) {
        for (Playlist play in ctrl.platform.playlists.value) {
          for (MapEntry<Track, DateTime> tr in play.tracks) {
            tr.key.setIsPlaying(false);
          }
        }
      }

      

      if (track != null) {
        track.setIsPlaying(true);
        this.selectedTrack.value = track;

        if(queueCreate) {

          if(_isShuffle) {
            GlobalQueue.generateNonPermanentQueue(playlist, true, selectedTrack: track);
            _blockAnimation = true;
            _songsTabCtrl.index = 0;
            _tabIndex = _songsTabCtrl.index;
          } else {
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
            this.selectedTrack.value = GlobalQueue.queue.value[0].key;
            this.selectedTrack.value.setIsPlaying(true);
          } else {
            GlobalQueue.generateNonPermanentQueue(playlist, false);
            _blockAnimation = true;
            _songsTabCtrl.index = 0;
            _tabIndex = _songsTabCtrl.index;
            this.selectedTrack.value = GlobalQueue.queue.value[0].key;
            this.selectedTrack.value.setIsPlaying(true);
          }

        } else {
          
          // Next or Previous

        }

      }

    mainImageColorRetriever();
    
    if(_panelCtrl.isAttached && this.selectedTrack.value.id != null && !_panelCtrl.isPanelShown) {
      _panelCtrl.show();
    }

  }

  void seekAllTrackToZero() {
    for(MapEntry me in GlobalQueue.queue.value) {
      Track tr = me.key;
      tr.seekTo(Duration(seconds: 0));
    }
  }

  void moveToNextTrack() {
    Track nextTrack;
    int lastIndex;
    if (GlobalQueue.currentQueueIndex + 1 < GlobalQueue.queue.value.length) {
      nextTrack = GlobalQueue.queue.value[GlobalQueue.currentQueueIndex + 1].key;
      GlobalQueue.currentQueueIndex++;
      lastIndex = GlobalQueue.currentQueueIndex;
    } else {
      nextTrack = GlobalQueue.queue.value[0].key;
      GlobalQueue.currentQueueIndex = 0;
      lastIndex = GlobalQueue.queue.value.length-1;
    }
    
    if(GlobalQueue.queue.value[GlobalQueue.currentQueueIndex].value) {
      GlobalQueue.moveFromPermanentToNoPermanent(lastIndex);
    }

    _isRepeatOnce = false;
    _isRepeatAlways = false;
    setPlaying(nextTrack, false);
  }

  void moveToPreviousTrack() {
    Track previousTrack;
    if (GlobalQueue.currentQueueIndex - 1 >= 0) {
      previousTrack = GlobalQueue.queue.value[GlobalQueue.currentQueueIndex - 1].key;
      GlobalQueue.currentQueueIndex--;
    } else {
      previousTrack = this.selectedTrack.value;
      GlobalQueue.currentQueueIndex = 0;
    }
    _isRepeatOnce = false;
    _isRepeatAlways = false;
    GlobalQueue.reBuildQueue();
    setPlaying(previousTrack, false);
  }


  tabControllerChecker() {
    
    if(_panelQueueCtrl.isAttached) {
      _panelQueueCtrl.show();
    }
    
    //if(_songsTabCtrl == null || GlobalQueue.queue.value.length != _songsTabCtrl.length) {
      tabControllerBuilder();
    //}


    if(this.selectedTrack.value.currentDuration >= this.selectedTrack.value.totalDuration) {
        seekAllTrackToZero();
        if(_isRepeatOnce) {
          this.selectedTrack.value.seekTo(Duration(seconds: 0));
          _isRepeatOnce = false;
        } else if(_isRepeatAlways) {
          this.selectedTrack.value.seekTo(Duration(seconds: 0));
        } else if(_songsTabCtrl.index < _songsTabCtrl.length-1) {
          _songsTabCtrl.animateTo(_songsTabCtrl.index+1);
        } else {
          _blockAnimation = true;
          _songsTabCtrl.animateTo(0);
          moveToNextTrack();
        }
    }

  }


  tabControllerBuilder() {
    
      int length;
      int initialIndex;
      switch(GlobalQueue.currentQueueIndex) {
        case 0: length = 3; initialIndex = 0; break;
        case 1: length = 4; initialIndex = 1; break;
        default: length = 5; initialIndex = 2; break;
      }
      if(GlobalQueue.queue.value.isEmpty) length = 0;

      /*print(length);
      print(initialIndex);*/

      setState(() {

        _songsTabCtrl = TabController(length: length, initialIndex: initialIndex, vsync: this);
        _songsTabCtrl.addListener(() {

            seekAllTrackToZero();
            if(_songsTabCtrl.index > _tabIndex) {
              _tabIndex = _songsTabCtrl.index;
              moveToNextTrack();
              //tabControllerBuilder();
            } else if(_songsTabCtrl.index < _tabIndex) {
              _tabIndex = _songsTabCtrl.index;
              moveToPreviousTrack();
              //tabControllerBuilder();
            }

            /*if(_songsTabCtrl.index == 1 && (_tabIndex == _songsTabCtrl.length-1 || _tabIndex == 0)) {
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
            }*/
            _blockAnimation = false;

        });
        _tabView = tabViewBuilder();

      });

  }


  /*  FRONT PLAYER  */

  double _screenWidth;
  double _screenHeight;
  double _ratio = 1;

  Widget _tabView;

  PanelController _panelCtrl = PanelController();
  PanelController _panelQueueCtrl = PanelController();
  TabController _songsTabCtrl;
  int _tabIndex = 0;
  bool _isPanelDraggable = true;
  ValueNotifier<bool> _isPanelQueueDraggable = ValueNotifier<bool>(true);

  // Front constant
  double image_size_large;
  double image_size_little;
  double side_marge;
  double botbar_height;
  double playbutton_size_large;
  double playbutton_size_little;
  double text_size_large;
  double text_size_little;

  ValueNotifier<Color> _mainImageColor = ValueNotifier<Color>(Colors.black87);
  double _botBarHeight;
  double _imageSize;
  double _sideMarge;
  double _playButtonSize;
  double _textSize;
  double _elementsOpacity;
  String _playButtonIcon = "play";
  double _currentSliderValue;

  constantBuilder() {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    image_size_large = _screenWidth * 0.7;
    image_size_little = _screenWidth * 0.16;
    side_marge = (_screenWidth-image_size_little)*0.5;
    //botbar_height = _screenHeight/15;
    botbar_height = 56;
    playbutton_size_large = _screenWidth * 0.15;
    playbutton_size_little = _screenWidth * 0.1;
    text_size_large = _screenHeight *0.02;
    text_size_little = _screenHeight *0.015;

  }

  sizeBuilder() {
    if(_imageSize == null) _imageSize = image_size_little;
    if(_sideMarge == null) _sideMarge = side_marge;
    if(_playButtonSize == null) _playButtonSize = playbutton_size_little;
    if(_textSize == null) _textSize = text_size_little;
    if(_elementsOpacity == null) _elementsOpacity = 0;
  }

  preventFromNullValue(double height) {

      if (_imageSize < image_size_little) _imageSize = image_size_little;
      if (_playButtonSize < playbutton_size_little) _playButtonSize = playbutton_size_little;
      if (_textSize < text_size_little) _textSize = text_size_little;

  }

  switchPanelSize(double height) {
    setState(() {
      FocusScope.of(context).unfocus();

      _ratio = height;

      _botBarHeight = botbar_height - (_ratio * botbar_height);
      if (_imageSize >= image_size_little) _imageSize = image_size_large * _ratio;
      _sideMarge = (1 - _ratio) * side_marge;
      if(_playButtonSize >= playbutton_size_little) _playButtonSize = playbutton_size_large * _ratio;
      if(_textSize >= text_size_little) _textSize = text_size_large * _ratio;
      _elementsOpacity = _ratio;

      preventFromNullValue(_ratio);
    });
  }

  Color darken(Color color, {double amount: .1}) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  mainImageColorRetriever() async {
    PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(this.selectedTrack.value.imageUrlLittle)
    );
    _mainImageColor.value = darken(paletteGenerator.dominantColor.color, amount: 0.4);
  }


  tabViewBuilder() {
    return TabBarView(
      controller: _songsTabCtrl,
      children: List.generate(
        _songsTabCtrl.length,
        (index) {

          ValueNotifier<bool> isImageVisible = ValueNotifier<bool>(false);

          return VisibilityDetector(
            key: ValueKey("VisibilityDetector:PanelPlayer:Tracks:$index"),
            onVisibilityChanged: (VisibilityInfo visInfos) {
              if(visInfos.visibleFraction > 0.2)
                isImageVisible.value = true;
              else
                isImageVisible.value = false;
            },
            child: ValueListenableBuilder(
              valueListenable: GlobalQueue.queue,
              builder: (_, List<MapEntry<Track, bool>> queue ,__) {

                List<Track> realQueue = List<Track>();

                for(int i=0; i<_songsTabCtrl.length; i++) {
                  switch(_songsTabCtrl.length) {
                    case 3: {
                      realQueue.add(GlobalQueue.queue.value[GlobalQueue.currentQueueIndex+i].key);
                    } break;
                    case 4 : {
                      realQueue.add(GlobalQueue.queue.value[GlobalQueue.currentQueueIndex+i-1].key);
                    } break;
                    case 5 : {
                      realQueue.add(GlobalQueue.queue.value[GlobalQueue.currentQueueIndex+i-2].key);
                    } break;
                  }
                }

                print('------');
                print(_songsTabCtrl.index);
                for(Track tr in realQueue) {
                  print(tr);
                }

                Track trackUp = realQueue[index];

                return Stack(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(trackUp.imageUrlLittle),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                color: Colors.black.withOpacity(0.55),
                              )
                          ),
                        )
                      ],
                    ),
                    Positioned(
                      top: (_screenHeight * 0.77),
                      right: (_screenWidth / 2) - _screenWidth * 0.45,
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: InkWell(
                          child: Text(trackUp.totalDuration.toString().split(':')[1] +
                              ":" + trackUp.totalDuration.toString().split(':')[2].split(".")[0]
                          )
                        )
                      )
                    ),
                    Positioned(
                      top: (_screenHeight * 0.77),
                      left: (_screenWidth / 2) - _screenWidth * 0.45,
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: InkWell(
                          child: Text(trackUp.currentDuration.toString().split(':')[1] +
                            ":" + trackUp.currentDuration.toString().split(':')[2].split(".")[0]
                          )
                        )
                      )
                    ),
                    Positioned(
                      top: (_screenHeight * 0.75),
                      left: _screenWidth / 2 - ((_screenWidth - (_screenWidth / 4)) / 2),
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: Container(
                          width: _screenWidth - (_screenWidth / 4),
                          child: Slider.adaptive(
                            value: () {
                              trackUp.currentDuration.inSeconds / trackUp.totalDuration.inSeconds >= 0
                              && trackUp.currentDuration.inSeconds / trackUp.totalDuration.inSeconds <= 1
                                ? _currentSliderValue = trackUp.currentDuration.inSeconds / trackUp.totalDuration.inSeconds
                                : _currentSliderValue = 0.0;
                                return _currentSliderValue;
                            }.call(),
                            onChanged: (double value) {
                              trackUp.seekTo(Duration(seconds: (value * trackUp.totalDuration.inSeconds).toInt()));
                            },
                            min: 0,
                            max: 1,
                            activeColor: Colors.cyanAccent,
                          )
                        )
                      )
                    ),
                    Positioned(
                      width: _imageSize,
                      height: _imageSize,
                      left: (_screenWidth / 2 - (_imageSize / 2) - _sideMarge),
                      top: (_screenHeight / 4) * _ratio,
                      child: ValueListenableBuilder(
                        valueListenable: isImageVisible,
                        builder: (BuildContext context, bool value, Widget child) {
                          return Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(trackUp.imageUrlLarge),
                              )
                            ),
                          );
                        }
                      )
                    ),
                    Positioned(
                      left: _screenWidth * 0.2 * (1 - _ratio),
                      top: (_screenHeight * 0.60) * _ratio + (_sideMarge*0.06),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: _screenWidth * 0.15 * _ratio),
                                width: _screenWidth - (_screenWidth * 0.1 * 4),
                                child: Text(
                                  trackUp.name,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: _textSize + (5 * _ratio)),
                                )
                              ),
                              Container(
                                margin: EdgeInsets.only(left: _screenWidth * 0.15 * _ratio),
                                width: _screenWidth - (_screenWidth * 0.1 * 4),
                                child: Text(
                                  trackUp.artist,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: _textSize,
                                    fontWeight: FontWeight.w200),
                                )
                              )
                            ],
                          ),
                          IgnorePointer(
                            ignoring: (_elementsOpacity == 1 ? false : true),
                            child: Opacity(
                              opacity: _elementsOpacity,
                              child: InkWell(
                                  onTap: () {
                                    TabsView.getInstance(this).addToPlaylist(this.selectedPlatform, trackUp);
                                  },
                                  child: Icon(
                                  Icons.add,
                                  size: _playButtonSize - 10,
                                )
                              )
                            )
                          )
                        ]
                      )
                    ),
                    Opacity(
                      opacity: 1 - _ratio,
                      child: Container(
                        color: Colors.white,
                        width: trackUp.currentDuration.inSeconds * _screenWidth / trackUp.totalDuration.inSeconds,
                        height: 2,
                      ),
                    )
                  ],
                );
              }
            )
          );
        }
      )
    );
  }



  buildPanel() {
    return Stack(
      children: [
        SlidingUpPanel(
          isDraggable: _isPanelDraggable,
          onPanelSlide: (height) => switchPanelSize(height),
          controller: _panelCtrl,
          minHeight: botbar_height+10,
          maxHeight: _screenHeight,
          panelBuilder: (scrollCtrl) {
            if(this.selectedTrack.value.id == null) _panelCtrl.hide();
            return WillPopScope(
              onWillPop: () async {
                if(_panelCtrl.isPanelOpen) {
                  if(_panelQueueCtrl.isPanelOpen) {
                    _panelQueueCtrl.close();
                  } else {
                    _panelCtrl.close();
                  }
                  return false;
                } else
                  return true;
              },
              child: GestureDetector(
                onTap: () => _panelCtrl.panelPosition < 0.3 ? _panelCtrl.open() : null,
                child: Stack(
                  key: ValueKey('FrontPLayer'),
                  children: [
                    _tabView,
                    Positioned(
                      top: (_screenHeight * 0.80) * _ratio + (_sideMarge*0.07),
                      right: ((_screenWidth / 2) - (_playButtonSize / 2) - _sideMarge),
                      child: InkWell(
                        onTap: () {
                          this.selectedTrack.value.playPause() == true ? _playButtonIcon = "play" : _playButtonIcon = "pause";
                        },
                        child: Icon(
                          _playButtonIcon == "play" ? Icons.play_arrow : Icons.pause,
                          size: _playButtonSize,
                        )
                      )
                    ),
                    Positioned(
                      top: (_screenHeight * 0.8),
                      right: (_screenWidth / 2) - (_screenWidth / 4),
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: InkWell(
                            onTap: () {
                              if(_songsTabCtrl.index < _songsTabCtrl.length-1) {
                                _songsTabCtrl.animateTo(_songsTabCtrl.index+1);
                              } else {
                                _blockAnimation = true;
                                _songsTabCtrl.index = 0;
                                _tabIndex = _songsTabCtrl.index;
                                _blockAnimation = false;
                                moveToNextTrack();
                              }
                            },
                            child: Icon(
                            Icons.skip_next,
                            size: _playButtonSize,
                          )
                        )
                      )
                    ),
                    Positioned(
                      top: (_screenHeight * 0.8),
                      right: _screenWidth - (_screenWidth / 2.5),
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: InkWell(
                            onTap: () {
                              if(this.selectedTrack.value.currentDuration.inSeconds >= 1) {
                                this.selectedTrack.value.seekTo(Duration(seconds: 0));
                              } else if(_songsTabCtrl.index > 0) {
                                _songsTabCtrl.animateTo(_songsTabCtrl.index-1);
                              }
                            },
                            child: Icon(
                            Icons.skip_previous,
                            size: _playButtonSize,
                          )
                        )
                      )
                    ),
                    Positioned(
                      top: (_screenHeight * 0.82),
                      right: (_screenWidth / 2) - (_screenWidth / 2.5),
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: InkWell(
                            onTap: () {
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
                            },
                            child: Icon(
                            () {
                              if(!_isRepeatOnce && !_isRepeatAlways) return Icons.repeat;
                              else if(_isRepeatOnce && !_isRepeatAlways) return Icons.repeat_one;
                              else if(_isRepeatAlways && !_isRepeatOnce) return Icons.repeat;
                            }.call(),
                            color: () {
                              if(!_isRepeatOnce && !_isRepeatAlways) return Colors.white;
                              else if(_isRepeatOnce && !_isRepeatAlways) return Colors.cyanAccent;
                              else if(_isRepeatAlways && !_isRepeatOnce) return Colors.cyanAccent;
                            }.call(),
                            size: _playButtonSize - 30,
                          )
                        )
                      )
                    ),
                    Positioned(
                      top: (_screenHeight * 0.82),
                      left: (_screenWidth / 2) - (_screenWidth / 2.5),
                      child: Opacity(
                        opacity: _elementsOpacity,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if(_isShuffle) {
                                _isShuffle = false;
                                this.setPlaying(this.selectedTrack.value, true, playlist: this.selectedPlaylist, platformCtrl: this.selectedPlatform);
                              } else {
                                _isShuffle = true;
                                this.setPlaying(this.selectedTrack.value, true, playlist: this.selectedPlaylist, platformCtrl: this.selectedPlatform);
                              }
                            });
                          },
                            child: Icon(
                            Icons.shuffle,
                            color: () {
                              if(_isShuffle) return Colors.cyanAccent;
                              else return Colors.white;
                            }.call(),
                            size: _playButtonSize - 30,
                          )
                        )
                      )
                    )
                  ],
                ),
              ),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: _mainImageColor,
          builder: (BuildContext context, Color imageColor, Widget child) {
        
        return ValueListenableBuilder(
          valueListenable: _isPanelQueueDraggable,
          builder: (BuildContext context, bool value, Widget child) {
            return IgnorePointer(
              ignoring: (_elementsOpacity < 0.8 ? true : false),
              child: Opacity(
                opacity: _elementsOpacity,
                child: SlidingUpPanel(
                  controller: _panelQueueCtrl,
                  isDraggable: value,
                  minHeight: botbar_height-10,
                  maxHeight: _screenHeight,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
                  panelBuilder: (ScrollController scrollCtrl) {

                    List<DragAndDropList> allList;

                    return GestureDetector(
                      onTap: () => _panelQueueCtrl.panelPosition < 0.3 ? _panelQueueCtrl.open() : null,
                      onVerticalDragStart: (vertDragStart) {
                        _isPanelQueueDraggable.value = true;
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Container(
                          decoration: new BoxDecoration(
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(15.0),
                              topRight: const Radius.circular(15.0),
                            ),
                            color: darken(imageColor, amount: 0.1),
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(10),
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.all(Radius.circular(12.0))
                                ),
                              ),
                              Container(
                                height: _screenHeight-30,
                                child: DefaultTabController(
                                  length: 2,
                                  child: Scaffold(
                                    backgroundColor: imageColor,
                                    appBar: AppBar(
                                      backgroundColor: darken(imageColor, amount: 0.1),
                                      toolbarHeight: 50,
                                      bottom: TabBar(
                                        tabs: [
                                          Tab(text: "Queue"),
                                          Tab(text: "Lyrics"),
                                        ],
                                      ),
                                    ),
                                    body: GestureDetector(
                                      onVerticalDragStart: (vertDragStart) {
                                        _isPanelQueueDraggable.value = true;
                                      },
                                      child: TabBarView(
                                        children: [
                                          DragAndDropLists(
                                            onItemDraggingChanged: (DragAndDropItem details, bool isChanging) {
                                              if(isChanging == null || isChanging) _isPanelQueueDraggable.value = false;
                                              else _isPanelQueueDraggable.value = true;
                                            },
                                            onItemReorder: (int i1, int l1, int i2, int l2) { },
                                            itemOnAccept: (DragAndDropItem i1, DragAndDropItem i2) {
                                              if(i1 != null && i2 != null) {
                                                int oldItemIndex = int.parse(i1.child.key.toString().split(':')[2]);
                                                int newItemIndex = int.parse(i2.child.key.toString().split(':')[2]);
                                                if(allList.length == 1) {
                                                  GlobalQueue.reorder(oldItemIndex, 1, newItemIndex, 1);
                                                } else {
                                                  String oldList = i1.child.key.toString().split(':')[1];
                                                  String newList = i2.child.key.toString().split(':')[1];
                                                  switch(oldList) {
                                                    case 'PermanentQueue': {
                                                      switch(newList) {
                                                        case 'PermanentQueue': GlobalQueue.reorder(oldItemIndex, 0, newItemIndex, 0); break;
                                                        case 'NoPermanentQueue': GlobalQueue.reorder(oldItemIndex, 0, newItemIndex, 1); break;
                                                      }
                                                    } break;
                                                    case 'NoPermanentQueue': {
                                                      switch(newList) {
                                                        case 'PermanentQueue': GlobalQueue.reorder(oldItemIndex, 1, newItemIndex, 0); break;
                                                        case 'NoPermanentQueue': GlobalQueue.reorder(oldItemIndex, 1, newItemIndex, 1); break;
                                                      }
                                                    } break;
                                                  }
                                                }
                                              }
                                            },
                                            scrollController: scrollCtrl,
                                            children: () {

                                              List<DragAndDropItem> permanentItems = 
                                              List.generate(
                                                  GlobalQueue.permanentQueue.value.length,
                                                  (index) {

                                                    return DragAndDropItem(
                                                      child: ValueListenableBuilder(
                                                        valueListenable: GlobalQueue.permanentQueue,
                                                        key: ValueKey('ReorderableListView:PermanentQueue:$index:'),
                                                        builder: (BuildContext context, List<Track> value, Widget child) {
                                                    
                                                          List<Track> queue = List<Track>();
                                                          
                                                          for(Track tr in GlobalQueue.permanentQueue.value) {
                                                            queue.add(tr);
                                                          }

                                                          return Container(
                                                            margin: EdgeInsets.only(left: 20, right: 20),
                                                            
                                                            child:  Card(
                                                              color: darken(imageColor, amount: 0.1),
                                                              child: Row(
                                                                children: [
                                                                  Flexible(
                                                                    flex: 5,
                                                                    child: ListTile(
                                                                      title: Text(queue.elementAt(index).name),
                                                                      leading: FractionallySizedBox(
                                                                        heightFactor: 0.8,
                                                                        child: AspectRatio(
                                                                          aspectRatio: 1,
                                                                          child: new Container(
                                                                            decoration: new BoxDecoration(
                                                                              image: new DecorationImage(
                                                                                fit: BoxFit.fitHeight,
                                                                                alignment: FractionalOffset.center,
                                                                                image: NetworkImage(queue.elementAt(index).imageUrlLittle),
                                                                              )
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ),
                                                                      subtitle: Text(queue.elementAt(index).artist),
                                                                    )
                                                                  ),
                                                                  Flexible(
                                                                    flex: 1,
                                                                    child: Container (
                                                                      margin: EdgeInsets.only(left:20, right: 20),
                                                                      child: Icon(Icons.drag_handle)
                                                                    )
                                                                  )
                                                                ]
                                                              )
                                                            )
                                                          );
                                                        }
                                                      )
                                                    );
                                                  },
                                                );

                                              List<DragAndDropItem> noPermanentItems = 
                                              List.generate(
                                                  GlobalQueue.noPermanentQueue.value.length-(GlobalQueue.currentQueueIndex+1) > -1 ?
                                                  GlobalQueue.noPermanentQueue.value.length-(GlobalQueue.currentQueueIndex+1) : 0,
                                                  (index) {

                                                    return DragAndDropItem(
                                                      child: ValueListenableBuilder(
                                                        valueListenable: GlobalQueue.noPermanentQueue,
                                                        key: ValueKey('ReorderableListView:NoPermanentQueue:$index:'),
                                                        builder: (BuildContext context, List<Track> value, Widget child) {
                                                    
                                                          List<Track> queue = List<Track>();
                                                          
                                                          for(int i=0; i<GlobalQueue.noPermanentQueue.value.length; i++) {
                                                            if(i>GlobalQueue.currentQueueIndex) {
                                                              queue.add(GlobalQueue.noPermanentQueue.value[i]);
                                                            }
                                                          }

                                                          return Container(
                                                            margin: EdgeInsets.only(left: 20, right: 20),
                                                            
                                                            child: Card(
                                                              color: darken(imageColor, amount: 0.1),
                                                              child: Row(
                                                                children: [
                                                                  Flexible(
                                                                    flex: 5,
                                                                    child: ListTile(
                                                                      title: Text(queue.elementAt(index).name),
                                                                      leading: FractionallySizedBox(
                                                                        heightFactor: 0.8,
                                                                        child: AspectRatio(
                                                                          aspectRatio: 1,
                                                                          child: new Container(
                                                                            decoration: new BoxDecoration(
                                                                              image: new DecorationImage(
                                                                                fit: BoxFit.fitHeight,
                                                                                alignment: FractionalOffset.center,
                                                                                image: NetworkImage(queue.elementAt(index).imageUrlLittle),
                                                                              )
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ),
                                                                      subtitle: Text(queue.elementAt(index).artist),
                                                                    )
                                                                  ),
                                                                  Flexible(
                                                                    flex: 1,
                                                                    child: Container (
                                                                        margin: EdgeInsets.only(left:20, right: 20),
                                                                        child: Icon(Icons.drag_handle)
                                                                      )
                                                                    )
                                                                  ]
                                                                )
                                                              )
                                                            );
                                                        }
                                                      )
                                                    );
                                                  },
                                                );

                                                DragAndDropList permanentList = DragAndDropList(
                                                  canDrag: false,
                                                  header: Container(
                                                    margin: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
                                                    child: Text(
                                                      "Prochain dans la file d'attente",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontSize: 20
                                                      )
                                                    )
                                                  ),
                                                  children: permanentItems
                                                );

                                                DragAndDropList noPermanentList = DragAndDropList(
                                                  canDrag: false,
                                                  header: Container(
                                                    margin: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
                                                    child: Text(
                                                      "Prochaine depuis " + this.selectedPlaylist.name,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 20
                                                      )
                                                    )
                                                  ),
                                                  children: noPermanentItems
                                                );

                                                if(GlobalQueue.permanentQueue.value.isEmpty)
                                                  allList = [noPermanentList];
                                                else
                                                  allList = [permanentList, noPermanentList];


                                                return allList;

                                            }.call(),
                                          ),


                                          Text("Work in progress"),
                                        ],
                                      ),
                                    )
                                  )
                                )
                              )
                            ],
                          )
                        )
                      )
                    );
                  }
                )
              )
            );
          }
            );
          }
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {

    constantBuilder();
    tabControllerChecker();
    sizeBuilder();


    return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.yellow,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Stack(children: [
              PageView(
                controller: this.pageController,
                physics: NeverScrollableScrollPhysics(),
                children: this.pages,
              ),
              buildPanel()
            ]),
            bottomNavigationBar: Container(
                height: _botBarHeight,
                child: BottomNavigationBar(
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.library_music),
                        label: 'Bibliotèque',
                        backgroundColor: Colors.black),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        label: 'Search',
                        backgroundColor: Colors.black),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.account_circle),
                        label: 'Profile',
                        backgroundColor: Colors.black),
                  ],
                  currentIndex: this.selectedIndex,
                  onTap: this.onItemTapped,
                )
            )
        )
    );
  }
}
