import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';

import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:device_apps/device_apps.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsView.dart';

class PlaylistsPageMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playlists',
      debugShowCheckedModeBanner: false,
      home: new PlaylistsPage(title: 'Playlists'),
    );
  }
}

class PlaylistsPage extends StatefulWidget {

  final String title;
  
  PlaylistsPage({Key key, this.title}) : super(key: key);

  @override
  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  Key key = UniqueKey();
  Key tabKey = UniqueKey();

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


  /*
  bool returnToPlaylist(ServicesLister element) {
    setState(() {
      this.tracksViews[element][1] = false;
    });
    //this.tabListener(element: element);
    setState(() { this.exitPage = true; });
    return false;
  }
  


  openPlaylist(int tabIndex, MapEntry elem, Playlist playlist) {
    List<Track> tracks = playlist.getTracks();
    PlatformsController ctrl = elem.value;
    Key reorderKey = UniqueKey();

    WillPopScope tracksWidget = WillPopScope(
      key: PageStorageKey('TabBarView:'+ctrl.platform.name+':Playlist['+playlist.id.toString()+']:Tracks'),
      onWillPop: () async {
        return returnToPlaylist(elem.key);
      },
      child: Theme(
        data: ThemeData(
          brightness: Brightness.dark,
          canvasColor: Colors.transparent
        ),
        child: ReorderableListView(
          key: reorderKey,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              tracks = playlist.reorder(oldIndex, newIndex);
              this.tabKey = UniqueKey();
            });
          },
          header: Container(
            width: WidgetsBinding.instance.window.physicalSize.width,
            height: 165,
            margin: EdgeInsets.only(left: 30, right: 30, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => {},//renamePlaylist(context, playlist),
                  child: Container(
                    margin: EdgeInsets.only(top: 30, bottom: 20),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => returnToPlaylist(elem.key),
                          child: Container(
                            child: Icon(Icons.arrow_back),
                            margin: EdgeInsets.all(5),
                          ),
                        ),
                        Text(playlist.name, style: TextStyle(fontSize: 30))
                      ],
                    )
                  )
                ),
                InkWell(
                  onTap: () => {  },
                  child: FractionallySizedBox(
                    heightFactor: 0.5,
                    child: playlist.image
                  )
                )
              ]
            )
          ),
          children: List.generate(
            tracks.length,
            (index) {
              return Container(
                key: ValueKey('ReorderableListView:Tracks:$index'),
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 0),
                child: InkWell(
                  child: Card(
                    child: Row(
                      children: [
                        Flexible(
                          flex: 5,
                          child: ListTile(
                            title: Text(tracks.elementAt(index).name),
                            leading: FractionallySizedBox(
                              heightFactor: 0.8,
                              child: tracks.elementAt(index).image
                            ),
                            subtitle: Text(tracks.elementAt(index).artist),
                            onLongPress: () {},
                            onTap: () {},
                          )
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(left:20, right: 20),
                            child: Icon(Icons.drag_handle)
                          )
                        )
                      ]
                    )
                  )
                )
              );
            }
          )
        )
      )
    );
    setState(() {
      this.tracksViews[elem.key] = [tracksWidget, true];
      this.tabView[this._tabController.index] = tracksWidget;
      this.initialTabIndex = tabIndex;
      this.tabKey = UniqueKey();
    });
    this._tabController.notifyListeners();
  }
*/

  void tabListener({ServicesLister element}) {
    /*int index = this._tabController.index;
    if(this.tabView[index].key.toString().contains('Tracks')) {
      setState(() { this.exitPage = false; this.initialTabIndex = index; });
    } else {
      setState(() { this.exitPage = true; this.initialTabIndex = index; });
    }
    print(this.tabView[index].key.toString());
    print(this._tabController.index);
    print(this.exitPage);*/
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
    this._tabController.addListener( () => tabListener());

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
                    this.tabsView[i] = TabsView.getInstance(this).tracksCreator(i, this.tracksList[i].key, this.tracksList[i].value, onReorderTracks, returnToPlaylist);
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