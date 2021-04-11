import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
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
  Track selectedTrack = Track(
      service: ServicesLister.DEFAULT,
      artist: '',
      name: '',
      id: '',
      imageUrl: '');

  int selectedIndex;
  Widget currentPage;

  void fakers() {
    PlatformsController ctrl =
        PlatformsLister.platforms[ServicesLister.DEFAULT];
    for (int i = 0; i < 10; i++) {
      ctrl.addPlaylist(
          name: ctrl.platform.name + " n°$i",
          imageUrl: 'https://source.unsplash.com/random',
          ownerId: "");
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
                imageUrl: 'https://source.unsplash.com/random',
                id: j.toString()),
            true);
      }
    }

    //Queue
    GlobalQueue.addToPermanentQueue(PlatformsLister
        .platforms[ServicesLister.DEFAULT].platform.playlists[0]
        .getTracks()[0]);
    GlobalQueue.addToPermanentQueue(PlatformsLister
        .platforms[ServicesLister.DEFAULT].platform.playlists[0]
        .getTracks()[0]);
  }

  @override
  void initState() {
    this.fakers();
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

  setPlaying(Track track, String playMode, {Playlist playlist}) {
    for (MapEntry<ServicesLister, PlatformsController> elem
        in PlatformsLister.platforms.entries) {
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

        if (playMode == 'selected_shuffle') {
          GlobalQueue.currentQueueIndex = 0;
          GlobalQueue.replaceInPermanentQueue(0, this.selectedTrack);
          GlobalQueue.generateNonPermanentQueue(playlist);
        }
      } else {
        if (playMode == 'simple_shuffle') {
          GlobalQueue.currentQueueIndex = 0;
          GlobalQueue.resetQueue();
          GlobalQueue.generateNonPermanentQueue(playlist);
          this.selectedTrack = GlobalQueue.queue[0];
          this.selectedTrack.setIsPlaying(true);
        } else {
          GlobalQueue.currentQueueIndex = 0;
          GlobalQueue.resetQueue();
        }
      }
    });
    for (PlatformsController ctrl in PlatformsLister.platforms.values) {
      ctrl.updateStates();
    }
  }

  void moveToNextTrack() {
    Track nextTrack = this.selectedTrack;
    if (GlobalQueue.queue.indexOf(this.selectedTrack) + 1 < GlobalQueue.queue.length) {
      nextTrack = GlobalQueue.queue[GlobalQueue.queue.indexOf(this.selectedTrack) + 1];
      GlobalQueue.currentQueueIndex = GlobalQueue.queue.indexOf(nextTrack);
      this.selectedTrack = nextTrack;
    }
    setPlaying(nextTrack, null);
  }

  void moveToPreviousTrack({bool isRewinder = false}) {
    Track previousTrack = this.selectedTrack;
    if(!isRewinder || this.selectedTrack.currentDuration.inSeconds <= 1) {
      if (GlobalQueue.queue.indexOf(this.selectedTrack) - 1 >= 0) {
        previousTrack = GlobalQueue.queue[GlobalQueue.queue.indexOf(this.selectedTrack) - 1];
        GlobalQueue.currentQueueIndex--;
        this.selectedTrack = previousTrack;
      }
    } else {
      previousTrack = this.selectedTrack;
      this.selectedTrack.seekTo(Duration(seconds: 0));
    }
    setPlaying(previousTrack, null);
  }

  /*  FRONT PLAYER  */

  double _screenWidth;
  double _screenHeight;
  double _ratio = 1;

  PanelController _panelCtrl = PanelController();
  TabController _songsTabCtrl;
  int _tabIndex = 0;
  bool _isPanelDraggable = true;

  // Front constant
  double image_size_large;
  double image_size_little;
  double side_marge;
  double botbar_height;
  double playbutton_size_large;
  double playbutton_size_little;
  double text_size_large;
  double text_size_little;

  double _botBarHeight;
  double _imageSize;
  double _sideMarge;
  double _playButtonSize;
  double _textSize;
  double _elementsOpacity;
  String _playButtonIcon = "play";

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
    setState(() {

      if (_imageSize < image_size_little) _imageSize = image_size_little;
      if (_playButtonSize < playbutton_size_little) _playButtonSize = playbutton_size_little;
      if (_textSize < text_size_little) _textSize = text_size_little;

    });
  }

  switchPanelSize(double height) {
    setState(() {

      _ratio = height;

      _botBarHeight = botbar_height - (_ratio * botbar_height);
      if (_imageSize >= image_size_little) _imageSize = image_size_large * _ratio;
      _sideMarge = (1 - _ratio) * side_marge;
      if(_playButtonSize >= playbutton_size_little) _playButtonSize = playbutton_size_large * _ratio;
      if(_textSize >= text_size_little) _textSize = text_size_large * _ratio;
      _elementsOpacity = _ratio;

    });
    preventFromNullValue(_ratio);
  }



  buildPanel() {
    return SlidingUpPanel(
      isDraggable: _isPanelDraggable,
      onPanelSlide: (height) => switchPanelSize(height),
      controller: _panelCtrl,
      minHeight: botbar_height+10,
      maxHeight: _screenHeight,
      panelBuilder: (scrollCtrl) {
        return WillPopScope(
          onWillPop: () => _panelCtrl.close(),
          child: GestureDetector(
            onTap: () => _panelCtrl.panelPosition < 0.3 ? _panelCtrl.open() : null,
            child: Stack(
              key: ValueKey('FrontPLayer'),
              children: [
                TabBarView(
                controller: _songsTabCtrl,
                  children: List.generate(
                    GlobalQueue.queue.length,
                    (index) {
                      Track track = GlobalQueue.queue[index];
                      return Stack(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(track.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: index == _songsTabCtrl.length ? 10 : 0,
                                  sigmaY: index == _songsTabCtrl.length ? 10 : 0),
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Colors.black.withOpacity(0.55),
                                    )
                                  ]
                                )
                              ),
                            ],
                          ),
                          Positioned(
                            top: (_screenHeight * 0.77),
                            right: (_screenWidth / 2) - _screenWidth * 0.45,
                            child: Opacity(
                              opacity: _elementsOpacity,
                              child: InkWell(
                                child: Text(track.totalDuration.toString().split(':')[1] +
                                    ":" + track.totalDuration.toString().split(':')[2].split(".")[0]
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
                                child: Text(track.currentDuration.toString().split(':')[1] +
                                  ":" + track.currentDuration.toString().split(':')[2].split(".")[0]
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
                                  value: (track.currentDuration.inSeconds /
                                          track.totalDuration.inSeconds < 0 ||
                                          track.currentDuration.inSeconds /
                                          track.totalDuration.inSeconds > 1
                                      ? 0.0
                                      : track.currentDuration.inSeconds /
                                          track.totalDuration.inSeconds),
                                  onChanged: (double value) {},
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
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(track.imageUrl),
                                )
                              ),
                            ),
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
                                        track.name,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: _textSize + (5 * _ratio)),
                                      )
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: _screenWidth * 0.15 * _ratio),
                                      width: _screenWidth - (_screenWidth * 0.1 * 4),
                                      child: Text(
                                        track.artist,
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
                        ],
                      );
                    }
                  )
                ),
                Positioned(
                  top: (_screenHeight * 0.80) * _ratio + (_sideMarge*0.07),
                  right: ((_screenWidth / 2) - (_playButtonSize / 2) - _sideMarge),
                  child: InkWell(
                    onTap: () => _playButtonIcon == "play" ? _playButtonIcon = "pause" : _playButtonIcon = "play",
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
                        onTap: () => this.moveToNextTrack(),
                        child: Icon(
                        Icons.skip_next,
                        size: _playButtonSize,
                      )
                    )
                  )
                ),
                Positioned(
                  top: (_screenHeight * 0.8),
                  left: (_screenWidth / 2) - (_screenWidth / 4),
                  child: Opacity(
                    opacity: _elementsOpacity,
                    child: InkWell(
                        onTap: () => this.moveToPreviousTrack(isRewinder: true),
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
                        child: Icon(
                        Icons.repeat,
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
                        child: Icon(
                        Icons.shuffle,
                        size: _playButtonSize - 30,
                      )
                    )
                  )
                ),
              ],
            )
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      _songsTabCtrl = TabController(length: GlobalQueue.queue.length, initialIndex: 0, vsync: this);
      _songsTabCtrl.addListener(() {
        /*print("-------------");
        print(_songsTabCtrl.index);
        print(_tabIndex);*/
        if(_songsTabCtrl.index > _tabIndex) {
          _tabIndex = _songsTabCtrl.index;
          moveToNextTrack();
        }
      });
    });


    constantBuilder();
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
                ))));
  }
}
