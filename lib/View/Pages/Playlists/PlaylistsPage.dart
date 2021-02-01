import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/PlatformsLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';

import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
import 'package:device_apps/device_apps.dart';

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

class _PlaylistsPageState extends State<PlaylistsPage> with AutomaticKeepAliveClientMixin {

  Key key = UniqueKey();

  Map userPlatforms = new Map();
  List<bool> isTracksListView = new List<bool>();
  List<Widget> tabView;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  // TODO: Fix try catch doesn't work
  openApp(Platform platform) async {
    try {
      DeviceApps.openApp(platform.platformInformations['uri']);
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
                  ctrl.platform.addPlaylist(PlaylistInformations(value));
                });
              },
            )
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }

  
  openPlaylist(int tabIndex, PlaylistInformations playlist) {
    Container tracks = Container(
      child: Text(playlist.name)
    );
    setState(() {
      this.tabView.removeAt(tabIndex);
      this.isTracksListView.insert(tabIndex, true);
      this.tabView.insert(tabIndex, tracks);
      this.key = UniqueKey();
    });
    for(var el in this.tabView) {
      print(el);
    }
  }



  void removePlaylist(BuildContext context, PlatformsController ctrl, PlaylistInformations playlist) {
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
                  ctrl.removePlaylist(playlist.id);
                });
              },
            )
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }
  void renamePlaylist(BuildContext context, PlaylistInformations playlist) {
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
  playlistOption(PlatformsController ctrl, PlaylistInformations playlist) {
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
                  onPressed: () => removePlaylist(dialogContext, ctrl, playlist),
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


  Widget generatePlaylist(int tabIndex, PlatformsController ctrl) {

    List<PlaylistInformations> playlists = ctrl.getPlaylists();
    return Theme(
      key: PageStorageKey('TabBarView:'+ctrl.platform.name),
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
              key: ValueKey('ReorderableListView:$index'),
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
                          onLongPress: () => playlistOption(ctrl, playlists.elementAt(index)),
                          onTap: () => openPlaylist(tabIndex, playlists.elementAt(index)),
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


  List<Widget> tab() {
    List elements = new List<Widget>();
    int i=0;
    for(MapEntry elem in this.userPlatforms.entries) {
      //if(this.tabView.elementAt)
      elements.add(generatePlaylist(i, elem.value));
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
      tabs: elements,
    );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    this.userPlatforms.clear();
    for(MapEntry elem in PlatformsLister.platforms.entries) {
      elem.value.setPlaylistsPageState(this);
      if(elem.value.getUserInformations()['isConnected'] == true) {
        this.userPlatforms[elem.key] = elem.value;
        this.isTracksListView.add(false);
      }
    }
    this.tabView = tab();
    for(var el in this.tabView) {
      print(el);
    }

    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: this.userPlatforms.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Playlists"),
            bottom: tabBar()
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black54,
            child: TabBarView(
              children: this.tabView,
            ),
          )
        )
      )
    );
    
  }
}