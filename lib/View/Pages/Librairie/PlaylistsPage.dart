import 'dart:io';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smartshuffle/Controller/AppManager/AppInit.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/FrontPlayer.dart';

import 'package:smartshuffle/Model/Util.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsView.dart';


class PlaylistsPage extends StatefulWidget {

  PlaylistsPage({Key key}) : super(key: key);

  @override
  PlaylistsPageState createState() => PlaylistsPageState();
}

class PlaylistsPageState extends State<PlaylistsPage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  final MaterialColor _materialColor = GlobalTheme.material_color;
  final ThemeData _themeData = GlobalTheme.themeData;

  Key key = UniqueKey();
  Key tabKey = UniqueKey();

  bool exitPage = true;
  TabController tabController;
  ValueNotifier<int> initialTabIndex = ValueNotifier<int>(0);

  Map<ServicesLister, PlatformsController> userPlatforms = new Map<ServicesLister, PlatformsController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    FrontPlayerController().addView('playlist', this);
    super.initState();
  }




  void exitDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).globalQuit, style: TextStyle(color: Colors.white)),
          actions: [
            FlatButton(child: Text(AppLocalizations.of(context).no, style: TextStyle(color: Colors.white)), onPressed: () => Navigator.pop(dialogContext)),
            FlatButton(child: Text(AppLocalizations.of(context).yes, style: TextStyle(color: Colors.white)), onPressed: () => exit(0)),
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }




  Widget tabBar() {
    List elements = <Widget>[];
    for(MapEntry elem in this.userPlatforms.entries) {
      elements.add(Tab(icon: ImageIcon(AssetImage(elem.value.platformInformations['icon']))));
    }
    return TabBar(
      controller: this.tabController,
      indicatorColor: _materialColor.shade300,
      tabs: elements,
    );
  }

  void userPlatformsInit() {
    this.userPlatforms.clear();
    for(MapEntry<ServicesLister, PlatformsController> elem in PlatformsLister.platforms.entries) {
      if(elem.value.userInformations['isConnected'] == true)
        this.userPlatforms[elem.key] = elem.value;
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    StatesManager.setPlaylistsPageState(this);

    userPlatformsInit();
    tabController = TabController(initialIndex: initialTabIndex.value, length: this.userPlatforms.length, vsync: this);

    List elements = <Widget>[];
    for(MapEntry elem in this.userPlatforms.entries) {
      elements.add(Tab(icon: ImageIcon(AssetImage(elem.value.platformInformations['icon']))));
    }

    return MaterialApp(
      theme: _themeData,
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
      home: Scaffold(
        key: this.tabKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: TabBar(
            controller: tabController,
            indicatorColor: _materialColor.shade300,
            tabs: elements
          ),
          foregroundColor: _materialColor.shade300,
        ),
        body: TabBarView(
          controller: tabController,
          children: List.generate(tabController.length, (index) {
            return Container(
              key: PageStorageKey(GlobalAppController.getAllConnectedControllers()[index].platform.name),
              child: TabView(GlobalAppController.getAllConnectedControllers()[index], parent: this),
            );
          }),
        ),
      )
    );
    
  }
}