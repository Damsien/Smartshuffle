import 'dart:io';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';

import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:device_apps/device_apps.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/GlobalApp.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsView.dart';


class PlaylistsPage extends StatefulWidget {

  final MaterialColor materialColor = MaterialColorApplication.material_color;

  @override
  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  Key key = UniqueKey();
  Key tabKey = UniqueKey();

  bool exitPage = true;
  TabController _tabController;
  ValueNotifier<int> initialTabIndex = ValueNotifier<int>(0);

  Map<ServicesLister, PlatformsController> userPlatforms = new Map<ServicesLister, PlatformsController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
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
    List elements = new List<Widget>();
    for(MapEntry elem in this.userPlatforms.entries) {
      elements.add(Tab(icon: ImageIcon(AssetImage(elem.value.getPlatformInformations()['icon']))));
    }
    return TabBar(
      controller: this._tabController,
      indicatorColor: this.widget.materialColor.shade300,
      tabs: elements,
    );
  }

  void userPlatformsInit() {
    this.userPlatforms.clear();
    int i=0;
    for(MapEntry<ServicesLister, PlatformsController> elem in PlatformsLister.platforms.entries) {
      elem.value.setPlaylistsPageState(this);
      if(elem.value.getUserInformations()['isConnected'] == true)
        this.userPlatforms[elem.key] = elem.value;
    }
  }


  @override
  Widget build(BuildContext context) {

    userPlatformsInit();
    _tabController = TabController(initialIndex: initialTabIndex.value, length: this.userPlatforms.length, vsync: this);

    List elements = List<Widget>();
    for(MapEntry elem in this.userPlatforms.entries) {
      elements.add(Tab(icon: ImageIcon(AssetImage(elem.value.getPlatformInformations()['icon']))));
    }


    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: this.widget.materialColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        accentColor: this.widget.materialColor.shade100
      ),
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
      home: Container(
        key: this.tabKey,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: TabBar(
              controller: _tabController,
              indicatorColor: this.widget.materialColor.shade300,
              tabs: elements
            ),
            foregroundColor: this.widget.materialColor.shade300,
          ),
          body: WillPopScope(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_tabController.length, (index) {
                return Container(
                  key: PageStorageKey(PlatformsLister.getAllControllers()[index].platform.name),
                  child: TabView(PlatformsLister.getAllControllers()[index]),
                );
              }),
            ),
            onWillPop: () async {
              if(this._tabController.index == 0) exitDialog();
              else this._tabController.animateTo(0);
              return false;
            },
          )
        )
        )
      );
    
  }
}