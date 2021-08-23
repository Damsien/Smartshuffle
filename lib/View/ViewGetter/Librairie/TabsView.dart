import 'dart:developer';
import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/services.dart';
import 'package:smartshuffle/Controller/AppManager/GlobalQueue.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Players/FrontPlayer.dart';
import 'package:smartshuffle/Model/Util.dart';
import 'package:smartshuffle/View/Pages/Librairie/PlaylistsPage.dart';
import 'package:smartshuffle/View/ViewGetter/FormsView.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsPopupItems.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Object/Platform.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:visibility_detector/visibility_detector.dart';


class TabView extends StatefulWidget {

  final PlatformsController ctrl;
  final PlaylistsPageState parent;
  final ScrollController playlistScrollController = ScrollController();
  final ScrollController tracksScrollController = ScrollController();

  TabView(this.ctrl, {Key key, this.parent}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TabViewState();

}

class TabViewState extends State<TabView> with AutomaticKeepAliveClientMixin {

  Playlist selectedPlaylist;
  double trackTop;

  void refresh() {
    setState(() {});
  }

  void returnToPlaylist() {
    setState(() {
      trackTop = MediaQuery.of(context).size.height;
      widget.parent.isPlaylistOpen[widget] = false;
    });
  }

  void openPlaylist(Playlist playlist) {
    setState(() {
      selectedPlaylist = playlist;
      trackTop = 0;
      widget.parent.isPlaylistOpen[widget] = true;
    });
  }

  @override
  void initState() {
    widget.parent.isPlaylistOpen[widget] = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(trackTop == null) trackTop = MediaQuery.of(context).size.height;

    return Stack(
      key: PageStorageKey(widget.ctrl.platform.name),
      children: [
        PlaylistsView(
          ctrl: widget.ctrl,
          openPlaylist: openPlaylist,
          scrollController: widget.playlistScrollController
        ),
        AnimatedPositioned(
          top: trackTop,
          curve: Curves.ease,
          duration: Duration(milliseconds: 150),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height-56-50,
            child: TracksView(
              ctrl: widget.ctrl,
              playlist: selectedPlaylist,
              returnToPlaylist: returnToPlaylist,
              notifyParent: refresh,
              scrollController: widget.tracksScrollController
            )
          )
        ),
      ]
    );
  }

  @override
  bool get wantKeepAlive => true;
  
}


class TracksView extends StatefulWidget {

  final PlatformsController ctrl;
  final Playlist playlist;
  final Function returnToPlaylist;
  final Function notifyParent;
  final ScrollController scrollController;

  TracksView({
    Key key,
    @required this.ctrl,
    @required this.playlist,
    @required this.returnToPlaylist,
    @required this.scrollController,
    this.notifyParent
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TracksViewState();

}

class _TracksViewState extends State<TracksView> {

  final MaterialColor _materialColor = GlobalTheme.material_color;

  PlatformsController _ctrl;
  Playlist _playlist;
  Function _returnToPlaylist;

  ScrollController _scrollCtrl;

  List<Track> _tracks;

  Text _textDisplayed;
  Widget _littleTopBar;

  String _searchValue;
  void setResearch(String value) {
    if(_searchValue != value) {
      if(value != '') {
        List<Track> temp = <Track>[];
        for(Track track in _playlist.getTracks) {
          if(track.title.contains(value) || track.title.toLowerCase().contains(value)
          || track.artist.contains(value) || track.artist.toLowerCase().contains(value)) {
            temp.add(track);
          }
        }
        setState(() {
          _tracks = temp;
        });
      } else {
        setState(() {
          _tracks = _playlist.getTracks;
        });
      }
      _searchValue = value;
    }
  }

  String _topText(Playlist playlist, bool isTop) {
    String text;
    if(isTop) {
      final int tracksLength = playlist.getTracks.length;
      Duration tracksDuration = Duration.zero;
      for(Track track in playlist.getTracks) {
        tracksDuration += track.totalDuration.value;
      }
      text = tracksLength.toString() + " " + AppLocalizations.of(context).globalTracks
        + " - " + tracksDuration.toString().split('.')[0];
    } else {
      text = playlist.name;
    }
    return text;
  }

  @override
  void initState() {
    _ctrl = widget.ctrl;
    _returnToPlaylist = widget.returnToPlaylist;
    _scrollCtrl = widget.scrollController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _playlist = widget.playlist;

    if(_playlist == null) return SizedBox.shrink();

    _tracks = _playlist.getTracks;
    if(_textDisplayed == null) _textDisplayed = Text(_topText(_playlist, true), key: ValueKey('Track:TopMode'));
    if(_littleTopBar == null) _littleTopBar = SizedBox.shrink();

    Widget tracksList = _TracksLister(ctrl: _ctrl, playlist: _playlist, scrollController: _scrollCtrl, tracks: _tracks,);

    return WillPopScope(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollCtrl,
              padding: EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        width: WidgetsBinding.instance.window.physicalSize.width,
                        height: 150,
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 30, bottom: 20),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width/2,
                                        child: InkWell(
                                          onTap: () => (_ctrl.features[PlatformsCtrlFeatures.PLAYLIST_RENAME] ?
                                            TabsView(objectState: this).renamePlaylist(_playlist)
                                            : SizedBox.shrink()
                                          ),
                                          child: Text(
                                            _playlist.name, 
                                            style: ((300/_playlist.name.length+5) > 30 ?
                                              TextStyle(fontSize: 30) :
                                              TextStyle(fontSize: (300/_playlist.name.length+5).toDouble())
                                            ),
                                          )
                                        )
                                      ),
                                      VisibilityDetector(
                                        key: UniqueKey(),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width/2,
                                          child: Text(
                                            _playlist.ownerName, 
                                            style: ((300/_playlist.ownerName.length+5) > 30 ?
                                              TextStyle(fontSize: 20) :
                                              TextStyle(fontSize: (200/_playlist.ownerName.length+5).toDouble())
                                            ),
                                          )
                                        ),
                                        onVisibilityChanged: (VisibilityInfo info) {
                                          if(info.visibleFraction == 0 && _textDisplayed.key == ValueKey('Track:TopMode')) {
                                            setState(() {
                                              _littleTopBar = Container(
                                                decoration: BoxDecoration(
                                                  color: _materialColor.shade50
                                                ),
                                                width: MediaQuery.of(context).size.width,
                                                height: 2,
                                              );
                                              _textDisplayed = Text(_topText(_playlist, false), key: ValueKey('Track:BotMode'));
                                            });
                                          } else if(info.visibleFraction > 0 && _textDisplayed.key == ValueKey('Track:BotMode')) {
                                            setState(() {
                                              _littleTopBar = SizedBox.shrink();
                                              _textDisplayed = Text(_topText(_playlist, true), key: ValueKey('Track:TopMode'));
                                            });
                                          }
                                        }
                                      )
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
                                        image: NetworkImage(_playlist.imageUrl),
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
                                setResearch(val);
                              },
                            )
                          ),
                          trailing: InkWell(
                            child: PopupMenuButton(
                              icon: Icon(Icons.sort),
                              tooltip: AppLocalizations.of(context).tabsViewSort,
                              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                SortPopupItemLastAdded(_playlist).build(context),
                                SortPopupItemTitle(_playlist).build(context),
                                SortPopupItemArtist(_playlist).build(context)
                              ],
                              onSelected: (value) {
                                setState(() {
                                  _tracks = _playlist.sort(value);
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
                                onPressed: () => FrontPlayerController().createQueueAndPlay(_playlist, isShuffle: false),
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
                                  side: BorderSide(color: _materialColor.shade700)
                                ),
                              )
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width/2.5,
                              margin: EdgeInsets.only(top: 5, bottom: 10),
                              child: MaterialButton(
                                onPressed: () => FrontPlayerController().createQueueAndPlay(_playlist, isShuffle: true),
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
                                  side: BorderSide(color: _materialColor.shade700)
                                ),
                              )
                            ),
                          ],
                        ),
                      ),
                    ]
                  ),
                  Container(
                    height: 80*_tracks.length.toDouble(),
                    child: tracksList
                  )
                ]
              )
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black
              ),
              height: 37,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => _returnToPlaylist(),
                    child: Container(
                      child: Icon(Icons.expand_more, size: 25),
                      margin: EdgeInsets.all(5),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 150),
                    child: _textDisplayed
                  ),
                  InkWell(
                    onTap: () => _returnToPlaylist(),
                    child: Container(
                      child: Icon(Icons.more_vert, size: 25),
                      margin: EdgeInsets.all(5),
                    ),
                  ),
                ]
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 150),
              child: _littleTopBar,
            )
          ]
        )
      ),
      onWillPop: () async {
        if(_tracks.length != _playlist.getTracks.length) {
          setResearch('');
        } else {
          _returnToPlaylist();
        }
        return false;
      },
    );
  }
  
}


class _TracksLister extends StatefulWidget {

  final List<Track> tracks;
  final ScrollController scrollController;
  final PlatformsController ctrl;
  final Playlist playlist;

  _TracksLister({Key key, @required this.tracks, @required this.scrollController, @required this.ctrl, @required this.playlist}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TrackListerState();

}

class _TrackListerState extends State<_TracksLister> {

  @override
  Widget build(BuildContext context) {
    List<Track> tracks = widget.tracks;
    ScrollController scrollController = widget.scrollController;
    PlatformsController ctrl = widget.ctrl;
    Playlist playlist = widget.playlist;


    return ListView.builder(
      controller: scrollController,
      itemCount: tracks.length,
      itemBuilder: (BuildContext context, int index) => TrackView(tracks[index], ctrl: ctrl, playlist: playlist)
    );

  }

}


class TrackView extends StatefulWidget {

  final Track track;
  final PlatformsController ctrl;
  final Playlist playlist;

  TrackView(this.track, {Key key, @required this.ctrl, @required this.playlist}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TrackViewState();

}

class _TrackViewState extends State<TrackView> {

  final MaterialColor _materialColor = GlobalTheme.material_color;

  @override
  Widget build(BuildContext context) {
    Track track = widget.track;
    Playlist playlist = widget.playlist;
    PlatformsController ctrl = widget.ctrl;

    return Container(
      child: GestureDetector(
        onTap: () {
          setState(() {
            FrontPlayerController().createQueueAndPlay(playlist, track: track);
          });
        },
        onDoubleTap: () {
          TabsView(objectState: this).addToQueue(track);
          String trackName = track.title;
          SnackBarController().showSnackBar(
            SnackBar(
              action: SnackBarAction(
                label: AppLocalizations.of(context).cancel,
                onPressed: () => GlobalQueue().removeLastPermanent(),
              ),
              duration: Duration(seconds: 1),
              content: Text("$trackName "+AppLocalizations.of(context).tabsViewAddedToQueue),
            )
          );
        },
        onLongPressStart: (LongPressStartDetails detail) => TabsView(objectState: this).trackMainOptions(track, ctrl: ctrl, index: ctrl.platform.playlists.value.indexOf(playlist), detail: detail),
        child: Container(
            child: ListTile(
              title: ValueListenableBuilder(
                valueListenable: track.isSelected,
                builder: (_, value, __) {
                  return Text(
                    track.title,
                    style: (track.isSelected.value ?
                      TextStyle(color: _materialColor.shade300) : TextStyle(color: Colors.white)
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
                        image: NetworkImage(track.imageUrlLittle),
                      )
                    ),
                  )
                )
              ),
              subtitle: Text(track.artist),
              trailing: Builder(
                builder: (BuildContext bContext) {
                  return FractionallySizedBox(
                    heightFactor: 1,
                    child: TabsView(objectState: this).trackMainDialog(track, ctrl: ctrl, index: ctrl.platform.playlists.value.indexOf(playlist),
                      enable:{
                        PopupMenuConstants.TRACKSMAINDIALOG_ADDTOQUEUE: true,
                        PopupMenuConstants.TRACKSMAINDIALOG_ADDTOANOTHERPLAYLIST: ctrl.features[PlatformsCtrlFeatures.TRACK_ADD_ANOTHER_PLAYLIST],
                        PopupMenuConstants.TRACKSMAINDIALOG_REMOVEFROMPLAYLIST: ctrl.features[PlatformsCtrlFeatures.TRACK_REMOVE],
                        PopupMenuConstants.TRACKSMAINDIALOG_INFORMATIONS: true,
                        PopupMenuConstants.TRACKSMAINDIALOG_REPORT: true
                      }
                    )
                  );
                }
              )
            )
          )
        )
      );

  }
  
}


class PlaylistsView extends StatefulWidget {

  final PlatformsController ctrl;
  final Function openPlaylist;
  final ScrollController scrollController;

  PlaylistsView({Key key, @required this.ctrl, @required this.openPlaylist, @required this.scrollController}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlaylistsViewState();
}

class _PlaylistsViewState extends State<PlaylistsView> {

  final MaterialColor _materialColor = GlobalTheme.material_color;

  @override
  Widget build(BuildContext context) {
    PlatformsController ctrl = widget.ctrl;

    return FutureBuilder<List<Playlist>>(
      future: ctrl.getPlaylists(),
      builder: (BuildContext context, AsyncSnapshot<List<Playlist>> snapshot) {
        Widget finalWidget;
        
        if(snapshot.hasData) {

          
          List<Playlist> realPlaylists = snapshot.data;
          finalWidget = Container(
            key: PageStorageKey('TabBarView:'+ctrl.platform.name+':Playlists'),
            color: Colors.black,
            child: RefreshIndicator(
              key: UniqueKey(),
              backgroundColor: Colors.black,
              color: _materialColor.shade300,
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
                    scrollController: widget.scrollController,
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
                                child: Text(ctrl.platformInformations['name'], style: TextStyle(fontSize: 30))
                              ),
                              (ctrl.features[PlatformsCtrlFeatures.PLAYLIST_ADD] ?
                              Container(
                                child: MaterialButton(
                                  shape: ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                  onPressed: () => TabsView(objectState: this).createPlaylist(ctrl),
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
                              )
                              : SizedBox.shrink()
                              )
                            ]
                          ),
                          InkWell(
                            onTap: () => TabsView(objectState: this).openApp(ctrl.platform),
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
                                      onTap: () => widget.openPlaylist(playlists[index]),
                                    ),
                                    onLongPressStart: (LongPressStartDetails detail) => TabsView(objectState: this).playlistMainOptions(playlists[index], ctrl: ctrl, index: index, detail: detail,
                                      enable: {
                                        PopupMenuConstants.PLAYLISTSMAINDIALOG_RENAME: ctrl.features[PlatformsCtrlFeatures.PLAYLIST_RENAME],
                                        PopupMenuConstants.PLAYLISTSMAINDIALOG_CLONE: ctrl.features[PlatformsCtrlFeatures.PLAYLIST_CLONE],
                                        PopupMenuConstants.PLAYLISTSMAINDIALOG_MERGE: ctrl.features[PlatformsCtrlFeatures.PLAYLIST_MERGE],
                                        PopupMenuConstants.PLAYLISTSMAINDIALOG_DELETE: ctrl.features[PlatformsCtrlFeatures.PLAYLIST_REMOVE]
                                      }
                                    ),
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
            color: Colors.black,
            alignment: Alignment.center,
            child: CircularProgressIndicator(color: _materialColor.shade300)
          );
                
        }

        return finalWidget;

      }
    );
  }
  
}



class TabsView {

  // GlobalKey<ScaffoldState> scaffold;
  // State objectState;

  BuildContext context;
  State state;
  
  static final TabsView _tabsView = TabsView._instance();

  final MaterialColor materialColor = GlobalTheme.material_color;

  factory TabsView({GlobalKey<ScaffoldState> scaffoldKey, State objectState}) {
    // _tabsView.scaffold = scaffoldKey;
    // _tabsView.objectState = objectState;
    
    if(scaffoldKey != null) {
      _tabsView.state = scaffoldKey.currentState;
      _tabsView.context = scaffoldKey.currentContext;
    }

    if(objectState != null) {
      _tabsView.state = objectState;
      _tabsView.context = objectState.context;
    }


    return _tabsView;
  }

  TabsView._instance();




  
  // TODO: Fix try catch doesn't work
  void openApp(Platform platform) async {
    try {
      DeviceApps.openApp(platform.platformInformations['package']);
    } catch (error) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).globalNotFoundApp, style: TextStyle(color: Colors.white)),
            content: Text(AppLocalizations.of(context).globalNotFoundAppDesc),
            contentTextStyle: TextStyle(color: Colors.white),
            actions: [
              FlatButton(
                child: Text(AppLocalizations.of(context).ok, style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(dialogContext),
              )
            ],
            backgroundColor: Colors.grey[800],
          );
        }
      );
    }
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
        SnackBarController().showSnackBar(
          SnackBar(
            action: SnackBarAction(
              label: AppLocalizations.of(context).cancel,
              onPressed: () => GlobalQueue().removeLastPermanent()
            ),
            duration: Duration(seconds: 1),
            content: Text("$name "+AppLocalizations.of(context).tabsViewAddedToQueue),
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
    int index,
    Function refresh,
    Map<String, bool> enable,
    double iconSize
  }) {
    String name = track.title;
    Map<String, PopupMenuEntry> popUpMenuEntry =
    {
      PopupMenuConstants.TRACKSMAINDIALOG_ADDTOQUEUE: TracksPopupItemAddToQueue().build(context),
      PopupMenuConstants.TRACKSMAINDIALOG_ADDTOANOTHERPLAYLIST: TracksPopupItemAddToAnotherPlaylist().build(context),
      PopupMenuConstants.TRACKSMAINDIALOG_REMOVEFROMPLAYLIST: TracksPopupItemRemoveFromPlaylist().build(context),
      PopupMenuConstants.TRACKSMAINDIALOG_INFORMATIONS: TracksPopupItemInformations().build(context),
      PopupMenuConstants.TRACKSMAINDIALOG_REPORT: TracksPopupItemReport().build(context)
    };

    return PopupMenuButton(
      iconSize: iconSize ?? 24.0,
      icon: Icon(Icons.more_vert),
      tooltip: AppLocalizations.of(context).options,
      itemBuilder: (BuildContext context) {
        if(enable == null) {
          return popUpMenuEntry.values.toList();
        } else {
          List<PopupMenuEntry> tempoList = <PopupMenuEntry>[];
          for(MapEntry<String, bool> me in enable.entries) {
            if(me.value) {
              tempoList.add(popUpMenuEntry[me.key]);
            }
          }
          return tempoList;
        }
      },
      onSelected: (value) {
        trackMainDialogOptions(value, name: name, ctrl: ctrl, track: track, index: index, refresh: refresh);
        this.state.setState(() {});
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
    String name = track.title;

    await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(detail.globalPosition.dx, detail.globalPosition.dy,
         MediaQuery.of(context).size.width - detail.globalPosition.dx, MediaQuery.of(context).size.height - detail.globalPosition.dy),
        items: [
          TracksPopupItemAddToQueue().build(context),
          TracksPopupItemAddToAnotherPlaylist().build(context),
          TracksPopupItemRemoveFromPlaylist().build(context),
          TracksPopupItemInformations().build(context),
          TracksPopupItemReport().build(context)
        ],
        elevation: 8.0,
      ).then((value){
        trackMainDialogOptions(value, name: name, ctrl: ctrl, track: track, index: index, refresh: refresh);
      }
    );
  }


  void addToPlaylist(Track track, {@required PlatformsController ctrl}) {
    String name = track.title;
    String ctrlName = ctrl.platform.name;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$name', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: FlatButton(
                  child: Text(AppLocalizations.of(context).tabsViewAddToService+" SmartShuffle", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    choosePlaylistToAddTrack(track, ctrl: PlatformsLister.platforms[ServicesLister.SMARTSHUFFLE]);
                  },
                ),
              ),
              () {
                if(ctrl.platform.name != PlatformsLister.platforms[ServicesLister.SMARTSHUFFLE].platform.name) {
                  return Container(
                    child: FlatButton(
                      child: Text(AppLocalizations.of(context).tabsViewAddToService+" $ctrlName", style: TextStyle(color: Colors.white)),
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
                  child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.white)),
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
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).tabsViewChooseAPlaylist, style: TextStyle(color: Colors.white)),
          contentPadding: EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: () {
                allCards = List.generate(
                  ctrl.platform.playlists.value.length,
                  (index) {

                    if(ctrl.platform.playlists.value[index].ownerId == ctrl.userInformations['ownerId']) {
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
                                subtitle: Text(ctrl.platform.playlists.value[index].getTracks.length.toString() + " "+AppLocalizations.of(context).globalTracks),
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                  String id = ctrl.addTrackToPlaylist(index, track, false);
                                  if(id == null) {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return AlertDialog(
                                          title: Text(AppLocalizations.of(context).tabsViewTrackAlreadyExists, style: TextStyle(color: Colors.white)),
                                          actions: [
                                            FlatButton(
                                              child: Text(AppLocalizations.of(context).no, style: TextStyle(color: Colors.white)),
                                              onPressed: () => Navigator.pop(dialogContext),
                                            ),
                                            FlatButton(
                                              child: Text(AppLocalizations.of(context).yes, style: TextStyle(color: Colors.white)),
                                              onPressed: () {
                                                Navigator.pop(dialogContext);
                                                state.setState(() {
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
                      child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.white)),
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
    state.setState(() {
      GlobalQueue().addToPermanentQueue(track);
    });
  }


  void removeFromPlaylist(Track track, {
    @required PlatformsController ctrl,
    @required int playlistIndex,
    Function refresh
  }) {
    String name = track.title;
    String playlistName = ctrl.platform.playlists.value[playlistIndex].name;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).remove+" $name "+AppLocalizations.of(context).from+" $playlistName ?", style: TextStyle(color: Colors.white)),
          actions: [
            FlatButton(
              child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).confirm, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                int trackIndex = ctrl.platform.playlists.value[playlistIndex].getTracks.indexOf(track);
                state.setState(() {
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
    String name = track.title;
    String artist = track.artist;
    String artist_string = AppLocalizations.of(context).globalArtist;
    if(artist.contains(',')) artist_string = AppLocalizations.of(context).globalArtists;
    String album;
    if(track.album != null) album = track.album;
    else album = AppLocalizations.of(context).nothing;
    String service = track.serviceName.toString();
    showDialog(
      context: context,
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
                    child: Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: AppLocalizations.of(context).popupItemTitle,
                            style: TextStyle(
                              fontSize: 25,
                              decoration: TextDecoration.underline,
                            )
                          ),
                          TextSpan(
                            text: ": $name",
                            style: TextStyle(
                              fontSize: 25,
                            )
                          ),
                        ]
                      )
                    )
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: "$artist_string",
                            style: TextStyle(
                              fontSize: 17,
                              decoration: TextDecoration.underline,
                            )
                          ),
                          TextSpan(
                            text: ": $artist",
                            style: TextStyle(
                              fontSize: 17,
                            )
                          ),
                        ]
                      )
                    )
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: AppLocalizations.of(context).globalAlbum,
                            style: TextStyle(
                              fontSize: 17,
                              decoration: TextDecoration.underline,
                            )
                          ),
                          TextSpan(
                            text: ": $album",
                            style: TextStyle(
                              fontSize: 17,
                            )
                          ),
                        ]
                      )
                    )
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: AppLocalizations.of(context).globalService,
                            style: TextStyle(
                              fontSize: 17,
                              decoration: TextDecoration.underline,
                            )
                          ),
                          TextSpan(
                            text: ": $service",
                            style: TextStyle(
                              fontSize: 17,
                            )
                          ),
                        ]
                      )
                    )
                  ),
                ]
              )
            ]
          ),
          actions: [
            FlatButton(
              child: Text(AppLocalizations.of(context).ok, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        );
      }
    );
  }


  void openReportForm(Track track) {
    Navigator.of(context)
      .push(
        MaterialPageRoute(
          builder: (context) => FormReport(track: track)
        )
      );
  }





  /*  CRUD PLAYLISTS  */

  void playlistMainOptions(Playlist playlist, {
    @required PlatformsController ctrl,
    @required int index,
    @required LongPressStartDetails detail,
    Map<String, bool> enable
  }) async {
    HapticFeedback.lightImpact();
    String name = playlist.name;
    Map<String, PopupMenuEntry> popUpMenuEntry =
    {
      PopupMenuConstants.PLAYLISTSMAINDIALOG_RENAME: PlaylistsPopupItemRename().build(context),
      PopupMenuConstants.PLAYLISTSMAINDIALOG_CLONE: PlaylistsPopupItemClone().build(context),
      PopupMenuConstants.PLAYLISTSMAINDIALOG_MERGE: PlaylistsPopupItemMerge().build(context),
      PopupMenuConstants.PLAYLISTSMAINDIALOG_DELETE: PlaylistsPopupItemDelete().build(context),
    };
    List<PopupMenuEntry> items = [];

    if(enable == null) {
      items.add(PlaylistsPopupItemRename().build(context));
      items.add(PlaylistsPopupItemClone().build(context));
      items.add(PlaylistsPopupItemMerge().build(context));
      items.add(PlaylistsPopupItemDelete().build(context));
    } else {
      for(MapEntry<String, bool> me in enable.entries) {
        if(me.value) {
          items.add(popUpMenuEntry[me.key]);
        }
      }
    }



    await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(detail.globalPosition.dx, detail.globalPosition.dy,
         MediaQuery.of(context).size.width - detail.globalPosition.dx, MediaQuery.of(context).size.height - detail.globalPosition.dy),
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
    String value = AppLocalizations.of(context).globalPlaylist + " " + ctrl.platform.name + " n°" + ctrl.platform.playlists.value.length.toString();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).tabsViewCreateAPlaylist, style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    labelText: AppLocalizations.of(context).tabsViewNameOfPlaylist
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
              child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            MaterialButton(
              child: Text(AppLocalizations.of(context).confirm, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                state.setState(() {
                  ctrl.addPlaylist(name: value, ownerId: ctrl.platformInformations['ownerId']);
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
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).delete+" $name ?", style: TextStyle(color: Colors.white)),
          content: Text(AppLocalizations.of(context).tabsViewRemoveMessage),
          contentTextStyle: TextStyle(color: Colors.white),
          actions: [
            MaterialButton(
              child: Text(AppLocalizations.of(context).no, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            MaterialButton(
              child: Text(AppLocalizations.of(context).yes, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                state.setState(() {
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
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).globalRename+" $name", style: TextStyle(color: Colors.white)),
          content: TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              labelText: AppLocalizations.of(context).tabsViewNameOfPlaylist,
            ),
            initialValue: name,
            onChanged: (String val) {
              value = val;
            },
          ),
          actions: [
            MaterialButton(
              child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            MaterialButton(
              child: Text(AppLocalizations.of(context).confirm, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                state.setState(() {
                  playlist.name = value;
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
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).globalClone+" $name "+ AppLocalizations.of(context).globalIn+ " SmartShuffle ?", style: TextStyle(color: Colors.white)),
          actions: [
            MaterialButton(
              child: Text(AppLocalizations.of(context).no, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            MaterialButton(
              child: Text(AppLocalizations.of(context).yes, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                Playlist play;
                state.setState(() {
                  play = PlatformsLister.platforms[ServicesLister.SMARTSHUFFLE].addPlaylist(playlist: playlist,);
                });
                if(play == null) {
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: Text("$name "+AppLocalizations.of(context).tabsViewAlreadyExists+" "+ AppLocalizations.of(context).globalIn+" SmartShuffle", style: TextStyle(color: Colors.white)),
                        actions: [
                          FlatButton(
                            child: Text(AppLocalizations.of(context).ok, style: TextStyle(color: Colors.white)),
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
    PlatformsController defaultCtrl = PlatformsLister.platforms[ServicesLister.SMARTSHUFFLE];
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).tabsViewChoosePlaylistToMerge+" $name", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: () {
                allCards = List.generate(
                  defaultCtrl.platform.playlists.value.length,
                  (index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 3),
                      child: ListTile(
                        title: Text(defaultCtrl.platform.playlists.value[index].name),
                        leading: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                alignment: FractionalOffset.center,
                                image: NetworkImage(defaultCtrl.platform.playlists.value[index].imageUrl),
                              )
                            ),
                          ),
                        ),
                        subtitle: Text(defaultCtrl.platform.playlists.value[index].tracks.length.toString() + " " + AppLocalizations.of(context).globalTracks),
                        onTap: () {
                          Navigator.pop(dialogContext);
                          showDialog(context: dialogContext, builder: (BuildContext bldctx) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context).tabsViewMergePlaylist + " ?"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: Text(playlist.name),
                                    leading: AspectRatio(
                                      aspectRatio: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.fitHeight,
                                            alignment: FractionalOffset.center,
                                            image: NetworkImage(playlist.imageUrl),
                                          )
                                        ),
                                      ),
                                    ),
                                    subtitle: Text.rich(
                                      TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: playlist.tracks.length.toString(),
                                            style: TextStyle(decoration: TextDecoration.underline)
                                          ),
                                          TextSpan(text: " " +AppLocalizations.of(context).globalTracks)
                                        ]
                                      )
                                    )
                                  ),
                                  Icon(Icons.arrow_downward),
                                  ListTile(
                                    title: Text(defaultCtrl.platform.playlists.value[index].name),
                                    leading: AspectRatio(
                                      aspectRatio: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.fitHeight,
                                            alignment: FractionalOffset.center,
                                            image: NetworkImage(defaultCtrl.platform.playlists.value[index].imageUrl),
                                          )
                                        ),
                                      ),
                                    ),
                                    subtitle: Text.rich(
                                      TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(text: defaultCtrl.platform.playlists.value[index].tracks.length.toString() + "+"),
                                          TextSpan(
                                            text: playlist.tracks.length.toString(),
                                            style: TextStyle(decoration: TextDecoration.underline)
                                          ),
                                          TextSpan(text: " " +AppLocalizations.of(context).globalTracks)
                                        ]
                                      )
                                    )
                                  )
                                ]
                              ),
                              actions: [
                                FlatButton(
                                  child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.white)),
                                  onPressed: () => Navigator.pop(bldctx),
                                ),
                                FlatButton(
                                  child: Text(AppLocalizations.of(context).confirm, style: TextStyle(color: Colors.white)),
                                  onPressed: () => defaultCtrl.mergePlaylist(defaultCtrl.platform.playlists.value[index], playlist),
                                ),
                              ],
                            );
                          });
                        },
                      )
                    );
                  }
                );
                allCards.add(
                  Container(
                    child: MaterialButton(
                      child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.white)),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                );
                return allCards;
              }.call()
            )
          ),
        );
      }
    );
  }


}