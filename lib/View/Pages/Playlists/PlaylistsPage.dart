import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';

import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:device_apps/device_apps.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

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

  Map userPlatforms = new Map();
  Map tracksViews = new Map();

  bool exitPage = true;
  TabController _tabController;
  int initialTabIndex = 0;
  List<Widget> tabView = new List<Widget>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  // TODO: Fix try catch doesn't work
  openApp(Platform platform) async {
    try {
      DeviceApps.openApp(platform.platformInformations['package']);
    } catch (error) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text("Application introuvble", style: TextStyle(color: Colors.white)),
            content: Text("L'application n'est pas installé ou vous utilisez un appareil IOS"),
            contentTextStyle: TextStyle(color: Colors.white),
            actions: [
              FlatButton(
                child: Text("Ok", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(dialogContext),
              )
            ],
            backgroundColor: Colors.grey[800],
          );
        }
      );
    }
  }



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
                  onTap: () => renamePlaylist(context, playlist),
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


  void tabListener({ServicesLister element}) {
    int index = this._tabController.index;
    if(this.tabView[index].key.toString().contains('Tracks')) {
      setState(() { this.exitPage = false; this.initialTabIndex = index; });
    } else {
      setState(() { this.exitPage = true; this.initialTabIndex = index; });
    }
    print(this.tabView[index].key.toString());
    print(this._tabController.index);
    print(this.exitPage);
  }




  createPlaylist(PlatformsController ctrl) {
    String value = "Playlist " + ctrl.platform.name + " n°" + ctrl.platform.playlists.length.toString();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Créer une playlist", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    labelText: 'Nom de la playlist'
                  ), 
                  onChanged: (String val) {
                    value = val;
                  },
                ),
              )
            ],
          ),
          contentTextStyle: TextStyle(color: Colors.white),
          actions: [
            FlatButton(
              child: Text("Annuler", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FlatButton(
              child: Text("Valider", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  ctrl.addPlaylist(value);
                });
              },
            )
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }


  void removePlaylist(BuildContext context, PlatformsController ctrl, Playlist playlist, int index) {
    Navigator.pop(context);
    String name = playlist.name;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Supprimer $name ?", style: TextStyle(color: Colors.white)),
          content: Text("Il ne sera plus possible de la récupérer après sa suppression !"),
          contentTextStyle: TextStyle(color: Colors.white),
          actions: [
            FlatButton(
              child: Text("Non", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FlatButton(
              child: Text("Oui", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  ctrl.removePlaylist(index);
                });
              },
            )
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }
  void renamePlaylist(BuildContext context, Playlist playlist) {
    Navigator.pop(context);
    String name = playlist.name;
    String value = playlist.name;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Renommer $name", style: TextStyle(color: Colors.white)),
          content: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              labelText: name
            ), 
            onChanged: (String val) {
              value = val;
              print(value);
            },
          ),
          actions: [
            FlatButton(
              child: Text("Annuler", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FlatButton(
              child: Text("Valider", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  playlist.rename(value);
                });
              },
            )
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }
  playlistOption(PlatformsController ctrl, Playlist playlist, int index) {
    String name = playlist.name;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("$name", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: FlatButton(
                  child: Text("Renommer", style: TextStyle(color: Colors.white)),
                  onPressed: () => renamePlaylist(dialogContext, playlist),
                ),
              ),
              Container(
                child: FlatButton(
                  child: Text("Supprimer", style: TextStyle(color: Colors.white)),
                  onPressed: () => removePlaylist(dialogContext, ctrl, playlist, index),
                ),
              ),
              Container(
                child: FlatButton(
                  child: Text("Annuler", style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }


  Future<Widget> generatePlaylist(int tabIndex, MapEntry elem)  async {
    PlatformsController ctrl = elem.value;
    List<Playlist> playlists = await ctrl.getPlaylists();

    return Theme(
      key: PageStorageKey('TabBarView:'+ctrl.platform.name+':Playlists'),
      data: ThemeData(
        brightness: Brightness.dark,
        canvasColor: Colors.transparent
      ),
      child: ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            playlists = ctrl.platform.reorder(oldIndex, newIndex);
          });
        },
        header: Container(
          width: WidgetsBinding.instance.window.physicalSize.width,
          height: 165,
          margin: EdgeInsets.only(left: 30, right: 30, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 30, bottom: 20),
                    child: Text(ctrl.getPlatformInformations()['name'], style: TextStyle(fontSize: 30))
                  ),
                  Container(
                    child: RaisedButton(
                      onPressed: () => createPlaylist(ctrl),
                      colorBrightness: Brightness.dark,
                      color: Colors.grey[800],
                      child: Wrap(
                        spacing: 8.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(Icons.add), Text("Ajouter une playlist")
                        ]
                      )
                    )
                  ),
                ]
              ),
              InkWell(
                onTap: () => openApp(ctrl.platform),
                child: FractionallySizedBox(
                  heightFactor: 0.5,
                  child: Image(image: AssetImage(ctrl.platform.platformInformations['logo']))
                )
              )
            ]
          )
        ),
        children: List.generate(
          playlists.length,
          (index) {
            return Container(
              key: ValueKey('ReorderableListView:Playlists:$index'),
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: InkWell(
                child: Card(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 5,
                        child: ListTile(
                          title: Text(playlists.elementAt(index).name),
                          leading: FractionallySizedBox(
                            heightFactor: 0.8,
                            child: playlists.elementAt(index).image
                          ),
                          subtitle: Text(playlists.elementAt(index).tracks.length.toString()+" tracks"),
                          onLongPress: () => playlistOption(ctrl, playlists.elementAt(index), index),
                          onTap: () => openPlaylist(tabIndex, elem, playlists.elementAt(index)),
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
    );
  }


  Future<List<Widget>> tab() async {
    List<Widget> elements = new List<Widget>();
    int i=0;
    for(MapEntry elem in this.userPlatforms.entries) {
      if(this.tracksViews[elem.key] != null && this.tracksViews[elem.key][1] == true)
        elements.add(this.tracksViews[elem.key][0]);
      else
        elements.add(await generatePlaylist(i, elem));
      i++;
    }
    return elements;
  }


  Widget tabBar() {
    List elements = new List<Widget>();
    for(MapEntry elem in this.userPlatforms.entries) {
      Widget el;
      el = Tab(icon: ImageIcon(AssetImage(elem.value.getPlatformInformations()['icon'])));
      elements.add(el);
    }
    return TabBar(
      controller: this._tabController,
      tabs: elements,
    );
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);

    this.userPlatforms.clear();
    for(MapEntry elem in PlatformsLister.platforms.entries) {
      elem.value.setPlaylistsPageState(this);
      if(elem.value.getUserInformations()['isConnected'] == true)
        this.userPlatforms[elem.key] = elem.value;
    }
    this.tabView = new List<Widget>(this.userPlatforms.length);
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
        child: FutureBuilder(
          future: tab(),
          builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
            Scaffold scaffold;
            this.tabView = snapshot.data;
            if(snapshot.hasData) {
              scaffold = Scaffold(
              appBar: AppBar(
                title: Text("Bibliotèque"),
                bottom: tabBar()
              ),
              body: WillPopScope(
                onWillPop: () async {
                  if(this.exitPage) {
                    if(this._tabController.index != 0) {
                      setState(() {
                        this.initialTabIndex = 0;
                      });
                      this._tabController.animateTo(0);
                    } else {
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
                  }
                  return !this.exitPage;
                },
                child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.black54,
                        child: TabBarView(
                          controller: this._tabController,
                          children: this.tabView,
                        ),
                      )
                    )
              );
            } else {
              scaffold = Scaffold(
                appBar: AppBar(
                  title: Text("Bibliotèque"),
                  bottom: tabBar(),
                ),
                body: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()
                )
              );
            }

            return scaffold;

          },
        )
        
        
        )
      );
    
  }
}