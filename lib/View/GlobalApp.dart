import 'dart:developer';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smartshuffle/Controller/AppManager/AppInit.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Players/FrontPlayer.dart';
import 'package:smartshuffle/Model/Util.dart';
import 'package:smartshuffle/View/ViewGetter/FrontPlayerView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/View/Pages/Librairie/PlaylistsPage.dart';

import 'Pages/Profile/ProfilePage.dart';
import 'Pages/Search/SearchPage.dart';

class GlobalAppMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr', ''),
        const Locale('en', ''),
      ],
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

class GlobalApp extends State<_GlobalApp> with TickerProviderStateMixin, WidgetsBindingObserver {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController;
  List<Widget> pages;

  Map<ServicesLister, PlatformsController> userPlatforms =
      new Map<ServicesLister, PlatformsController>();

  int selectedIndex;
  Widget currentPage;

  ThemeData _themeData = GlobalTheme.themeData;

  final MaterialColor materialColor = GlobalTheme.material_color;

  // void fakers() {
  //   PlatformsController ctrl =
  //       PlatformsLister.platforms[ServicesLister.SMARTSHUFFLE];
  //   for (int i = 0; i < 10; i++) {
  //     ctrl.addPlaylist(
  //         name: ctrl.platform.name + ' n°$i',
  //         imageUrl: 'https://source.unsplash.com/random',
  //         ownerId: '',
  //         ownerName: 'Damien');
  //   }
  //   for (int i = 0; i < 10; i++) {
  //     for (int j = 0; j < Random().nextInt(70); j++) {
  //       ctrl.addTrackToPlaylist(
  //           i,
  //           Track(
  //               name: 'Track n°$j',
  //               artist: 'Artist n°$i',
  //               totalDuration: Duration(
  //                   minutes: Random().nextInt(4),
  //                   seconds: Random().nextInt(59)),
  //               service: ServicesLister.SMARTSHUFFLE,
  //               imageUrlLittle: 'https://source.unsplash.com/random',
  //               imageUrlLarge: 'https://source.unsplash.com/random',
  //               id: j.toString()),
  //           true);
  //     }
  //   }
  // }

  void refresh() {
    setState(() {});
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
        AudioService.stop();
      break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  void dispose() {
    AudioService.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addObserver(this);
    this.initPage();
    super.initState();
    GlobalAppController.initApp(this);
  }

  void initPage() {

    Widget playlistsPage = new PlaylistsPage();
    Widget searchPage = new SearchPageMain();
    Widget profilePage = new ProfilePage();
    setState(() {
      this.pages = [playlistsPage, searchPage, profilePage];
      this.currentPage = this.pages[0];
      this.selectedIndex = 0;
      this.pageController = PageController(initialPage: selectedIndex) ;
    });
    for (MapEntry<ServicesLister, PlatformsController> elem
        in PlatformsLister.platforms.entries) {
      if (elem.value.userInformations['isConnected'] == true)
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
    SnackBarController().key = _scaffoldKey;

    return MaterialApp(
        theme: _themeData,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          key: _scaffoldKey,
          body: AudioServiceWidget(
            child: Stack(children: [
              PageView(
                controller: this.pageController,
                physics: NeverScrollableScrollPhysics(),
                children: this.pages,
              ),
              FrontPlayerView(notifyParent: refresh)
            ])
          ),
          bottomNavigationBar: Container(
            color: Colors.grey[900],
            height: FrontPlayerController().botBarHeight,
            child:  BottomNavigationBar(
              backgroundColor: Colors.black,
              selectedItemColor: this.materialColor.shade300,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.library_music),
                    label: AppLocalizations.of(context).globalTitleLibrairie,
                    backgroundColor: Colors.black),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: AppLocalizations.of(context).globalTitleSearch,
                    backgroundColor: Colors.black),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle),
                    label: AppLocalizations.of(context).globalTitleProfile,
                    backgroundColor: Colors.black),
              ],
              currentIndex: this.selectedIndex,
              onTap: this.onItemTapped,
            )
          )
        ),
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr', ''),
        const Locale('en', ''),
      ],
    );
  }
}
