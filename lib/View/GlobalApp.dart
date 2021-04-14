import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/PlayerFrontController.dart';
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

  PlayerFrontController playerFrontController;

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
                imageUrl: 'https://source.unsplash.com/random',
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
    this.initPage();
    super.initState();
  }

  void initPage() {
    this.playerFrontController = new PlayerFrontController();
    Widget playlistsPage = new PlaylistsPage(setPlaying: this.playerFrontController.setPlaying);
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

  
  

  @override
  Widget build(BuildContext context) {

    this.playerFrontController.build(context);

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
              this.playerFrontController.widget
            ]),
            bottomNavigationBar: Container(
                height: this.playerFrontController.botBarHeight,
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
