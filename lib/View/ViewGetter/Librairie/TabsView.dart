
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/services.dart';
import 'package:smartshuffle/Controller/GlobalQueue.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsDialog.dart';
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

class TabsView {

  State state;
  
  static final TabsView _tabsView = TabsView._instance();

  factory TabsView(State state) {
    _tabsView.state = state;
    return _tabsView;
  }

  TabsView._instance();

  static final String TracksView = 'Tracks';
  static final String PlaylistsView = 'Playlists';




  List<Widget> playlistsCreator(Map<ServicesLister, PlatformsController> userPlatforms, List<String> distribution, Function onReorder, Function openPlaylist) {
    List elements = new List<Widget>(userPlatforms.length);

    int i=0;
    for(MapEntry<ServicesLister, PlatformsController> elem in userPlatforms.entries) {
      if(distribution[i] != TabsView.TracksView)
        elements[i] = generatePlaylist(i, elem, onReorder, openPlaylist);
      i++;
    }
    return elements;
  }






  Widget generatePlaylist(int tabIndex, MapEntry<ServicesLister, PlatformsController> elem, Function onReorder, Function openPlaylist) {
    PlatformsController ctrl = elem.value;

    return FutureBuilder<List<Playlist>>(
      future: ctrl.getPlaylists(),
      builder: (BuildContext context, AsyncSnapshot<List<Playlist>> snapshot) {
        Widget finalWidget;
        
        if(snapshot.hasData) {

          
          List<Playlist> realPlaylists = snapshot.data;
          finalWidget = Theme(
            key: PageStorageKey('TabBarView:'+ctrl.platform.name+':Playlists'),
            data: ThemeData(
              brightness: Brightness.dark,
            ),
            child: Container(
              color: Colors.black54,
              child: RefreshIndicator(
                key: UniqueKey(),
                onRefresh: () async {
                  List<Playlist> plays = await ctrl.getPlaylists(refreshing: true);
                  this.state.setState(() {
                    realPlaylists = plays;
                  });
                },
                child: ValueListenableBuilder(
                  valueListenable: ctrl.getPlaylistsUpdate(),
                  builder: (_, List<Playlist> playlists, __) {
                    return ReorderableListView(
                      onReorder: (int oldIndex, int newIndex) {
                        onReorder(ctrl, playlists, oldIndex, newIndex);
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
                                  child: RaisedButton(
                                    onPressed: () => createPlaylist(ctrl),
                                    colorBrightness: Brightness.dark,
                                    color: Colors.grey[800],
                                    child: Wrap(
                                      spacing: 8.0,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Icon(Icons.add), Text(AppLocalizations.of(this.state.context).tabsViewAddAPlaylist)
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
                            margin: EdgeInsets.only(bottom: 5),
                            //color: (index % 2 == 0 ? Colors.grey[800] : Colors.grey[850]),
                            child: InkWell(
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: 5,
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
                                      subtitle: Text(playlists.elementAt(index).tracks.length.toString()+" "+AppLocalizations.of(this.state.context).globalTracks),
                                      onLongPress: () => playlistOption(ctrl, playlists.elementAt(index), index),
                                      onTap: () => openPlaylist(tabIndex, elem, playlists.elementAt(index)),
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


  // TODO: Fix try catch doesn't work
  openApp(Platform platform) async {
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


  List<Widget> tracksListGenerator(List<Track> tracks, PlatformsController ctrl, Playlist playlist, Function setPlaying) {
    return List.generate(
                    tracks.length,
                    (index) {

                      /*Dismissible(
                          key: ValueKey('ReorderableListView:Tracks:Dismissible:$index'),
                          /*dismissThresholds: {DismissDirection.startToEnd: double.infinity,
                                              DismissDirection.endToStart: double.infinity},*/
                          direction: dismissDirection,
                          confirmDismiss: (confirm) async {
                            addToQueue(tracks[index]);
                            return false;
                          },
                          background: Card(
                            child: Wrap(
                              alignment: WrapAlignment.end,
                              runAlignment: WrapAlignment.center,
                              children:[
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.playlist_add, size: 30)
                                )
                              ]
                            )
                          ),*/

                      return Container(
                          key: ValueKey('ListView:Tracks:$index'),
                          margin: EdgeInsets.only(left: 20, right: 20, bottom: 0),
                          child: GestureDetector(
                            onTap: () {
                              setPlaying(tracks[index], true, playlist: playlist, platformCtrl: ctrl);
                            },
                            onDoubleTap: () {
                              addToQueue(tracks.elementAt(index));
                              String trackName = tracks.elementAt(index).name;
                              ScaffoldMessenger.of(this.state.context).showSnackBar(
                                SnackBar(
                                  action: SnackBarAction(
                                    label: AppLocalizations.of(this.state.context).cancel,
                                    onPressed: () => GlobalQueue().removeLastPermanent()
                                  ),
                                  duration: Duration(seconds: 1),
                                  content: Text("$trackName " + AppLocalizations.of(this.state.context).tabsViewAddedToQueue),
                                )
                              );
                              /*Fluttertoast.showToast(
                                msg: "$trackName ajouté à la file d'attente",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );*/
                            },
                            onLongPressStart: (LongPressStartDetails detail) => trackMainOptions(ctrl, tracks.elementAt(index), ctrl.platform.playlists.value.indexOf(playlist), detail),
                            child: Card(
                                child: ListTile(
                                  title: ValueListenableBuilder(
                                    valueListenable: tracks[index].isSelected,
                                    builder: (_, value, __) {
                                      return Text(
                                        tracks.elementAt(index).name,
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
                                            image: NetworkImage(tracks.elementAt(index).imageUrlLittle),
                                          )
                                        ),
                                      )
                                    )
                                  ),
                                  subtitle: Text(tracks.elementAt(index).artist),
                                  trailing: FractionallySizedBox(
                                    heightFactor: 1,
                                    child: trackMainDialog(ctrl, tracks.elementAt(index), ctrl.platform.playlists.value.indexOf(playlist)),
                                  ),
                                )
                              )
                            )
                          );
                    }
                  );
  }


  Widget listTracksBuilder(BuildContext buildContext, int index, List<Track> tracks, PlatformsController ctrl, Playlist playlist, Function setPlaying) {
    return Container(
        key: ValueKey('ListView:Tracks:$index'),
        child: GestureDetector(
          onTap: () {
            setPlaying(tracks[index], true, playlist: playlist, platformCtrl: ctrl);
          },
          onDoubleTap: () {
            addToQueue(tracks.elementAt(index));
            String trackName = tracks.elementAt(index).name;
            ScaffoldMessenger.of(this.state.context).showSnackBar(
              SnackBar(
                action: SnackBarAction(
                  label: AppLocalizations.of(this.state.context).cancel,
                  onPressed: () => GlobalQueue().removeLastPermanent(),
                ),
                duration: Duration(seconds: 1),
                content: Text("$trackName "+AppLocalizations.of(this.state.context).tabsViewAddedToQueue),
              )
            );
          },
          onLongPressStart: (LongPressStartDetails detail) => trackMainOptions(ctrl, tracks.elementAt(index), ctrl.platform.playlists.value.indexOf(playlist), detail),
          child: Container(
              child: ListTile(
                title: ValueListenableBuilder(
                  valueListenable: tracks[index].isSelected,
                  builder: (_, value, __) {
                    return Text(
                      tracks.elementAt(index).name,
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
                          fit: BoxFit.cover,
                          alignment: FractionalOffset.center,
                          image: NetworkImage(tracks.elementAt(index).imageUrlLittle),
                        )
                      ),
                    )
                  )
                ),
                subtitle: Text(tracks.elementAt(index).artist),
                trailing: FractionallySizedBox(
                  heightFactor: 1,
                  child: trackMainDialog(ctrl, tracks.elementAt(index), ctrl.platform.playlists.value.indexOf(playlist)),
                ),
              )
            )
          )
        );
  }


  Widget tracksCreator(int tabIndex, PlatformsController ctrl, Playlist playlist, List<Widget> researchList, bool notResearch, Function setResearch, Function onReorder, Function returnToPlaylist, Function setPlaying) {
    
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
                                              onTap: () => renamePlaylist(context, playlist),
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
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(1))),
                                    labelText: AppLocalizations.of(this.state.context).search+"..",
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
                                  tooltip: AppLocalizations.of(this.state.context).tabsViewSort,
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                    SortPopupItemLastAdded(playlist).build(context),
                                    SortPopupItemTitle(playlist).build(context),
                                    SortPopupItemArtist(playlist).build(context)
                                  ],
                                  onSelected: (value) {
                                    this.state.setState(() {
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
                                  child: FlatButton(
                                    onPressed: () => setPlaying(null, true, playlist: playlist, platformCtrl: ctrl, isShuffle: false),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(Icons.play_arrow),
                                        Text(AppLocalizations.of(this.state.context).tabsViewPlayingSimple,
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    shape: ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: BorderSide(color: Colors.cyanAccent)
                                    ),
                                  )
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width/2.5,
                                  margin: EdgeInsets.only(top: 5, bottom: 10),
                                  child: FlatButton(
                                    onPressed: () => setPlaying(null, true, playlist: playlist, platformCtrl: ctrl, isShuffle: true),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(Icons.shuffle),
                                        Text(AppLocalizations.of(this.state.context).tabsViewPlayingShuffle,
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    shape: ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: BorderSide(color: Colors.cyanAccent)
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
                            itemBuilder: (buildContext, index) => listTracksBuilder(buildContext, index, tracks, ctrl, playlist, setPlaying),
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





  /* CRUD TRACKS  */



  void trackMainDialogOptions(String value, String name, PlatformsController ctrl, Track track, int index, Function refresh) {
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
        addToPlaylistDialog(ctrl, track);
      } break;
      case PopupMenuConstants.TRACKSMAINDIALOG_REMOVEFROMPLAYLIST: {
        removeFromPlaylistDialog(ctrl, track, index, refresh: refresh);
      } break;
      case PopupMenuConstants.TRACKSMAINDIALOG_INFORMATIONS: {
        trackInformationsDialog(ctrl, track);
      } break;
    }
  }


  PopupMenuButton trackMainDialog(PlatformsController ctrl, Track track, int index, {Function refresh}) {
    String name = track.name;

    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      tooltip: AppLocalizations.of(this.state.context).options,
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        TracksPopupItemAddToQueue().build(context),
        TracksPopupItemAddToAnotherPlaylist().build(context),
        TracksPopupItemRemoveFromPlaylist().build(context),
        TracksPopupItemInformations().build(context),
      ],
      onSelected: (value) {
        trackMainDialogOptions(value, name, ctrl, track, index, refresh);
      },
    );
  }

  void trackMainOptions(PlatformsController ctrl, Track track, int index, LongPressStartDetails detail, {Function refresh}) async {
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
        ],
        elevation: 8.0,
      ).then((value){
        trackMainDialogOptions(value, name, ctrl, track, index, refresh);
      }
    );
  }


  void addToPlaylistDialog(PlatformsController ctrl, Track track) {
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return TrackAddToPlaylistDialog(ctrl, track, choosePlaylistToAddTrack, dialogContext);
      }
    );
  }


  void addToPlaylist(PlatformsController ctrl, int index, Track track) {
    this.state.setState(() {
      ctrl.addTrackToPlaylist(index, track, true);
    });
  }
  void choosePlaylistToAddTrack(PlatformsController ctrl, Track track) {
    List<Widget> allCards;
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return TrackChoosePlaylistDialog(ctrl, allCards, track, addToPlaylist, dialogContext);
      }
    );
  }


  void addToQueue(Track track) {
    this.state.setState(() {
      GlobalQueue().addToPermanentQueue(track);
    });
  }


  void removeFromPlaylist(PlatformsController ctrl, int playlistIndex, int trackIndex, Function refresh) {
    this.state.setState(() {
      ctrl.removeTrackFromPlaylist(playlistIndex, trackIndex);
      if(refresh != null) refresh(null, null, '', null, null);
    });
  }
  void removeFromPlaylistDialog(PlatformsController ctrl, Track track, int playlistIndex, {Function refresh}) {
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return TrackRemoveFromPlaylistDialog(ctrl, track, playlistIndex, refresh, removeFromPlaylist, dialogContext);
      }
    );
  }


  void trackInformationsDialog(PlatformsController ctrl, Track track) {
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return TrackInformationDialog(ctrl, track, dialogContext);
      }
    );
  }





  /*  CRUD PLAYLISTS  */

  createPlaylist(PlatformsController ctrl) {
    String value = AppLocalizations.of(this.state.context).globalPlaylist+" " + ctrl.platform.name + " n°" + ctrl.platform.playlists.value.length.toString();

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
            FlatButton(
              child: Text(AppLocalizations.of(this.state.context).cancel, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FlatButton(
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


  void removePlaylist(BuildContext context, PlatformsController ctrl, Playlist playlist, int index) {
    Navigator.pop(context);
    String name = playlist.name;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(this.state.context).delete+" $name ?", style: TextStyle(color: Colors.white)),
          content: Text(AppLocalizations.of(this.state.context).tabsViewRemoveMessage),
          contentTextStyle: TextStyle(color: Colors.white),
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
    String name = playlist.name;
    String value = playlist.name;

    showDialog(
      context: context,
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
            FlatButton(
              child: Text(AppLocalizations.of(this.state.context).confirm, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                this.state.setState(() {
                  playlist.rename(value);
                });
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(this.state.context).cancel, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
          backgroundColor: Colors.grey[800],
        );
      }
    );
  }

  clonePlaylist(BuildContext context, PlatformsController ctrl, Playlist playlist) {
    String name = playlist.name;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(this.state.context).globalClone+" $name "+ AppLocalizations.of(this.state.context).globalIn+ " SmartShuffle ?", style: TextStyle(color: Colors.white)),
          actions: [
            FlatButton(
              child: Text(AppLocalizations.of(this.state.context).no, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FlatButton(
              child: Text(AppLocalizations.of(this.state.context).yes, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                Playlist play;
                this.state.setState(() {
                  play = PlatformsLister.platforms[ServicesLister.DEFAULT].addPlaylist(playlist: playlist);
                });
                if(play == null) {
                  showDialog(
                    context: context,
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

  mergePlaylist(BuildContext context, PlatformsController ctrl, Playlist playlist) {
    String name = playlist.name;
    List<Widget> allCards;
    PlatformsController defaultCtrl = PlatformsLister.platforms[ServicesLister.DEFAULT];
    
    showDialog(
      context: context,
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
                            subtitle: Text(defaultCtrl.platform.playlists.value[index].getTracks().length.toString() + " "+AppLocalizations.of(this.state.context).globalTracks),
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
          backgroundColor: Colors.black,
        );
      }
    );
  }

  playlistOption(PlatformsController ctrl, Playlist playlist, int index) {
    String name = playlist.name;
    showDialog(
      context: this.state.context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("$name", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: FlatButton(
                  child: Text(AppLocalizations.of(this.state.context).globalRename, style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    renamePlaylist(dialogContext, playlist);
                  },
                ),
              ),
              (ctrl.platform.name != 'SmartShuffle' ? 
              Container(
                child: FlatButton(
                  child: Text(AppLocalizations.of(this.state.context).tabsViewClonePlaylist, style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    clonePlaylist(dialogContext, ctrl, playlist);
                  },
                ),
              ) : Container()
              ),
              (ctrl.platform.name != 'SmartShuffle' ? 
              Container(
                child: FlatButton(
                  child: Text(AppLocalizations.of(this.state.context).tabsViewMergePlaylist, style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    mergePlaylist(dialogContext, ctrl, playlist);
                  },
                ),
              ) : Container()
              ),
              Container(
                child: FlatButton(
                  child: Text(AppLocalizations.of(this.state.context).delete, style: TextStyle(color: Colors.white)),
                  onPressed: () => removePlaylist(dialogContext, ctrl, playlist, index),
                ),
              ),
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


}