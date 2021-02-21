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

import 'Pages/Profile/ProfilePage.dart';
import 'Pages/Search/SearchPage.dart';

class GlobalAppMain extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global',
      debugShowCheckedModeBanner: false,
      home: new _GlobalApp(title: 'Playlist'),  //Ouverture de la page agenda lors de l'ouverture de l'app
    );
  }
}

class _GlobalApp extends StatefulWidget {

  final String title;
  
  _GlobalApp({Key key, this.title}) : super(key: key);

  @override
  GlobalApp createState() => GlobalApp();
}

class GlobalApp extends State<_GlobalApp> {
  
  PageController pageController;
  List<Widget> pages;

  Map<ServicesLister, PlatformsController> userPlatforms = new Map<ServicesLister, PlatformsController>();
  Track selectedTrack = Track(service: ServicesLister.DEFAULT, artist: '', name: '', id: '', imageUrl: '');

  int selectedIndex;
  Widget currentPage;


  void fakers() {
      PlatformsController ctrl = PlatformsLister.platforms[ServicesLister.DEFAULT];
      for(int i=0; i<10; i++) {
        ctrl.addPlaylist(
          name: ctrl.platform.name+" n°$i",
          imageUrl: 'https://source.unsplash.com/random',
          ownerId: ""
        );
      }
      for(int i=0; i<10; i++) {
        for(int j=0; j<Random().nextInt(70); j++) {
          ctrl.addTrackToPlaylist(i, 
            Track(
              name: "Track n°$j", 
              artist: "Artist n°$i", 
              totalDuration: Duration(
                minutes: Random().nextInt(4),
                seconds: Random().nextInt(59)
              ),
              service: ServicesLister.DEFAULT,
              imageUrl: 'https://source.unsplash.com/random',
              id: j.toString()
            ),
            true
          );
        }
      }

    //Queue
    GlobalQueue.addToPermanentQueue(PlatformsLister.platforms[ServicesLister.DEFAULT].platform.playlists[0].getTracks()[0]);
    GlobalQueue.addToPermanentQueue(PlatformsLister.platforms[ServicesLister.DEFAULT].platform.playlists[0].getTracks()[0]);
  }

  @override
  void initState() {
    this.fakers();
    this.initPage();
    super.initState();
  }

  void initPage() {
    Widget playlistsPage = new PlaylistsPage(setPlaying: setPlaying,);
    Widget searchPage = new SearchPageMain();
    Widget profilePage = new ProfilePage();
    setState(() {
      this.pages = [playlistsPage, searchPage, profilePage];
      this.currentPage = this.pages[0];
      this.selectedIndex = 0;
      this.pageController = PageController(initialPage: selectedIndex);
    });
    for(MapEntry<ServicesLister, PlatformsController> elem in PlatformsLister.platforms.entries) {
      elem.value.setPlaylistsPageState(this);
      if(elem.value.getUserInformations()['isConnected'] == true)
        this.userPlatforms[elem.key] = elem.value;
    }
  }

  

  void onItemTapped(int index) {
    setState(() {
      this.selectedIndex = index;
      this.pageController.jumpToPage(index);
    });
  }


  

  
  //PLAYER

  Widget mainPlayer;

  double opacity = 1;
  bool visbible = false;
  
  //Margin
  double bottomMarg = 5;
  double heightMarg = 65;
  double sideMarg = 20;

  double botBarHeight = 56;

  double verticalUpdateValue;

  //Little
  int _animationDuration = 200;

  double imageSize;
  double playButtonSize;
  double trackTextSize;
  double skipElements;


  setPlaying(Track track) {
    for(MapEntry<ServicesLister, PlatformsController> elem in PlatformsLister.platforms.entries) {
      if(elem.value.getUserInformations()['isConnected'] == true)
        this.userPlatforms[elem.key] = elem.value;
    }
    setState(() {
      for(PlatformsController ctrl in this.userPlatforms.values) {
        for(Playlist play in ctrl.platform.playlists) {
          for(MapEntry<Track, DateTime> tr in play.tracks) {
            tr.key.setIsPlaying(false);
          }
        }
      }
      if(track != null) {
        track.setIsPlaying(true);
        this.selectedTrack = track;
        GlobalQueue.replaceInPermanentQueue(GlobalQueue.currentQueueIndex, this.selectedTrack);

        //Player
        if(this.mainPlayer.key != ValueKey('LargePlayer')) {
          this.visbible = true;
          this.heightMarg = 65;
          this.bottomMarg = 5;
          this.opacity = 1;
        }

      } else {
        GlobalQueue.currentQueueIndex = 0;
        GlobalQueue.resetQueue();
      }


    });
    for(PlatformsController ctrl in PlatformsLister.platforms.values) {
      ctrl.updateStates();
    }
  }



  Widget widgetLargePlayer() {
    return Stack(
      key: ValueKey('LargePlayer'),
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(this.selectedTrack.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              width: MediaQuery.of(context).size.width-this.sideMarg,
              height:  MediaQuery.of(context).size.height,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
            )
          ],
        ),
        Positioned(
          top: (MediaQuery.of(context).size.height/1.14),
          right: ((MediaQuery.of(context).size.width/2)-this.playButtonSize/2),
          child: InkWell(
            child: Icon(
              Icons.play_arrow,
              size: this.playButtonSize,
            )
          )
        ),
        Positioned(
          top: (MediaQuery.of(context).size.height/1.193),
          right: (MediaQuery.of(context).size.width/2)-190,
          child: Opacity(
            opacity: this.skipElements,
            child: InkWell(
              child: Text(this.selectedTrack.totalDuration.toString().split(':')[1]
                +":"+this.selectedTrack.totalDuration.toString().split(':')[2].split(".")[0])
            )
          )
        ),
        Positioned(
          top: (MediaQuery.of(context).size.height/1.19),
          left: (MediaQuery.of(context).size.width/2)-190,
          child: Opacity(
            opacity: this.skipElements,
            child: InkWell(
              child: Text(this.selectedTrack.currentDuration.toString().split(':')[1]
                +":"+this.selectedTrack.currentDuration.toString().split(':')[2].split(".")[0])
            )
          )
        ),
        Positioned(
          top: (MediaQuery.of(context).size.height/2+MediaQuery.of(context).size.height/3.1),
          left: MediaQuery.of(context).size.width/2-((MediaQuery.of(context).size.width-(MediaQuery.of(context).size.width/4))/2),
          child: Opacity(
            opacity: this.skipElements,
            child: Container(
              width: MediaQuery.of(context).size.width-(MediaQuery.of(context).size.width/4),
              child: Slider.adaptive(
                value: (this.selectedTrack.currentDuration.inSeconds / this.selectedTrack.totalDuration.inSeconds < 0
                  || this.selectedTrack.currentDuration.inSeconds / this.selectedTrack.totalDuration.inSeconds > 1 ?
                  0.0 :
                  this.selectedTrack.currentDuration.inSeconds / this.selectedTrack.totalDuration.inSeconds),
                onChanged: (double value) {  },
                min: 0,
                max: 1,
                activeColor: Colors.cyanAccent,
              )
            )
          )
        ),
        Positioned(
          top: (MediaQuery.of(context).size.height/1.14),
          right: (MediaQuery.of(context).size.width/2)-90,
          child: Opacity(
            opacity: this.skipElements,
            child: InkWell(
              child: Icon(
                Icons.skip_next,
                size: this.playButtonSize,
              )
            )
          )
        ),
        Positioned(
          top: (MediaQuery.of(context).size.height/1.14),
          left: (MediaQuery.of(context).size.width/2)-90,
          child: Opacity(
            opacity: this.skipElements,
            child: InkWell(
              child: Icon(
                Icons.skip_previous,
                size: this.playButtonSize,
              )
            )
          )
        ),
        Positioned(
          top: (MediaQuery.of(context).size.height/1.123),
          right: (MediaQuery.of(context).size.width/2)-150,
          child: Opacity(
            opacity: this.skipElements,
            child: InkWell(
              child: Icon(
                Icons.repeat,
                size: this.playButtonSize-20,
              )
            )
          )
        ),
        Positioned(
          top: (MediaQuery.of(context).size.height/1.12),
          left: (MediaQuery.of(context).size.width/2)-150,
          child: Opacity(
            opacity: this.skipElements,
            child: InkWell(
              child: Icon(
                Icons.shuffle,
                size: this.playButtonSize-20,
              )
            )
          )
        ),
        Positioned(
          width: this.imageSize,
          height: this.imageSize,
          left: (MediaQuery.of(context).size.width/2-(this.imageSize/2)-this.sideMarg),
          top: (MediaQuery.of(context).size.height/4)*this.verticalUpdateValue,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(this.selectedTrack.imageUrl),
              )
            ),
          ),
        ),
        Positioned(
          left: (MediaQuery.of(context).size.width/2-175),
          top: (MediaQuery.of(context).size.height/1.5),
          child: Container(
            width: 350,
            child: Text(
              this.selectedTrack.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: this.trackTextSize),
            )
          )
        ),
        Positioned(
          left: (MediaQuery.of(context).size.width/2-175),
          top: (MediaQuery.of(context).size.height/(this.selectedTrack.name.length > 20 ? 1.3 : 1.4)),
          child: Container(
            width: 350,
            child: Text(
              this.selectedTrack.artist,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: this.trackTextSize, fontWeight: FontWeight.w200),
            )
          )
        ),
      ],
    );
  }

  Widget widgetLittlePlayer() {
    return Stack(
      key: ValueKey('LittlePlayer'),
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(this.selectedTrack.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              width: MediaQuery.of(context).size.width-this.sideMarg,
              height:  MediaQuery.of(context).size.height,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
            )
          ],
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: _animationDuration),
          top: (MediaQuery.of(context).size.height/2+MediaQuery.of(context).size.height/2.1)*
           (this.verticalUpdateValue == 0 ? this.verticalUpdateValue : this.verticalUpdateValue-0.1)
           +20*(1-this.verticalUpdateValue),
          right: ((MediaQuery.of(context).size.width/2)-this.playButtonSize/2)*this.verticalUpdateValue+15*(1-this.verticalUpdateValue),
          child: InkWell(
            child: Icon(
              Icons.play_arrow,
              size: this.playButtonSize,
            )
          )
        ),
        Visibility(
          visible: (this.skipElements == 0 ? false : true),
          child: AnimatedPositioned(
            duration: Duration(milliseconds: _animationDuration),
            top: (MediaQuery.of(context).size.height/2+MediaQuery.of(context).size.height/2.3)*
             (this.verticalUpdateValue == 0 ? this.verticalUpdateValue : this.verticalUpdateValue-0.1)
             +20*(1-this.verticalUpdateValue),
            right: (MediaQuery.of(context).size.width/2)-190,
            child: Opacity(
              opacity: this.skipElements,
              child: InkWell(
                child: Text(this.selectedTrack.totalDuration.toString().split(':')[1]
                 +":"+this.selectedTrack.totalDuration.toString().split(':')[2].split(".")[0])
              )
            )
          )
        ),
        Visibility(
          visible: (this.skipElements == 0 ? false : true),
          child: AnimatedPositioned(
            duration: Duration(milliseconds: _animationDuration),
            top: (MediaQuery.of(context).size.height/2+MediaQuery.of(context).size.height/2.3)*
             (this.verticalUpdateValue == 0 ? this.verticalUpdateValue : this.verticalUpdateValue-0.1)
             +20*(1-this.verticalUpdateValue),
            left: (MediaQuery.of(context).size.width/2)-190,
            child: Opacity(
              opacity: this.skipElements,
              child: InkWell(
                child: Text(this.selectedTrack.currentDuration.toString().split(':')[1]
                 +":"+this.selectedTrack.currentDuration.toString().split(':')[2].split(".")[0])
              )
            )
          )
        ),
        Visibility(
          visible: (this.skipElements == 0 ? false : true),
          child: AnimatedPositioned(
            duration: Duration(milliseconds: _animationDuration),
            top: (MediaQuery.of(context).size.height/2+MediaQuery.of(context).size.height/2.4)*
             (this.verticalUpdateValue == 0 ? this.verticalUpdateValue : this.verticalUpdateValue-0.1)
             +20*(1-this.verticalUpdateValue),
            left: MediaQuery.of(context).size.width/2-((MediaQuery.of(context).size.width-(MediaQuery.of(context).size.width/4))/2),
            child: Opacity(
              opacity: this.skipElements,
              child: Container(
                width: MediaQuery.of(context).size.width-(MediaQuery.of(context).size.width/4),
                child: Slider.adaptive(
                  value: (this.selectedTrack.currentDuration.inSeconds / this.selectedTrack.totalDuration.inSeconds < 0
                   || this.selectedTrack.currentDuration.inSeconds / this.selectedTrack.totalDuration.inSeconds > 1 ?
                   0.0 :
                   this.selectedTrack.currentDuration.inSeconds / this.selectedTrack.totalDuration.inSeconds),
                  onChanged: (double value) {  },
                  min: 0,
                  max: 1,
                  activeColor: Colors.cyanAccent,
                )
              )
            )
          )
        ),
        Visibility(
          visible: (this.skipElements == 0 ? false : true),
          child: AnimatedPositioned(
            duration: Duration(milliseconds: _animationDuration),
            top: (MediaQuery.of(context).size.height/2+MediaQuery.of(context).size.height/2.1)*
             (this.verticalUpdateValue == 0 ? this.verticalUpdateValue : this.verticalUpdateValue-0.1)
             +20*(1-this.verticalUpdateValue),
            right: (MediaQuery.of(context).size.width/2)-90,
            child: Opacity(
              opacity: this.skipElements,
              child: InkWell(
                child: Icon(
                  Icons.skip_next,
                  size: this.playButtonSize,
                )
              )
            )
          )
        ),
        Visibility(
          visible: (this.skipElements == 0 ? false : true),
          child: AnimatedPositioned(
            duration: Duration(milliseconds: _animationDuration),
            top: (MediaQuery.of(context).size.height/2+MediaQuery.of(context).size.height/2.1)*
             (this.verticalUpdateValue == 0 ? this.verticalUpdateValue : this.verticalUpdateValue-0.1)
             +20*(1-this.verticalUpdateValue),
            left: (MediaQuery.of(context).size.width/2)-90,
            child: Opacity(
              opacity: this.skipElements,
              child: InkWell(
                child: Icon(
                  Icons.skip_previous,
                  size: this.playButtonSize,
                )
              )
            )
          )
        ),
        Visibility(
          visible: (this.skipElements == 0 ? false : true),
          child: AnimatedPositioned(
            duration: Duration(milliseconds: _animationDuration),
            top: (MediaQuery.of(context).size.height/2+MediaQuery.of(context).size.height/2.05)*
             (this.verticalUpdateValue == 0 ? this.verticalUpdateValue : this.verticalUpdateValue-0.1)
             +20*(1-this.verticalUpdateValue),
            right: (MediaQuery.of(context).size.width/2)-150,
            child: Opacity(
              opacity: this.skipElements,
              child: InkWell(
                child: Icon(
                  Icons.repeat,
                  size: this.playButtonSize-20,
                )
              )
            )
          )
        ),
        Visibility(
          visible: (this.skipElements == 0 ? false : true),
          child: AnimatedPositioned(
            duration: Duration(milliseconds: _animationDuration),
            top: (MediaQuery.of(context).size.height/2+MediaQuery.of(context).size.height/2.05)*
             (this.verticalUpdateValue == 0 ? this.verticalUpdateValue : this.verticalUpdateValue-0.1)
             +20*(1-this.verticalUpdateValue),
            left: (MediaQuery.of(context).size.width/2)-150,
            child: Opacity(
              opacity: this.skipElements,
              child: InkWell(
                child: Icon(
                  Icons.shuffle,
                  size: this.playButtonSize-20,
                )
              )
            )
          )
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: _animationDuration),
          width: this.imageSize,
          height: this.imageSize,
          left: (MediaQuery.of(context).size.width/2-(this.imageSize/2)-this.sideMarg)*this.verticalUpdateValue,
          top: (MediaQuery.of(context).size.height/4)*this.verticalUpdateValue,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(this.selectedTrack.imageUrl),
              )
            ),
          ),
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: _animationDuration),
          left: (MediaQuery.of(context).size.width/2-175)*this.verticalUpdateValue+80*(1-this.verticalUpdateValue),
          top: (MediaQuery.of(context).size.height/1.5)*this.verticalUpdateValue+7*(1-this.verticalUpdateValue),
          child: Container(
            width: (this.verticalUpdateValue == 0 ? 250 : 350),
            child: Text(
              this.selectedTrack.name,
              textAlign: (this.verticalUpdateValue == 0 ? TextAlign.start : TextAlign.center),
              style: TextStyle(fontSize: this.trackTextSize),
            )
          )
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: _animationDuration),
          left: (MediaQuery.of(context).size.width/2-175)*this.verticalUpdateValue+80*(1-this.verticalUpdateValue),
          top: (MediaQuery.of(context).size.height/
           (this.selectedTrack.name.length > 20 ? 1.3 : 1.4))*
           this.verticalUpdateValue+43*(1-this.verticalUpdateValue),
          child: Container(
            width: 350,
            child: Text(
              this.selectedTrack.artist,
              textAlign: (this.verticalUpdateValue == 0 ? TextAlign.start : TextAlign.center),
              style: TextStyle(fontSize: this.trackTextSize, fontWeight: FontWeight.w200),
            )
          )
        ),
      ],
    );
  }




  void verticalDragUpdate(DragUpdateDetails details) {
    _animationDuration = 0;
    FocusScope.of(context).unfocus();
    double perc = 1-((details.localPosition.dy*100/MediaQuery.of(context).size.height)/100);
    double height = MediaQuery.of(context).size.height*perc;
    if(details.delta.direction > 0) this.mainPlayer = widgetLittlePlayer();
    if((details.delta.dy > 0 && this.mainPlayer.key != ValueKey('LargePlayer'))
     || (details.delta.dy > 0 && this.mainPlayer.key == ValueKey('LargePlayer'))
     || (details.delta.dy < 0 && this.mainPlayer.key != ValueKey('LargePlayer'))) {
      setState(() {
        this.verticalUpdateValue = perc;
        this.sideMarg = 20*(1-perc);
        if(this.heightMarg > 65) {
          this.botBarHeight = 56*(1-perc);
          this.imageSize = this.verticalUpdateValue*300+65;
          if(this.verticalUpdateValue>=0.5) this.playButtonSize = 50*this.verticalUpdateValue;
          if(this.verticalUpdateValue>=0.5) this.trackTextSize = 30*this.verticalUpdateValue;
          this.skipElements = 1*this.verticalUpdateValue;
        } else {
          this.botBarHeight = 56;
          this.imageSize = 65;
          this.playButtonSize = 25;
          this.trackTextSize = 14;
          this.skipElements = 0;
        }
        if(height >= 0) this.heightMarg = height;
        else this.heightMarg = 0;
      });
    }
  }

  void verticalDragEnd(DragEndDetails details) {
    _animationDuration = 200;
    if(details.primaryVelocity>=0 && this.heightMarg <= 65) {
      moveToLittlePlayer(0, 0);
      setPlaying(null);
    } else if(details.primaryVelocity>=0 && this.heightMarg > 65) {
      if(details.primaryVelocity==0 && this.heightMarg > (MediaQuery.of(context).size.height)/2) moveToLargePlayer();
      else moveToLittlePlayer(65, 5);
    } else moveToLargePlayer();
  }

  void moveToLargePlayer() {
    setState(() {
      this.verticalUpdateValue = 1;
      this.bottomMarg = 0;
      this.heightMarg = MediaQuery.of(context).size.height;
      this.sideMarg = 0;
      this.botBarHeight = 0;
      this.imageSize = 300;
      this.playButtonSize = 50;
      this.skipElements = 1;
      this.trackTextSize = 30;
    });
    Future.delayed(Duration(milliseconds: _animationDuration), () {
      setState(() {
        this.mainPlayer = widgetLargePlayer();
      });
    });
  }

  void moveToLittlePlayer(double height, double marg) {
    setState(() {
      this.verticalUpdateValue = 0;
      this.bottomMarg = marg;
      this.heightMarg = height;
      this.sideMarg = 20;
      this.botBarHeight = 56;
      this.imageSize = 65;
      this.playButtonSize = 25;
      this.skipElements = 0;
      this.trackTextSize = 14;
      this.mainPlayer = widgetLittlePlayer();
    });
  }

  void horizontalDragUpdate(DragUpdateDetails details) {
    //print(details.delta.dx);
  }

  void horizontalDragEnd(DragEndDetails details) {
    for(PlatformsController ctrl in PlatformsLister.platforms.values) {
      ctrl.updateStates();
    }
    if(details.primaryVelocity < 0) {
      moveToNextTrack();
    } else if(details.primaryVelocity > 0) {
      moveToPreviousTrack();
    }
  }


  void moveToNextTrack() {
    for(Track t in GlobalQueue.queue) {
      print(t.name);
    }
    Track nextTrack = this.selectedTrack;
    if(GlobalQueue.queue.indexOf(this.selectedTrack)+1 < GlobalQueue.queue.length) {
      print("id");
      nextTrack = GlobalQueue.queue[GlobalQueue.queue.indexOf(this.selectedTrack)+1];
      GlobalQueue.currentQueueIndex = GlobalQueue.queue.indexOf(this.selectedTrack)+1;
    }
    print("---------");
    print(nextTrack.name);
    setPlaying(nextTrack);
  }

  void moveToPreviousTrack() {
    Track previousTrack = this.selectedTrack;
    if(GlobalQueue.queue.indexOf(this.selectedTrack)-1 >= 0) {
      previousTrack = GlobalQueue.queue[GlobalQueue.queue.indexOf(this.selectedTrack)-1];
      GlobalQueue.currentQueueIndex--;
    }
    setPlaying(previousTrack);
  }



  


  @override
  Widget build(BuildContext context) {


    if(this.mainPlayer == null || this.mainPlayer.key == ValueKey('LittlePlayer')) {
      if(this.verticalUpdateValue == null) this.verticalUpdateValue = 0;
      if(this.imageSize == null) this.imageSize = 65;
      if(this.playButtonSize == null) this.playButtonSize = 25;
      if(this.skipElements == null) this.skipElements = 0;
      if(this.trackTextSize == null) this.trackTextSize = 14;
      this.mainPlayer = widgetLittlePlayer();
    }
    else this.mainPlayer = widgetLargePlayer();


    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: this.pageController,
              physics: NeverScrollableScrollPhysics(),
              children: this.pages,
            ),
            GestureDetector(
              onTap: () {
                _animationDuration = 250;
                moveToLargePlayer();
              },
              onHorizontalDragUpdate: (details) => horizontalDragUpdate(details),
              onHorizontalDragEnd: (details) => horizontalDragEnd(details),
              onVerticalDragUpdate: (details) => verticalDragUpdate(details),
              onVerticalDragEnd: (details) => verticalDragEnd(details),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: this.visbible,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 250),
                    onEnd: () {
                      setState(() {
                        this.visbible = false;
                      });
                    },
                    opacity: this.opacity,
                    child: AnimatedContainer(
                      margin: EdgeInsets.only(bottom: this.bottomMarg),
                      width: MediaQuery.of(context).size.width-this.sideMarg,
                      height: this.heightMarg,
                      duration: Duration(milliseconds: _animationDuration),
                      child: this.mainPlayer
                    )
                  )
                )
              )
            )
          ]
        ),
        bottomNavigationBar: Container(
          height: this.botBarHeight,
          child:(this.heightMarg <= 65 ?
          BottomNavigationBar(
            items: <BottomNavigationBarItem> [
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: 'Bibliotèque',
                backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
                backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Profile',
                backgroundColor: Colors.black
              ),
            ],
            currentIndex: this.selectedIndex,
            onTap: this.onItemTapped,
          )
          : Container()
          )
        )
      )
    );
  }
}
