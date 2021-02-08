import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

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
      PlatformsController ctrl = PlatformsLister.platforms[ServicesLister.DEFAULT];
      for(int i=0; i<10; i++) {
        ctrl.addPlaylist(
          ctrl.platform.name+" n°$i",
          image: Image(image: NetworkImage('https://picsum.photos/200/300'))
        );
      }
      for(int i=0; i<10; i++) {
        for(int j=0; j<Random().nextInt(70); j++) {
          ctrl.addTrackToPlaylist(i, 
            Track(
              name: "Track n°$j", 
              artist: "Artist n°$i", 
              duration: Duration(
                minutes: Random().nextInt(4),
                seconds: Random().nextInt(59)
              ),
              service: ServicesLister.DEFAULT,
              image: Image(image: NetworkImage('https://picsum.photos/400/400')),
              id: j
            )
          );
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
