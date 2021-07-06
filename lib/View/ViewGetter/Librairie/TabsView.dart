
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/services.dart';
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/Controller/Players/FrontPlayer.dart';
import 'package:smartshuffle/Controller/Players/Youtube/SearchAlgorithm.dart';
import 'package:smartshuffle/View/GlobalApp.dart';
import 'package:smartshuffle/View/ViewGetter/FormsView.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsPopupItems.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformDefaultController.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';


class TracksCreator extends StatefulWidget {

  MaterialColor materialColor = MaterialColorApplication.material_color;

  int tabIndex;
  PlatformsController ctrl;
  Playlist playlist;
  Function setResearch;
  Function returnToPlaylist;
  bool notResearch;
  List<Widget> researchList;

  TracksCreator(this.tabIndex, {
    @required this.ctrl, @required this.playlist, @required this.setResearch, @required this.returnToPlaylist, this.notResearch, this.researchList
  });

  @override
  State<StatefulWidget> createState() => _TracksCreatorState();

}

class _TracksCreatorState extends State<TracksCreator> {

  int tabIndex;
  PlatformsController ctrl;
  Playlist playlist;
  Function setResearch;
  Function returnToPlaylist;
  bool notResearch;
  List<Widget> researchList;

  @override
  void init() {
    tabIndex = widget.tabIndex;
    ctrl = widget.ctrl;
    playlist = widget.playlist;
    setResearch = widget.setResearch;
    returnToPlaylist = widget.returnToPlaylist;
    notResearch = widget.notResearch;
    researchList = widget.researchList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Track>>(
      future: ctrl.getTracks(playlist),
      builder: (BuildContext context, AsyncSnapshot<List<Track>> snapshot) {
        Widget finalWidget;

        if(snapshot.hasData) {

          List<Track> tracks = snapshot.data;

          ScrollController scrollCtrl = ScrollController();
          

          finalWidget = WillPopScope(
            child: Theme(
              data: ThemeData(
                brightness: Brightness.dark,
                canvasColor: Colors.transparent
              ),
              child: Container(
                color: Colors.black54,
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: WidgetsBinding.instance.window.physicalSize.width,
                            height: 165,
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 30, bottom: 20),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => returnToPlaylist(tabIndex),
                                        child: Container(
                                          child: Icon(Icons.arrow_back, size: 30),
                                          margin: EdgeInsets.all(5),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width/2,
                                            child: InkWell(
                                              onTap: () => TabsView(this).renamePlaylist(playlist),
                                              child: Text(
                                                playlist.name, 
                                                style: ((300/playlist.name.length+5) > 30 ?
                                                  TextStyle(fontSize: 30) :
                                                  TextStyle(fontSize: (300/playlist.name.length+5).toDouble())
                                                ),
                                              )
                                            )
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width/2,
                                            child: Text(
                                              playlist.ownerName, 
                                              style: ((300/playlist.ownerName.length+5) > 30 ?
                                                TextStyle(fontSize: 20) :
                                                TextStyle(fontSize: (200/playlist.ownerName.length+5).toDouble())
                                              ),
                                            )
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ),
                                InkWell(
                                  onTap: () => {  },
                                  child: FractionallySizedBox(
                                    heightFactor: 0.5,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: new Container(
                                        decoration: new BoxDecoration(
                                          image: new DecorationImage(
                                            fit: BoxFit.cover,
                                            alignment: FractionalOffset.center,
                                            image: NetworkImage(playlist.imageUrl),
                                          )
                                        ),
                                      ),
                                    )
                                  )
                                ),
                              ]
                            ),
                          ),
                          Container(
                            width: WidgetsBinding.instance.window.physicalSize.width,
                            child: ListTile(
                              subtitle: Container(
                                height: 45,
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                    labelText: AppLocalizations.of(context).search+"..",
                                    filled: true,
                                  ),
                                  onChanged: (val) {
                                    setResearch(ctrl, playlist, val, tracks);
                                  },
                                )
                              ),
                              trailing: InkWell(
                                child: PopupMenuButton(
                                  icon: Icon(Icons.sort),
                                  tooltip: AppLocalizations.of(context).tabsViewSort,
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                    SortPopupItemLastAdded(playlist).build(context),
                                    SortPopupItemTitle(playlist).build(context),
                                    SortPopupItemArtist(playlist).build(context)
                                  ],
                                  onSelected: (value) {
                                    setState(() {
                                      tracks = playlist.sort(value);
                                    });
                                  },
                                )
                              )
                            )
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 17, right: 17),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width/2.5,
                                  margin: EdgeInsets.only(top: 5, bottom: 10),
                                  child: MaterialButton(
                                    onPressed: () => FrontPlayerController().createQueueAndPlay(playlist, isShuffle: false),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(Icons.play_arrow),
                                        Text(AppLocalizations.of(context).tabsViewPlayingSimple,
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    shape: ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: BorderSide(color: widget.materialColor.shade700)
                                    ),
                                  )
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width/2.5,
                                  margin: EdgeInsets.only(top: 5, bottom: 10),
                                  child: MaterialButton(
                                    onPressed: () => FrontPlayerController().createQueueAndPlay(playlist, isShuffle: true),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(Icons.shuffle),
                                        Text(AppLocalizations.of(context).tabsViewPlayingShuffle,
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    shape: ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: BorderSide(color: widget.materialColor.shade700)
                                    ),
                                  )
                                ),
                              ],
                            ),
                          ),
                        ]
                      ),
                      Visibility(
                        visible: notResearch,
                        child: Container(
                          height: 80*tracks.length.toDouble(),
                          child: ListView.builder (
                            controller: scrollCtrl,
                            itemCount: tracks.length,
                            itemBuilder: (buildContext, index) => GenerateTrack(tracks[index], index, ctrl: ctrl, playlist: playlist),
                          )
                        )
                      ),
                      Visibility(
                        visible: !notResearch,
                        child: Container(
                          height: 80*researchList.length.toDouble(),
                          child: ListView(
                            controller: scrollCtrl,
                            children: researchList,
                          )
                        )
                      )
                    ]
                  )
                )
              )
            ),
            onWillPop: () async {
              if(!notResearch) {
                setResearch(null, null, '', null);
                return false;
              } else {
                returnToPlaylist(tabIndex);
                return false;
              }
            },
          );


        } else {


          finalWidget = Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()
                );
             

        }



        return finalWidget;
      }
    );
  }
  
}


class GenerateTrack extends StatefulWidget {
  
  int index;
  Track track;
  PlatformsController ctrl;
  Playlist playlist;

  MaterialColor materialColor = MaterialColorApplication.material_color;

  GenerateTrack(this.track, this.index, {@required this.ctrl, @required this.playlist});

  @override
  State<StatefulWidget> createState() => _GenerateTrackState();

}

class _GenerateTrackState extends State<GenerateTrack> {

  int index;
  Track track;
  Playlist playlist;
  PlatformsController ctrl;

  @override
  void init() {
    index = widget.index;
    track = widget.track;
    playlist = widget.playlist;
    ctrl = widget.ctrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
    key: ValueKey('ListView:Tracks:$index'),
    margin: EdgeInsets.only(left: 20, right: 20, bottom: 0),
    child: GestureDetector(
      onTap: () {
        FrontPlayerController().createQueueAndPlay(playlist, track: widget.track);
      },
      onDoubleTap: () {
        TabsView(this).addToQueue(track);
        String trackName = track.name;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            action: SnackBarAction(
              label: AppLocalizations.of(context).cancel,
              onPressed: () => GlobalQueue().removeLastPermanent()
            ),
            duration: Duration(seconds: 1),
            content: Text("$trackName " + AppLocalizations.of(context).tabsViewAddedToQueue),
          )
        );
        /*Fluttertoast.showToast(
          msg: "$trackName ajouté à la file d'attente",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );*/
      },
      onLongPressStart: (LongPressStartDetails detail) => TabsView(this).trackMainOptions(track, ctrl: ctrl, index: ctrl.platform.playlists.value.indexOf(playlist), detail: detail),
      child: Card(
          child: ListTile(
            title: ValueListenableBuilder(
              valueListenable: track.isSelected,
              builder: (_, value, __) {
                return Text(
                  track.name,
                  style: (value ?
                    TextStyle(color: Colors.cyanAccent) : TextStyle(color: Colors.white)
                  )
                );
              }
            ),
            leading: FractionallySizedBox(
              heightFactor: 0.8,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      fit: BoxFit.fitHeight,
                      alignment: FractionalOffset.center,
                      image: NetworkImage(track.imageUrlLittle),
                    )
                  ),
                )
              )
            ),
            subtitle: Text(track.artist),
            trailing: FractionallySizedBox(
              heightFactor: 1,
              child: TabsView(this).trackMainDialog(track, ctrl:ctrl, index: ctrl.platform.playlists.value.indexOf(playlist)),
            ),
          )
        )
      )
    );
  }
  
}


class GeneratePlaylist extends StatefulWidget {

  int tabIndex;
  MapEntry<ServicesLister, PlatformsController> platforms;
  Function openPlaylist;

  MaterialColor materialColor = MaterialColorApplication.material_color;

  GeneratePlaylist(this.tabIndex, {@required this.platforms, @required this.openPlaylist});

  @override
  State<StatefulWidget> createState() => _GeneratePlaylistState();
}

class _GeneratePlaylistState extends State<GeneratePlaylist> {


  @override
  Widget build(BuildContext context) {
    PlatformsController ctrl = widget.platforms.value;

    return FutureBuilder<List<Playlist>>(
      future: ctrl.getPlaylists(),
      builder: (BuildContext context, AsyncSnapshot<List<Playlist>> snapshot) {
        Widget finalWidget;
        
        if(snapshot.hasData) {

          
          List<Playlist> realPlaylists = snapshot.data;
          finalWidget = Container(
            key: PageStorageKey('TabBarView:'+ctrl.platform.name+':Playlists'),
            color: Colors.black54,
            child: RefreshIndicator(
              key: UniqueKey(),
              onRefresh: () async {
                List<Playlist> plays = await ctrl.getPlaylists(refreshing: true);
                setState(() {
                  realPlaylists = plays;
                });
              },
              child: ValueListenableBuilder(
                valueListenable: ctrl.getPlaylistsUpdate(),
                builder: (_, List<Playlist> playlists, __) {
                  return ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) {
                      playlists = ctrl.platform.reorder(oldIndex, newIndex);
                    },
                    header: Container(
                      width: WidgetsBinding.instance.window.physicalSize.width,
                      height: 165,
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
                                child: MaterialButton(
                                  shape: ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                  onPressed: () => TabsView(this).createPlaylist(ctrl),
                                  colorBrightness: Brightness.dark,
                                  color: Colors.grey[800],
                                  child: Wrap(
                                    spacing: 8.0,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Icon(Icons.add), Text(AppLocalizations.of(context).tabsViewAddAPlaylist)
                                    ]
                                  )
                                )
                              ),
                            ]
                          ),
                          InkWell(
                            onTap: () => TabsView(this).openApp(ctrl.platform),
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
                          margin: EdgeInsets.only(bottom: 5),
                          //color: (index % 2 == 0 ? Colors.grey[800] : Colors.grey[850]),
                          child: InkWell(
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 5,
                                  child: GestureDetector(
                                    child: ListTile(
                                      title: Text(playlists.elementAt(index).name),
                                      leading: FractionallySizedBox(
                                        heightFactor: 1,
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Container(
                                            decoration: new BoxDecoration(
                                              image: new DecorationImage(
                                                fit: BoxFit.cover,
                                                alignment: FractionalOffset.center,
                                                image: NetworkImage(playlists.elementAt(index).imageUrl),
                                              )
                                            ),
                                          ),
                                        )
                                      ),
                                      subtitle: Text(playlists.elementAt(index).tracks.length.toString()+" "+AppLocalizations.of(context).globalTracks),
                                      onTap: () => widget.openPlaylist(widget.tabIndex, widget.platforms, playlists.elementAt(index)),
                                    ),
                                    onLongPressStart: (LongPressStartDetails detail) => TabsView(this).playlistMainOptions(playlists[index], ctrl: ctrl, index: index, detail: detail),
                                  )
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 20, right: 20),
                                    child: Icon(Icons.drag_handle)
                                  )
                                )
                              ]
                            )
                          )
                        );
                      }
                    )..add(
                      Container(
                        key: UniqueKey(),
                        height: 80,
                      )
                    )
                  );
                }
              )
            )
            
          );



        } else {


          finalWidget = Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()
                );
                
        }

        return finalWidget;

      });
  }
  
}



class TabsView {

  State state;
  
  static final TabsView _tabsView = TabsView._instance();

  MaterialColor materialColor = MaterialColorApplication.material_color;

  factory TabsView(State state) {
    _tabsView.state = state;
    return _tabsView;
  }

  TabsView._instance();

  static final String TracksView = 'Tracks';
  static final String PlaylistsView = 'Playlists';




  List<Widget> playlistsCreator({
    @required Map<ServicesLister, PlatformsController> userPlatforms,
    @required List<String> distributions,
    @required Function openPlaylist
  }) {
    List elements = new List<Widget>(userPlatforms.length);

    int i=0;
    for(MapEntry<ServicesLister, PlatformsController> elem in userPlatforms.entries) {
      if(distributions[i] != TabsView.TracksView)
        elements[i] = GeneratePlaylist(i, platforms: elem, openPlaylist: openPlaylist);
      i++;
    }
    return elements;
  }




  
  // TODO: Fix try catch doesn't work
  void openApp(Platform platform) async {
    try {
      DeviceApps.openApp(platform.platformInformations['package']);
    } catch (error) {
      showDialog(
        context: this.state.context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(AppLocalizations.of(this.state.context).globalNotFoundApp, style: TextStyle(color: Colors.white)),
            content: Text(AppLocalizations.of(this.state.context).globalNotFoundAppDesc),
            contentTextStyle: TextStyle(color: Colors.white),
            actions: [
              FlatButton(
                child: Text(AppLocalizations.of(this.state.context).ok, style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(dialogContext),
              )
            ],
            backgroundColor: Colors.grey[800],
          );
        }
      );
    }
  }


  /*  TRACKS VIEW   */


  List<Widget> tracksListGenerator(List<Track> tracks, {
    @required PlatformsController ctrl,
    @required Playlist playlist
  }) {
    return List.generate(
      tracks.length,
      (index) {
        return GenerateTrack(tracks[index], index, ctrl: ctrl, playlist: playlist);
      }
    );
  }





  /* CRUD TRACKS  */



  void trackMainDialogOptions(String value, {
    @required Track track,
    String name,
    PlatformsController ctrl,
    int index,
    Function refresh
  }) {
    switch(value) {
      case PopupMenuConstants.TRACKSMAINDIALOG_ADDTOQUEUE: {
        ScaffoldMessenger.of(this.state.context).showSnackBar(
          SnackBar(
            action: SnackBarAction(
              label: AppLocalizations.of(this.state.context).cancel,
              onPressed: () => GlobalQueue().removeLastPermanent()
            ),
            duration: Duration(seconds: 1),
            content: Text("$name "+AppLocalizations.of(this.state.context).tabsViewAddedToQueue),
          )
        );
        addToQueue(track);
      } break;
      case PopupMenuConstants.TRACKSMAINDIALOG_ADDTOANOTHERPLAYLIST: {
        addToPlaylist(track, ctrl: ctrl);
      } break;
      case PopupMenuConstants.TRACKSMAINDIALOG_REMOVEFROMPLAYLIST: {
        removeFromPlaylist(track, ctrl: ctrl, playlistIndex: index, refresh: refresh);
      } break;
      case PopupMenuConstants.TRACKSMAINDIALOG_INFORMATIONS: {
        trackInformations(track, ctrl: ctrl);
      } break;
      case PopupMenuConstants.TRACKSMAINDIALOG_REPORT : {
        openReportForm(track);
      } break;
    }
  }


  PopupMenuButton trackMainDialog(Track track, {
    @required PlatformsController ctrl,
    @required int index,
    Function refresh
  }) {
    String name = track.name;

    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      tooltip: AppLocalizations.of(this.state.context).options,
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        TracksPopupItemAddToQueue().build(context),
        TracksPopupItemAddToAnotherPlaylist().build(context),
        TracksPopupItemRemoveFromPlaylist().build(context),
        TracksPopupItemInformations().build(context),
        TracksPopupItemReport().build(context)
      ],
      onSelected: (value) {
        trackMainDialogOptions(value, name: name, ctrl: ctrl, track: track, index: index, refresh: refresh);
      },
    );
  }

  void trackMainOptions(Track track, {
    @required PlatformsController ctrl,
    @required int index,
    @required LongPressStartDetails detail,
    Function refresh
  }) async {
    HapticFeedback.lightImpact();
    String name = track.name;

    await showMenu(
        context: this.state.context,
        position: RelativeRect.fromLTRB(detail.globalPosition.dx, detail.globalPosition.dy,
         MediaQuery.of(this.state.context).size.width - detail.globalPosition.dx, MediaQuery.of(this.state.context).size.height - detail.globalPosition.dy),
        items: [
          TracksPopupItemAddToQueue().build(this.state.context),
          TracksPopupItemAddToAnotherPlaylist().build(this.state.context),
          TracksPopupItemRemoveFromPlaylist().build(this.state.context),
          TracksPopupItemInformations().build(this.state.context),
          TracksPopupItemReport().build(this.state.context)
        ],
        elevation: 8.0,
      ).then((value){
        trackMainDialogOptions(value, name: name, ctrl: ctrl, track: track, index: index, refresh: refresh);
      }
    );
  }


  void addToPlaylist(Track track, {@required PlatformsController ctrl}) {
    String name = track.name;
    String ctrlName = ctrl.platform.name;
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$name', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: FlatButton(
                  child: Text(AppLocalizations.of(this.state.context).tabsViewAddToService+" SmartShuffle", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    choosePlaylistToAddTrack(track, ctrl: PlatformsLister.platforms[ServicesLister.DEFAULT]);
                  },
                ),
              ),
              () {
                if(ctrl.platform.name != PlatformsLister.platforms[ServicesLister.DEFAULT].platform.name) {
                  return Container(
                    child: FlatButton(
                      child: Text(AppLocalizations.of(this.state.context).tabsViewAddToService+" $ctrlName", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        choosePlaylistToAddTrack(track, ctrl: ctrl);
                      },
                    ),
                  );
                }
                return Container();
              }.call(),
              Container(
                child: FlatButton(
                  child: Text(AppLocalizations.of(this.state.context).cancel, style: TextStyle(color: Colors.white)),
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


  void choosePlaylistToAddTrack(Track track, {@required PlatformsController ctrl}) {
    List<Widget> allCards;
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(this.state.context).tabsViewChooseAPlaylist, style: TextStyle(color: Colors.white)),
          contentPadding: EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: () {
                allCards = List.generate(
                  ctrl.platform.playlists.value.length,
                  (index) {

                    if(ctrl.platform.playlists.value[index].ownerId == ctrl.getUserInformations()['ownerId']) {
                      return ListTile(
                                title: Text(ctrl.platform.playlists.value[index].name),
                                leading: FractionallySizedBox(
                                  heightFactor: 0.8,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          alignment: FractionalOffset.center,
                                          image: NetworkImage(ctrl.platform.playlists.value[index].imageUrl),
                                        )
                                      ),
                                    ),
                                  )
                                ),
                                subtitle: Text(ctrl.platform.playlists.value[index].getTracks.length.toString() + " "+AppLocalizations.of(this.state.context).globalTracks),
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                  String id = ctrl.addTrackToPlaylist(index, track, false);
                                  if(id == null) {
                                    showDialog(
                                      context: this.state.context,
                                      builder: (dialogContext) {
                                        return AlertDialog(
                                          title: Text(AppLocalizations.of(this.state.context).tabsViewTrackAlreadyExists, style: TextStyle(color: Colors.white)),
                                          actions: [
                                            FlatButton(
                                              child: Text(AppLocalizations.of(this.state.context).no, style: TextStyle(color: Colors.white)),
                                              onPressed: () => Navigator.pop(dialogContext),
                                            ),
                                            FlatButton(
                                              child: Text(AppLocalizations.of(this.state.context).yes, style: TextStyle(color: Colors.white)),
                                              onPressed: () {
                                                Navigator.pop(dialogContext);
                                                this.state.setState(() {
                                                  ctrl.addTrackToPlaylist(index, track, true);
                                                });
                                              },
                                            )
                                          ],
                                          backgroundColor: Colors.grey[800],
                                        );
                                      }
                                    );
                                  }
                                },
                      );
                    }
                    return Container();
                  }
                );
                allCards.add(
                  Container(
                    child: FlatButton(
                      child: Text(AppLocalizations.of(this.state.context).cancel, style: TextStyle(color: Colors.white)),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                );
                return allCards;
              }.call()
            )
          ),
          backgroundColor: Colors.grey[900],
        );
      }
    );
  }


  void addToQueue(Track track) {
    this.state.setState(() {
      GlobalQueue().addToPermanentQueue(track);
    });
  }


  void removeFromPlaylist(Track track, {
    @required PlatformsController ctrl,
    @required int playlistIndex,
    Function refresh
  }) {
    String name = track.name;
    String playlistName = ctrl.platform.playlists.value[playlistIndex].name;
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(this.state.context).remove+" $name "+AppLocalizations.of(this.state.context).from+" $playlistName ?", style: TextStyle(color: Colors.white)),
          actions: [
            FlatButton(
              child: Text(AppLocalizations.of(this.state.context).cancel, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FlatButton(
              child: Text(AppLocalizations.of(this.state.context).confirm, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                int trackIndex = ctrl.platform.playlists.value[playlistIndex].getTracks.indexOf(track);
                this.state.setState(() {
                  ctrl.removeTrackFromPlaylist(playlistIndex, trackIndex);
                  if(refresh != null) refresh(null, null, '', null, null);
                });
              },
            ),
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }


  void trackInformations(Track track, {@required PlatformsController ctrl}) {
    String name = track.name;
    String artist = track.artist;
    String artist_string = AppLocalizations.of(this.state.context).globalArtist;
    if(artist.contains(',')) artist_string = AppLocalizations.of(this.state.context).globalArtists;
    String album;
    if(track.album != null) album = track.album;
    else album = AppLocalizations.of(this.state.context).nothing;
    String service = track.serviceName.toString();
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Wrap(
            children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    height: MediaQuery.of(dialogContext).size.width*0.7,
                    child: Image(image: NetworkImage(track.imageUrlLarge), fit: BoxFit.cover)
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.all(10),
                    child: Text(AppLocalizations.of(this.state.context).popupItemTitle+": $name", style: TextStyle(fontSize: 25))
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Text("$artist_string: $artist", style: TextStyle(fontSize: 17))
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Text(AppLocalizations.of(this.state.context).globalAlbum+": $album", style: TextStyle(fontSize: 17))
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Text(AppLocalizations.of(this.state.context).globalService+": $service", style: TextStyle(fontSize: 17))
                  ),
                ]
              )
            ]
          ),
          actions: [
            FlatButton(
              child: Text(AppLocalizations.of(this.state.context).ok, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        );
      }
    );
  }


  void openReportForm(Track track) {
    Navigator.of(this.state.context)
      .push(
        MaterialPageRoute(
          builder: (context) => FormReport(materialColor: materialColor, track: track)
        )
      );
  }





  /*  CRUD PLAYLISTS  */

  void playlistMainOptions(Playlist playlist, {
    @required PlatformsController ctrl,
    @required int index,
    @required LongPressStartDetails detail
  }) async {
    HapticFeedback.lightImpact();
    String name = playlist.name;

    List<PopupMenuEntry> items = [];
    items.add(PlaylistsPopupItemRename().build(this.state.context));
    if(ctrl.platform.name != 'SmartShuffle')  items.add(PlaylistsPopupItemClone().build(this.state.context));
    if(ctrl.platform.name != 'SmartShuffle')  items.add(PlaylistsPopupItemMerge().build(this.state.context));
    items.add(PlaylistsPopupItemDelete().build(this.state.context));

    await showMenu(
        context: this.state.context,
        position: RelativeRect.fromLTRB(detail.globalPosition.dx, detail.globalPosition.dy,
         MediaQuery.of(this.state.context).size.width - detail.globalPosition.dx, MediaQuery.of(this.state.context).size.height - detail.globalPosition.dy),
        items: items,
        elevation: 8.0,
      ).then((value){
        playlistMainDialogOptions(playlist, value, ctrl: ctrl, name: name, index: index);
      }
    );
  }

  void playlistMainDialogOptions(Playlist playlist, String value, {
    @required PlatformsController ctrl, 
    @required String name,
    @required int index
  }) {
    switch(value) {
      case PopupMenuConstants.PLAYLISTSMAINDIALOG_RENAME: {
        renamePlaylist(playlist);
      } break;
      case PopupMenuConstants.PLAYLISTSMAINDIALOG_CLONE: {
        clonePlaylist(playlist, ctrl: ctrl);
      } break;
      case PopupMenuConstants.PLAYLISTSMAINDIALOG_MERGE: {
        mergePlaylist(playlist, ctrl: ctrl);
      } break;
      case PopupMenuConstants.PLAYLISTSMAINDIALOG_DELETE: {
        removePlaylist(playlist, ctrl: ctrl, index: index);
      } break;
    }
  }

  void createPlaylist(PlatformsController ctrl) {
    String value = AppLocalizations.of(this.state.context).globalPlaylist + " " + ctrl.platform.name + " n°" + ctrl.platform.playlists.value.length.toString();

    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(this.state.context).tabsViewCreateAPlaylist, style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    labelText: AppLocalizations.of(this.state.context).tabsViewNameOfPlaylist
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
            MaterialButton(
              child: Text(AppLocalizations.of(this.state.context).cancel, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            MaterialButton(
              child: Text(AppLocalizations.of(this.state.context).confirm, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                this.state.setState(() {
                  ctrl.addPlaylist(name: value, ownerId: ctrl.getPlatformInformations()['ownerId']);
                });
              },
            ),
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }


  void removePlaylist(Playlist playlist, {
    @required PlatformsController ctrl,
    @required int index
  }) {
    String name = playlist.name;

    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(this.state.context).delete+" $name ?", style: TextStyle(color: Colors.white)),
          content: Text(AppLocalizations.of(this.state.context).tabsViewRemoveMessage),
          contentTextStyle: TextStyle(color: Colors.white),
          actions: [
            MaterialButton(
              child: Text(AppLocalizations.of(this.state.context).no, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            MaterialButton(
              child: Text(AppLocalizations.of(this.state.context).yes, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                this.state.setState(() {
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

  void renamePlaylist(Playlist playlist) {
    String name = playlist.name;
    String value = playlist.name;

    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(this.state.context).globalRename+" $name", style: TextStyle(color: Colors.white)),
          content: TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              labelText: AppLocalizations.of(this.state.context).tabsViewNameOfPlaylist,
            ),
            initialValue: name,
            onChanged: (String val) {
              value = val;
            },
          ),
          actions: [
            MaterialButton(
              child: Text(AppLocalizations.of(this.state.context).cancel, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            MaterialButton(
              child: Text(AppLocalizations.of(this.state.context).confirm, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                this.state.setState(() {
                  playlist.rename(value);
                });
              },
            ),
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }

  void clonePlaylist(Playlist playlist, {@required PlatformsController ctrl}) {
    String name = playlist.name;
    
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(this.state.context).globalClone+" $name "+ AppLocalizations.of(this.state.context).globalIn+ " SmartShuffle ?", style: TextStyle(color: Colors.white)),
          actions: [
            MaterialButton(
              child: Text(AppLocalizations.of(this.state.context).no, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            MaterialButton(
              child: Text(AppLocalizations.of(this.state.context).yes, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                Playlist play;
                this.state.setState(() {
                  play = PlatformsLister.platforms[ServicesLister.DEFAULT].addPlaylist(playlist: playlist);
                });
                if(play == null) {
                  showDialog(
                    context: this.state.context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: Text("$name "+AppLocalizations.of(this.state.context).tabsViewAlreadyExists+" "+ AppLocalizations.of(this.state.context).globalIn+" SmartShuffle", style: TextStyle(color: Colors.white)),
                        actions: [
                          FlatButton(
                            child: Text(AppLocalizations.of(this.state.context).ok, style: TextStyle(color: Colors.white)),
                            onPressed: () => Navigator.pop(dialogContext),
                          )
                        ],
                        backgroundColor: Colors.grey[800],
                      );
                    }
                  );
                }
              },
            )
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }

  void mergePlaylist(Playlist playlist, {@required PlatformsController ctrl}) {
    String name = playlist.name;
    List<Widget> allCards;
    PlatformsController defaultCtrl = PlatformsLister.platforms[ServicesLister.DEFAULT];
    
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(this.state.context).tabsViewChoosePlaylistToMerge+" $name", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: () {
                allCards = List.generate(
                  defaultCtrl.platform.playlists.value.length,
                  (index) {
                    return Theme(
                      data: ThemeData(
                        brightness: Brightness.dark
                      ),
                      child: Container(
                        child: Card(
                          child: ListTile(
                            title: Text(defaultCtrl.platform.playlists.value[index].name),
                            leading: FractionallySizedBox(
                              heightFactor: 0.8,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: new Container(
                                  decoration: new BoxDecoration(
                                    image: new DecorationImage(
                                      fit: BoxFit.fitHeight,
                                      alignment: FractionalOffset.center,
                                      image: NetworkImage(defaultCtrl.platform.playlists.value[index].imageUrl),
                                    )
                                  ),
                                ),
                              )
                            ),
                            subtitle: Text(ctrl.platform.playlists.value[index].getTracks.length.toString() + " "+AppLocalizations.of(this.state.context).globalTracks),
                            onTap: () {
                              Navigator.pop(dialogContext);
                              //TODO Message de confirmation
                              defaultCtrl.mergePlaylist(defaultCtrl.platform.playlists.value[index], playlist);
                            },
                          )
                        )
                      )
                    );
                  }
                );
                allCards.add(
                  Container(
                    child: MaterialButton(
                      child: Text(AppLocalizations.of(this.state.context).cancel, style: TextStyle(color: Colors.white)),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                );
                return allCards;
              }.call()
            )
          ),
          backgroundColor: Colors.black,
        );
      }
    );
  }


}