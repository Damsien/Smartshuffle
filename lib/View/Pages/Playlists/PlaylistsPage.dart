import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/PlatformsLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/PlaylistInformations.dart';
import 'package:smartshuffle/Model/Object/TrackInformations.dart';

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

class _PlaylistsPageState extends State<PlaylistsPage> {




  openApp(Platform platform) {
    //Lauch platform app with platform.platformInformations['uri']
  }


  createPlaylist() {
    //Popup of playlist creation
  }

  
  openPlaylist() {
    print("d");
  }


  Widget generatePlaylist(PlatformsController ctrl) {
    List playlists = ctrl.getPlaylists();
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        canvasColor: Colors.transparent
      ),
      child: ReorderableListView(
        onReorder: (int oldIndex, int newIndex) { 
          setState(() {
            var elem = playlists.removeAt(oldIndex);
            playlists.insert(newIndex, elem);
          });
        },
        header: Container(
          width: MediaQuery.of(context).size.width,
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
                      onPressed: () { createPlaylist(); },
                      colorBrightness: Brightness.dark,
                      color: Colors.grey[800],
                      child: Wrap(
                        spacing: 8.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(Icons.add), Text("Créer une playlist")
                        ]
                      )
                    )
                  ),
                ]
              ),
              InkWell(
                onTap: openApp(ctrl.platform),
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
              key: ValueKey(index),
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: Card(
                child: ListTile(
                  title: Text(playlists.elementAt(index).name),
                  leading: FractionallySizedBox(
                    heightFactor: 0.8,
                    child: playlists.elementAt(index).image
                  ),
                  subtitle: Text(playlists.elementAt(index).tracks.length.toString()+" tracks"),
                  trailing: Icon(Icons.drag_handle),
                )
              ),
            );
          }
        )
      )
    );
  }


  List<Widget> tab() {
    List elements = new List<Widget>();
    for(MapEntry elem in PlatformsLister.platforms.entries) {
      elements.add(generatePlaylist(elem.value));
    }
    return elements;
  }


  Widget tabBar() {
    List elements = new List<Widget>();
    for(MapEntry elem in PlatformsLister.platforms.entries) {
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
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: PlatformsLister.platforms.length,
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
                children: tab(),
              ),
          )
        )
      )
    );
    
  }
}