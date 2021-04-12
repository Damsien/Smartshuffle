import 'dart:io';

import 'package:flutter/material.dart';
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
  
  PlaylistsPage({Key key, this.setPlaying}) : super(key: key);

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
  int initialTabIndex = 0;

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
    setState(() {
      playlists = ctrl.platform.reorder(oldIndex, newIndex);
      this.initialTabIndex = _tabController.index;
    });
  }

  openPlaylist(int tabIndex, MapEntry<ServicesLister, PlatformsController> elem, Playlist playlist) {
    setState(() {
      this.distribution[tabIndex] = TabsView.TracksView;
      this.tracksList[tabIndex] = MapEntry(elem.value, playlist);
      this.initialTabIndex = _tabController.index;
      this.tabKey = UniqueKey();
    });
  }

  

  onReorderTracks(PlatformsController ctrl, Playlist playlist, List<Track> tracks, int oldIndex, int newIndex) {
    setState(() {
      tracks = playlist.reorder(oldIndex, newIndex);
      this.initialTabIndex = _tabController.index;
    });
  }

  returnToPlaylist(int tabIndex) {
    setState(() {
      this.distribution[tabIndex] = TabsView.PlaylistsView;
      this.initialTabIndex = _tabController.index;
      this.tabKey = UniqueKey();
    });
  }

  void exitDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Êtes-vous sûr de vouloir quitter l'application ?", style: TextStyle(color: Colors.white)),
          actions: [
            FlatButton(child: Text("Non", style: TextStyle(color: Colors.white)), onPressed: () => Navigator.pop(dialogContext)),
            FlatButton(child: Text("Oui", style: TextStyle(color: Colors.white)), onPressed: () => exit(0)),
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }

  setResearch(PlatformsController ctrl, Playlist playlist, String value, List<Track> tracks, Function trackMainDialog) {

    setState(() {
      this.initialTabIndex = _tabController.index;
      if(value != "")
        this.notResearch[_tabController.index] = false;
      else
        this.notResearch[_tabController.index] = true;
    });

    if(value != "") {
      List<Widget> temp = new List<Widget>();
      int i=0;
      for(Track track in tracks) {
        if(track.name.contains(value) || track.name.toLowerCase().contains(value)
        || track.artist.contains(value) || track.artist.toLowerCase().contains(value)) {
          temp.add(
            Container(
              key: ValueKey('ResearchListView:Tracks:$i'),
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 0),
              child: InkWell(
                child: Card(
                  child: ListTile(
                    title: Text(
                      track.name,
                      style: (track.isPlaying ?
                        TextStyle(color: Colors.cyanAccent) : TextStyle(color: Colors.white)
                      )
                    ),
                    leading: FractionallySizedBox(
                      heightFactor: 0.8,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: new Container(
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              fit: BoxFit.fitHeight,
                              alignment: FractionalOffset.center,
                              image: NetworkImage(track.imageUrl),
                            )
                          ),
                        ),
                      )
                    ),
                    subtitle: Text(track.artist),
                    onLongPress: () => trackMainDialog(ctrl, track, ctrl.platform.playlists.indexOf(playlist), refresh: this.setResearch),
                    trailing: FractionallySizedBox(
                      heightFactor: 1,
                      child: InkWell(
                        child: Icon(Icons.more_vert),
                        onTap: () => trackMainDialog(ctrl, track, ctrl.platform.playlists.indexOf(playlist), refresh: this.setResearch),
                      )
                    ),
                    onTap: () => setPlaying(track, 'unknow', playlist: playlist, platformCtrl: ctrl),
                  )
                )
              )
            )
          );
          i++;
        }
      }
      setState(() {
        this.researchList.clear();
        for(Widget wid in temp)
          this.researchList.add(wid);
      });
    }
  }

  setPlaying(Track track, String playMode, {Playlist playlist, PlatformsController platformCtrl}) {
    setState(() {
      this.initialTabIndex = _tabController.index;
      widget.setPlaying(track, playMode, playlist: playlist, platformCtrl: platformCtrl);
    });
  }




  Widget tabBar() {
    List elements = new List<Widget>();
    for(MapEntry elem in this.userPlatforms.entries) {
      elements.add(Tab(icon: ImageIcon(AssetImage(elem.value.getPlatformInformations()['icon']))));
    }
    return TabBar(
      controller: this._tabController,
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

    if(this.initialTabIndex >= this.userPlatforms.length)
      this.initialTabIndex = 0;
    this._tabController = new TabController(
      length: this.userPlatforms.length,
      initialIndex: this.initialTabIndex,
      vsync: this
    );

    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Container(
        key: this.tabKey,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Bibliotèque"),
            bottom: tabBar()
          ),
          body: TabBarView(
            controller: this._tabController,
            children: () {
              List<Widget> allTabs = TabsView.getInstance(this).playlistsCreator(this.userPlatforms, this.distribution, onReorderPlaylists, openPlaylist);
              
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
                    this.tabsView[i] = TabsView.getInstance(this).tracksCreator(i, this.tracksList[i].key, this.tracksList[i].value, researchList, this.notResearch[i], setResearch, onReorderTracks, returnToPlaylist, setPlaying);
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