import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Players/BackPlayer.dart';
import 'package:smartshuffle/Controller/Players/FrontPlayer.dart';
import 'package:smartshuffle/Model/Object/UsefullWidget/extents_page_view.dart';
import 'package:smartshuffle/View/ViewGetter/FrontPlayerView.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsPopupItems.dart';
import 'package:spotify_sdk/models/player_state.dart';
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


class MaterialColorApplication {

  static Map<int, Color> _colorCodes = {
    50: Colors.yellow[100],
    100: Colors.yellow[200],
    200: Colors.yellow[300],
    300: Colors.yellow[400],
    400: Colors.yellow[500],
    500: Colors.yellow[600],
    600: Colors.yellow[700],
    700: Colors.yellow[800],
    800: Colors.yellow[900]
  };

  static final MaterialColor material_color = MaterialColor(0xFFFDD835, _colorCodes);

}


void _entrypoint() => AudioServiceBackground.run(() => AudioPlayerTask());
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

class GlobalApp extends State<_GlobalApp> with TickerProviderStateMixin {
  static const String SCREEN_VISIBLE = "screen_visible";
  static const String SCREEN_IDLE = "screen_idle";

  ValueNotifier<String> screenState = ValueNotifier<String>(SCREEN_VISIBLE);

  PageController pageController;
  List<Widget> pages;

  Map<ServicesLister, PlatformsController> userPlatforms =
      new Map<ServicesLister, PlatformsController>();

  int selectedIndex;
  Widget currentPage;

  MaterialColor materialColor;

  // void fakers() {
  //   PlatformsController ctrl =
  //       PlatformsLister.platforms[ServicesLister.DEFAULT];
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
  //               service: ServicesLister.DEFAULT,
  //               imageUrlLittle: 'https://source.unsplash.com/random',
  //               imageUrlLarge: 'https://source.unsplash.com/random',
  //               id: j.toString()),
  //           true);
  //     }
  //   }
  // }


  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    this.initPage();
    super.initState();
  }

  void initPage() {


    this.materialColor = MaterialColorApplication.material_color;

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

    const double _botbar_height = 56;

    return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: this.materialColor,
          accentColor: materialColor.shade100,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: AudioServiceWidget(
              child: Stack(children: [
                PageView(
                  controller: this.pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: this.pages,
                ),
                FocusDetector(
                  onVisibilityGained: () {screenState.value = SCREEN_VISIBLE;},
                  onFocusGained: ()  {screenState.value = SCREEN_VISIBLE;},
                  onForegroundGained: ()  {screenState.value = SCREEN_VISIBLE;},
                  onForegroundLost:  () {screenState.value = SCREEN_IDLE;},
                  // onFocusLost:  () {screenState.value = SCREEN_IDLE; print('idle');},
                  onVisibilityLost:   () {screenState.value = SCREEN_IDLE;},
                  child: FrontPlayerView()
                )
              ])
            ),
            bottomNavigationBar: Container(
              height: _botbar_height,
              child:  BottomNavigationBar(
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
