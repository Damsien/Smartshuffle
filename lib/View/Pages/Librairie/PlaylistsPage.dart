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
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsView.dart';


class PlaylistsPage extends StatefulWidget {

  final Function setPlaying;
  final MaterialColor materialColor;
  
  PlaylistsPage({Key key, this.setPlaying, this.materialColor}) : super(key: key);

  @override
  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  Key key = UniqueKey();
  Key tabKey = UniqueKey();

  List<bool> notResearch;
  List<Widget> researchList = List<Widget>();

  bool exitPage = true;
  TabController _tabController;
  ValueNotifier<int> initialTabIndex = ValueNotifier<int>(0);

  List<MapEntry<PlatformsController, Playlist>> tracksList;

  List<String> distribution;

  List<Widget> tabsView;
  Map<ServicesLister, PlatformsController> userPlatforms = new Map<ServicesLister, PlatformsController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }




  onReorderPlaylists(PlatformsController ctrl, List<Playlist> playlists, int oldIndex, int newIndex) {
    playlists = ctrl.platform.reorder(oldIndex, newIndex);
    this.initialTabIndex.value = _tabController.index;
  }

  openPlaylist(int tabIndex, MapEntry<ServicesLister, PlatformsController> elem, Playlist playlist) {
    setState(() {
      this.distribution[tabIndex] = TabsView.TracksView;
      this.tracksList[tabIndex] = MapEntry(elem.value, playlist);
      this.initialTabIndex.value = _tabController.index;
      this.tabKey = UniqueKey();
    });
  }

  

  onReorderTracks(PlatformsController ctrl, Playlist playlist, List<Track> tracks, int oldIndex, int newIndex) {
    setState(() {
      tracks = playlist.reorder(oldIndex, newIndex);
      this.initialTabIndex.value = _tabController.index;
    });
  }

  returnToPlaylist(int tabIndex) {
    setState(() {
      this.distribution[tabIndex] = TabsView.PlaylistsView;
      this.initialTabIndex.value = _tabController.index;
      this.tabKey = UniqueKey();
    });
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

  setResearch(PlatformsController ctrl, Playlist playlist, String value, List<Track> tracks) {

    setState(() {
      this.initialTabIndex.value = _tabController.index;
      if(value != '')
        this.notResearch[_tabController.index] = false;
      else
        this.notResearch[_tabController.index] = true;
    });

    if(value != '') {
      List<Track> temp = new List<Track>();
      for(Track track in tracks) {
        if(track.name.contains(value) || track.name.toLowerCase().contains(value)
        || track.artist.contains(value) || track.artist.toLowerCase().contains(value)) {
          temp.add(track);
        }
      }
      setState(() {
        this.researchList.clear();
        this.researchList = TabsView(this).tracksListGenerator(temp, ctrl, playlist, this.setPlaying);
      });
    }
  }

  setPlaying(Track track, bool queueCreate, {Playlist playlist, PlatformsController platformCtrl, bool isShuffle, bool isRepeatOnce, bool isRepeatAlways}) {
    //setState(() {
      this.initialTabIndex.value = _tabController.index;
      widget.setPlaying(track, queueCreate,
       playlist: playlist,
       platformCtrl: platformCtrl,
       isShuffle: isShuffle,
       isRepeatOnce: isRepeatOnce,
       isRepeatAlways: isRepeatAlways);
    //});
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


  tabConstructor(List<Widget> list) {
    userPlatformsInit();
    tabInitialization();
  }

   userPlatformsInit() {
    this.userPlatforms.clear();
    int i=0;
    for(MapEntry<ServicesLister, PlatformsController> elem in PlatformsLister.platforms.entries) {
      elem.value.setPlaylistsPageState(this);
      if(elem.value.getUserInformations()['isConnected'] == true)
        this.userPlatforms[elem.key] = elem.value;
    }
    if(this.distribution == null || this.distribution.length != this.userPlatforms.length)
      this.distribution = List<String>(this.userPlatforms.length);
    for(int i=0; i<this.distribution.length; i++) {
      if(this.distribution[i] == null || this.distribution[i] != TabsView.TracksView)
        this.distribution[i] = TabsView.PlaylistsView;
    }
    if(this.tracksList == null || this.tracksList.length != this.userPlatforms.length)
      this.tracksList = List<MapEntry<PlatformsController, Playlist>>(this.userPlatforms.length);
    if(this.notResearch == null || this.notResearch.length != this.userPlatforms.length) {
      this.notResearch = List<bool>(this.userPlatforms.length);
      for(int i=0; i<this.userPlatforms.length; i++) {
        this.notResearch[i] = true;
      }
    }
  }

  tabInitialization() {
    this.tabsView = List<Widget>(this.userPlatforms.length);
  
    for(int i=0; i<this.userPlatforms.length; i++) {
      this.tabsView[i] = Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()
                );
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    tabConstructor(this.tabsView);

    if(this.initialTabIndex.value >= this.userPlatforms.length)
      this.initialTabIndex.value = 0;
    this._tabController = new TabController(
      length: this.userPlatforms.length,
      initialIndex: this.initialTabIndex.value,
      vsync: this
    );

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
            title: tabBar(),
            foregroundColor: this.widget.materialColor.shade300,
          ),
          body: TabBarView(
            controller: this._tabController,
            children: () {
              List<Widget> allTabs = TabsView(this).playlistsCreator(this.userPlatforms, this.distribution, onReorderPlaylists, openPlaylist, this.widget.materialColor);
              
              for(int i=0; i<allTabs.length; i++) {
                setState(() {
                  if(allTabs[i] != null) {
                    this.tabsView[i] = WillPopScope(
                                        child: allTabs[i],
                                        onWillPop: () async {
                                          if(this._tabController.index == 0) exitDialog();
                                          else this._tabController.animateTo(0);
                                          return false;
                                        },
                                      );
                  } else {
                    this.tabsView[i] = allTabs[i];
                  }
                });
              }
              for(int i=0; i<this.distribution.length; i++) {
                if(this.distribution[i] == TabsView.TracksView) {
                  setState(() {
                    this.tabsView[i] = TabsView(this).tracksCreator(i, this.tracksList[i].key, this.tracksList[i].value, researchList, this.notResearch[i], setResearch, onReorderTracks, returnToPlaylist, setPlaying, this.widget.materialColor);
                  });
                }
              }
              return this.tabsView;
            }.call(),
          ),
        )
        )
      );
    
  }
}