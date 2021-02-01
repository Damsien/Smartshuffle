import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/PlatformsLister.dart';
import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
import 'package:smartshuffle/Model/Object/TrackInformations.dart';

import 'Pages/Playlists/PlaylistsPage.dart';
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

  int selectedIndex;
  Widget currentPage;


  void fakers() {
    for(MapEntry elem in PlatformsLister.platforms.entries) {
      PlatformsController ctrl = elem.value;
      for(int i=0; i<10; i++) {
        PlaylistInformations playlist = ctrl.addPlaylist(PlaylistInformations(
          ctrl.platform.name+" n°$i",
          image: Image(image: NetworkImage('https://picsum.photos/200/300'))
        ));
        int playlistId = playlist.id;
        for(int j=0; j<Random().nextInt(70); j++) {
          ctrl.addTrackToPlaylist(playlistId, 
            TrackInformations("Track n°$j", "Artist n°$j", 
              Duration(
                minutes: Random().nextInt(4),
                seconds: Random().nextInt(59)
              ),
              "some data"
            )
          );
        }
      }
    }
  }

  @override
  void initState() {
    this.fakers();
    this.initPage();
    super.initState();
  }

  void initPage() {
    Widget playlistsPage = new PlaylistsPageMain();
    Widget searchPage = new SearchPageMain();
    Widget profilePage = new ProfilePageMain();
    setState(() {
      this.pages = [playlistsPage, searchPage, profilePage];
      this.currentPage = this.pages[0];
      this.selectedIndex = 0;
      this.pageController = PageController(initialPage: selectedIndex);
    });
  }

  

  void onItemTapped(int index) {
    setState(() {
      this.selectedIndex = index;
      this.pageController.jumpToPage(index);
    });
  }




  /*Widget globalMaterial() {
    return Stack(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height
          ),
          child: Container(
            child: this.currentPage,
            color: Colors.black54,
          )
        ),
        /*Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 3,
            color: Colors.black
          )
        )*/
      ],
    );
  }*/


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: PageView(
          controller: this.pageController,
          physics: NeverScrollableScrollPhysics(),
          children: this.pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem> [
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: 'Playlists',
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
      )
    );
  }
}
