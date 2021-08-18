

import 'dart:ui';

import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smartshuffle/Controller/AppManager/GlobalQueue.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/Players/FrontPlayer.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Model/Object/UsefullWidget/extents_page_view.dart';
import 'package:smartshuffle/Model/Util.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsPopupItems.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsView.dart';

class FrontPlayerView extends StatefulWidget {

  final Function notifyParent;

  FrontPlayerView({Key key, @required this.notifyParent}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FrontPlayerViewState();
  
}


class _FrontPlayerViewState extends State<FrontPlayerView> {

  final MaterialColor _materialColor = GlobalTheme.material_color;

  // Controllers
  PanelController _panelCtrl = PanelController();
  PanelController _panelQueueCtrl = PanelController();

  // Queue panel is locked when _panelCtrl is close
  ValueNotifier<bool> _isPanelQueueDraggable = ValueNotifier<bool>(true);

  /* =========================== */
  
  // Global frontend strucutre variables;
  double _screen_width;
  double _screen_height;
  double _ratio = 1;

  // Front constant
  static double _image_size_large;
  static double _image_size_little;
  static double _side_marge;
  static double _playbutton_size_large;
  static double _playbutton_size_little;
  static double _text_size_large;
  static double _text_size_little;
  static Color _main_image_color = Colors.black;

  // Front variables
  double _imageSize;
  double _sideMarge;
  double _playButtonSize;
  double _textSize;
  double _elementsOpacity;
  double _currentSliderValue;


  /* =========================== */

  void _constantBuilder() {
    _screen_width = MediaQuery.of(context).size.width;
    _screen_height = MediaQuery.of(context).size.height;

    _image_size_large = _screen_width * 0.7;
    _image_size_little = _screen_width * 0.16;
    _side_marge = (_screen_width - _image_size_little) * 0.5;
    _playbutton_size_large = _screen_width * 0.15;
    _playbutton_size_little = _screen_width * 0.1;
    _text_size_large = _screen_height * 0.02;
    _text_size_little = _screen_height * 0.015;
  }

  void _sizeBuilder() {
    if (_imageSize == null) _imageSize = _image_size_little;
    if (_sideMarge == null) _sideMarge = _side_marge;
    if (_playButtonSize == null) _playButtonSize = _playbutton_size_little;
    if (_textSize == null) _textSize = _text_size_little;
    if (_elementsOpacity == null) _elementsOpacity = 0;
  }

  void _preventFromNullValue(double height) {
    if (_imageSize < _image_size_little) _imageSize = _image_size_little;
    if (_playButtonSize < _playbutton_size_little) _playButtonSize = _playbutton_size_little;
    if (_textSize < _text_size_little) _textSize = _text_size_little;
  }

  void _switchPanelSize(double height) {
    setState(() {
      FocusScope.of(context).unfocus();

      _ratio = height;

      FrontPlayerController().botBarHeight = FrontPlayerController().bot_bar_height - (_ratio * FrontPlayerController().bot_bar_height);
      widget.notifyParent();

      if (_imageSize >= _image_size_little) _imageSize = _image_size_large * _ratio;
      _sideMarge = (1 - _ratio) * _side_marge;
      if(_playButtonSize >= _playbutton_size_little) _playButtonSize = _playbutton_size_large * _ratio;
      if(_textSize >= _text_size_little) _textSize = _text_size_large * _ratio;
      _elementsOpacity = _ratio;

      _preventFromNullValue(_ratio);
    });
  }


  List<Widget> _queueListBuilder(List<Track> queue, int length) {
    List<Widget> list = <Widget>[];
    for(int index=0; index<length; index++) {
      Track track = queue[index];

      list.add(
        SizedBox(
          height: 80,
          child: Container(
            child: ListTile(
              title: ValueListenableBuilder(
                valueListenable: track.isSelected,
                builder: (_, value, __) {
                  return Text(
                    track.title,
                    style: (value ?
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
                    child: TabsView(objectState: this).trackMainDialog(
                      track,
                      ctrl: PlatformsLister.platforms[track.service],
                      enable: {
                        PopupMenuConstants.TRACKSMAINDIALOG_ADDTOQUEUE : true,
                        PopupMenuConstants.TRACKSMAINDIALOG_ADDTOANOTHERPLAYLIST: true,
                        PopupMenuConstants.TRACKSMAINDIALOG_REMOVEFROMPLAYLIST: false,
                        PopupMenuConstants.TRACKSMAINDIALOG_INFORMATIONS: true,
                        PopupMenuConstants.TRACKSMAINDIALOG_REPORT : false
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
    return list;
  }

  List<Widget> _queueListWidgetBuilder() {
    int permaLength = GlobalQueue.permanentQueue.value.length;
    int noPermaLength = (GlobalQueue.noPermanentQueue.value.length-(GlobalQueue.currentQueueIndex+1) > -1 ?
        GlobalQueue.noPermanentQueue.value.length-(GlobalQueue.currentQueueIndex+1) : 0);

    List<Track> permanentQueue = <Track>[];

    for(Track tr in GlobalQueue.permanentQueue.value) {
      permanentQueue.add(tr);
    }

    List<Track> noPermanentQueue = <Track>[];

    //TODO subString on list to cut it and retrieve only tracks who are after the current one
    for(int i=0; i<GlobalQueue.noPermanentQueue.value.length; i++) {
      if(i>GlobalQueue.currentQueueIndex) {
        noPermanentQueue.add(GlobalQueue.noPermanentQueue.value[i]);
      }
    }

    List<Widget> listView = <Widget>[];
    if (permaLength != 0) {

      listView.add(
        Text(
          AppLocalizations.of(context).globalAppTracksNextInQueue,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20
          )
        )
      );

      listView.add(
        SizedBox(height: 10)
      );

      listView.addAll(_queueListBuilder(permanentQueue, permaLength));

      listView.add(
        SizedBox(height: 30)
      );
    }

    listView.add(
      Text(
        AppLocalizations.of(context).globalAppPlaylistNextFrom + " " + FrontPlayerController().currentPlaylist.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20
        )
      )
    );

    listView.add(
      SizedBox(height: 10)
    );

    listView.addAll(_queueListBuilder(noPermanentQueue, noPermaLength));

    return listView;
  }


  /* =========================== */


  Future<void> _initAudioService() async {
    await AudioService.connect();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  @override
  void initState() {
    FrontPlayerController().onInitPage();
    _initAudioService();
    AudioService.notificationClickEventStream.listen((event) {
      if(event) _panelCtrl.open();
    });

    super.initState();
  }

  @override
  void dispose() {
    AudioService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FrontPlayerController().onBuildPage(view: this);

    if (
     _panelCtrl.isAttached
     && FrontPlayerController().currentTrack.value.id != null
     && !_panelCtrl.isPanelShown
     && FrontPlayerController().isPlayerReady
    ) {
      _panelCtrl.show();
    }
    List<Widget> listView = <Widget>[];
    
    _constantBuilder();
    _sizeBuilder();
    listView = _queueListWidgetBuilder();

    return FocusDetector(
      onVisibilityGained: () {FrontPlayerController().screenState.value = FrontPlayerController.SCREEN_VISIBLE;},
      onFocusGained: ()  {FrontPlayerController().screenState.value = FrontPlayerController.SCREEN_VISIBLE;},
      onForegroundGained: ()  {FrontPlayerController().screenState.value = FrontPlayerController.SCREEN_VISIBLE;},
      onForegroundLost:  () {FrontPlayerController().screenState.value = FrontPlayerController.SCREEN_IDLE;},
      // onFocusLost:  () {screenState.value = SCREEN_IDLE; print('idle');},
      onVisibilityLost:   () {FrontPlayerController().screenState.value = FrontPlayerController.SCREEN_IDLE;},
      child: Stack(
        children: [
          WillPopScope(
            onWillPop: () async {
              if(_panelCtrl.isPanelOpen) {
                if(_panelQueueCtrl.isPanelOpen) {
                  _panelQueueCtrl.close();
                } else {
                  _panelCtrl.close();
                }
                return false;
              } else
                return true;
            },
            child: SlidingUpPanel(
              isDraggable: FrontPlayerController().pageCtrl.hasClients ? ((FrontPlayerController().pageCtrl.page??0.0 % 1) < 0 && (FrontPlayerController().pageCtrl.page??0.0 % 1) > 1 ? false : true) : true,
              onPanelSlide: (height) => _switchPanelSize(height),
              controller: _panelCtrl,
              minHeight: FrontPlayerController().bot_bar_height+10,
              maxHeight: _screen_height,
              panelBuilder: (scrollCtrl) {
                if(FrontPlayerController().currentTrack.value.id == null) {
                  _panelCtrl.hide();
                }

                return GestureDetector(
                  onTap: () => _panelCtrl.panelPosition < 0.3 ? _panelCtrl.open() : null,
                  child: Stack(
                    key: ValueKey('FrontPLayer'),
                    children: [
                      ValueListenableBuilder(
                        valueListenable: GlobalQueue.queue,
                        builder: (_, List<MapEntry<Track, bool>> queue ,__) {

                          // FrontPlayerController().currentTrack.value = queue[GlobalQueue.currentQueueIndex].key;
                          // FrontPlayerController().currentTrack.value.seekTo(Duration.zero, false);
                          // FrontPlayerController().currentTrack.value.currentDuration.addListener(positionCheck);
                          
                          return ExtentsPageView.extents(
                            extents: 3, 
                            physics: _panelCtrl.panelPosition < 1 && _panelCtrl.panelPosition > 0.01 ? NeverScrollableScrollPhysics() : PageScrollPhysics(),
                            //itemCount: GlobalQueue.queue.value.length,
                            // onPageChanged: (index) {
                            //   if(index >= GlobalQueue.queue.value.length) {
                            //     FrontPlayerController().pageCtrl.jumpToPage(index % GlobalQueue.queue.value.length);
                            //     FrontPlayerController().nextTrack(backProvider: false);
                            //   }
                            // },
                            controller: FrontPlayerController().pageCtrl,
                            itemBuilder: (buildContext, index) {

                                  int realIndex = index % GlobalQueue.queue.value.length;

                                  Track trackUp = queue[realIndex].key;
                                  // print('trackup : $trackUp');
                                  // _timer?.cancel();
                                  // _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                                  //   _timer = timer;
                                  //   if(trackUp.currentDuration.value < trackUp.totalDuration.value) {
                                  //     trackUp.currentDuration.value = Duration(seconds: trackUp.currentDuration.value.inSeconds+1);
                                  //     trackUp.currentDuration.notifyListeners();
                                  //   } else {
                                  //     _timer.cancel();
                                  //   }
                                  // });

                                  return Stack(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(trackUp.imageUrlLittle),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            ClipRect(
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                  child: Container(
                                                    color: Colors.black.withOpacity(0.55),
                                                  )
                                              ),
                                            )
                                          ],
                                        ),
                                        ValueListenableBuilder(
                                          valueListenable: trackUp.totalDuration,
                                          builder: (BuildContext context, Duration duration, __) {
                                            if(trackUp.streamTrack.id != AudioService.currentMediaItem.id) {
                                              trackUp = FrontPlayerController().currentTrack.value;
                                            }

                                            return Positioned(
                                              top: (_screen_height * 0.77),
                                              right: (_screen_width / 2) - _screen_width * 0.45,
                                              child: Opacity(
                                                opacity: _elementsOpacity,
                                                child: InkWell(
                                                  child: Text(duration.toString().split(':')[1] +
                                                      ':' + duration.toString().split(':')[2].split('.')[0]
                                                  )
                                                )
                                              )
                                            );
                                          }
                                        ),
                                        ValueListenableBuilder(
                                          valueListenable: trackUp.currentDuration,
                                          builder: (BuildContext context, Duration duration, __) {
                                            return Stack(
                                              children: [
                                                Positioned(
                                                  top: (_screen_height * 0.77),
                                                  left: (_screen_width / 2) - _screen_width * 0.45,
                                                  child: Opacity(
                                                    opacity: _elementsOpacity,
                                                    child: InkWell(
                                                      child: Text(duration.toString().split(':')[1] +
                                                        ':' + duration.toString().split(':')[2].split('.')[0]
                                                      )
                                                    )
                                                  )
                                                ),
                                                Positioned(
                                                  top: (_screen_height * 0.75),
                                                  left: _screen_width / 2 - ((_screen_width - (_screen_width / 4)) / 2),
                                                  child: Opacity(
                                                    opacity: _elementsOpacity,
                                                    child: Container(
                                                      width: _screen_width - (_screen_width / 4),
                                                      child: Slider.adaptive(
                                                        value: () {
                                                          duration.inSeconds / trackUp.totalDuration.value.inSeconds >= 0
                                                          && duration.inSeconds / trackUp.totalDuration.value.inSeconds <= 1
                                                            ? _currentSliderValue = duration.inSeconds / trackUp.totalDuration.value.inSeconds
                                                            : _currentSliderValue = 0.0;
                                                            return _currentSliderValue;
                                                        }.call(),
                                                        onChanged: (double value) {
                                                          _panelCtrl.open();
                                                        },
                                                        onChangeEnd: (double value) {
                                                          trackUp.seekTo(Duration(seconds: (value * trackUp.totalDuration.value.inSeconds).toInt()), true);
                                                        },
                                                        min: 0,
                                                        max: 1,
                                                        activeColor: _materialColor.shade300,
                                                      )
                                                    )
                                                  )
                                                )
                                              ]
                                            );
                                          }
                                        ),
                                        Positioned(
                                          width: _imageSize,
                                          height: _imageSize,
                                          left: (_screen_width / 2 - (_imageSize / 2) - _sideMarge),
                                          top: (_screen_height / 4) * _ratio,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(trackUp.imageUrlLarge),
                                              )
                                            ),
                                          )
                                        ),
                                        Positioned(
                                          left: _screen_width * 0.2 * (1 - _ratio),
                                          top: (_screen_height * 0.60) * _ratio + (_sideMarge*0.06),
                                          child: Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(left: _screen_width * 0.15 * _ratio),
                                                    width: _screen_width - (_screen_width * 0.1 * 4),
                                                    child: Text(
                                                      trackUp.title,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(fontSize: _textSize + (5 * _ratio)),
                                                    )
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(left: _screen_width * 0.15 * _ratio),
                                                    width: _screen_width - (_screen_width * 0.1 * 4),
                                                    child: Text(
                                                      trackUp.artist,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontSize: _textSize,
                                                        fontWeight: FontWeight.w200),
                                                    )
                                                  )
                                                ],
                                              ),
                                              IgnorePointer(
                                                ignoring: (_elementsOpacity == 1 ? false : true),
                                                child: Opacity(
                                                  opacity: _elementsOpacity,
                                                  child: InkWell(
                                                      onTap: () {
                                                        TabsView(objectState: this).addToPlaylist(trackUp, ctrl: PlatformsLister.platforms[trackUp.service]);
                                                      },
                                                      child: Icon(
                                                      Icons.add,
                                                      size: _playButtonSize - 10,
                                                    )
                                                  )
                                                )
                                              )
                                            ]
                                          )
                                        ),
                                        Opacity(
                                          opacity: 1 - _elementsOpacity,
                                          child: ValueListenableBuilder(
                                            valueListenable: trackUp.currentDuration,
                                            builder: (BuildContext context, Duration duration, __) {
                                              return Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: duration.inSeconds * _screen_width / trackUp.totalDuration.value.inSeconds,
                                                  minWidth: duration.inSeconds * _screen_width / trackUp.totalDuration.value.inSeconds
                                                ),
                                                color: Colors.white,
                                                width: duration.inSeconds * _screen_width / trackUp.totalDuration.value.inSeconds,
                                                height: 2,
                                              );
                                            }
                                          )
                                        )
                                      ]
                                    );
                                  },
                                );
                        }
                      ),
                      Positioned(
                        top: (_screen_height * 0.05),
                        right: (_screen_width * 0.03),
                        child: IgnorePointer(
                          ignoring: (_elementsOpacity < 0.8 ? true : false),
                          child: Opacity(
                            opacity: _elementsOpacity,
                            child: TabsView(objectState: this).trackMainDialog(
                              FrontPlayerController().currentTrack.value,
                              ctrl: PlatformsLister.platforms[FrontPlayerController().currentTrack.value.service],
                              iconSize: 35.0,
                              index: () {
                                int index = FrontPlayerController().currentPlaylist.getTracks.indexOf(FrontPlayerController().currentTrack.value);
                                if(index == -1) {
                                  return null;
                                } else {
                                  return index;
                                }
                              }.call(),
                              enable: {
                                PopupMenuConstants.TRACKSMAINDIALOG_ADDTOQUEUE: true,
                                PopupMenuConstants.TRACKSMAINDIALOG_ADDTOANOTHERPLAYLIST:
                                  PlatformsLister.platforms[FrontPlayerController().currentTrack.value.service].features[PlatformsCtrlFeatures.TRACK_ADD_ANOTHER_PLAYLIST],
                                PopupMenuConstants.TRACKSMAINDIALOG_REMOVEFROMPLAYLIST:
                                  (FrontPlayerController().currentPlaylist.getTracks.indexOf(FrontPlayerController().currentTrack.value) == -1
                                    && PlatformsLister.platforms[FrontPlayerController().currentTrack.value.service].features[PlatformsCtrlFeatures.TRACK_REMOVE]
                                    ? false : true),
                                PopupMenuConstants.TRACKSMAINDIALOG_INFORMATIONS:true,
                                PopupMenuConstants.TRACKSMAINDIALOG_REPORT: true
                              }
                            )
                          )
                        )
                      ),
                      ValueListenableBuilder(
                        valueListenable: FrontPlayerController().currentTrack.value.isPlaying,
                        builder: (BuildContext context, bool isPlaying, Widget child) {
                          return Positioned(
                            top: (_screen_height * 0.80) * _ratio + (_sideMarge*0.07),
                            right: ((_screen_width / 2) - (_playButtonSize / 2) - _sideMarge),
                            child: InkWell(
                              onTap: () {
                                FrontPlayerController().currentTrack.value.playPause();
                              },
                              child: Icon(
                                !FrontPlayerController().currentTrack.value.isPlaying.value ? Icons.play_arrow : Icons.pause,
                                size: _playButtonSize,
                              )
                            )
                          );
                        }
                      ),
                      Positioned(
                        top: (_screen_height * 0.8),
                        right: (_screen_width / 2) - (_screen_width / 4),
                        child: Opacity(
                          opacity: _elementsOpacity,
                          child: InkWell(
                              onTap: () => FrontPlayerController().nextTrack(backProvider: false),
                              child: Icon(
                              Icons.skip_next,
                              size: _playButtonSize,
                            )
                          )
                        )
                      ),
                      Positioned(
                        top: (_screen_height * 0.8),
                        right: _screen_width - (_screen_width / 2.5),
                        child: Opacity(
                          opacity: _elementsOpacity,
                          child: InkWell(
                              onTap: () => FrontPlayerController().previousTrack(backProvider: false, isSeekToZero: true),
                              child: Icon(
                              Icons.skip_previous,
                              size: _playButtonSize,
                            )
                          )
                        )
                      ),
                      Positioned(
                        top: (_screen_height * 0.82),
                        right: (_screen_width / 2) - (_screen_width / 2.5),
                        child: Opacity(
                          opacity: _elementsOpacity,
                          child: InkWell(
                              onTap: () {
                                setState(() {
                                  if(FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) {
                                    FrontPlayerController().isRepeatOnce = false;
                                    FrontPlayerController().isRepeatAlways = true;
                                  } else if(FrontPlayerController().isRepeatAlways && !FrontPlayerController().isRepeatOnce) {
                                    FrontPlayerController().isRepeatAlways = false;
                                    FrontPlayerController().isRepeatOnce = false;
                                  } else if(!FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) {
                                    FrontPlayerController().isRepeatOnce = true;
                                    FrontPlayerController().isRepeatAlways = false;
                                  }
                                });
                              },
                              child: Icon(
                              () {
                                if(!FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) return Icons.repeat;
                                else if(FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) return Icons.repeat_one;
                                else if(FrontPlayerController().isRepeatAlways && !FrontPlayerController().isRepeatOnce) return Icons.repeat;
                              }.call(),
                              color: () {
                                if(!FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) return Colors.white;
                                else if(FrontPlayerController().isRepeatOnce && !FrontPlayerController().isRepeatAlways) return _materialColor.shade300;
                                else if(FrontPlayerController().isRepeatAlways && !FrontPlayerController().isRepeatOnce) return _materialColor.shade300;
                              }.call(),
                              size: _playButtonSize - 30,
                            )
                          )
                        )
                      ),
                      Positioned(
                        top: (_screen_height * 0.82),
                        left: (_screen_width / 2) - (_screen_width / 2.5),
                        child: Opacity(
                          opacity: _elementsOpacity,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if(FrontPlayerController().isShuffle) {
                                  FrontPlayerController().setPlayType(isShuffle: false);
                                } else {
                                  FrontPlayerController().setPlayType(isShuffle: true);
                                }
                              });
                            },
                              child: Icon(
                              Icons.shuffle,
                              color: () {
                                if(FrontPlayerController().isShuffle) return _materialColor.shade300;
                                else return Colors.white;
                              }.call(),
                              size: _playButtonSize - 30,
                            )
                          )
                        )
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _isPanelQueueDraggable,
            builder: (BuildContext context, bool value, Widget child) {
              


              return IgnorePointer(
                ignoring: (_elementsOpacity < 0.8 ? true : false),
                child: Opacity(
                  opacity: _elementsOpacity,
                  child: SlidingUpPanel(
                    controller: _panelQueueCtrl,
                    isDraggable: value,
                    minHeight: FrontPlayerController().bot_bar_height-10,
                    maxHeight: _screen_height,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
                    panelBuilder: (ScrollController scrollCtrl) {

                      return GestureDetector(
                        onTap: () => _panelQueueCtrl.panelPosition < 0.3 ? _panelQueueCtrl.open() : null,
                        onVerticalDragStart: (vertDragStart) {
                          _isPanelQueueDraggable.value = true;
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Container(
                            decoration: new BoxDecoration(
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(15.0),
                                topRight: const Radius.circular(15.0),
                              ),
                              color: Color(0xFF000000),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  width: 30,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.all(Radius.circular(12.0))
                                  ),
                                ),
                                Container(
                                  height: _screen_height-30,
                                  child: DefaultTabController(
                                    length: 2,
                                    child: Scaffold(
                                      appBar: AppBar(
                                        backgroundColor: _main_image_color,
                                        toolbarHeight: 5,
                                      ),
                                      body: GestureDetector(
                                        onVerticalDragStart: (vertDragStart) {
                                          _isPanelQueueDraggable.value = true;
                                        },
                                        child: TabBarView(
                                          children: [
                                            Scaffold(
                                              appBar: AppBar(
                                                toolbarHeight: 40,
                                                backgroundColor: _main_image_color,
                                                leading: IconButton(
                                                  icon: Icon(Icons.filter_list),
                                                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => QueueList(this))),
                                                ),
                                                // actions: [
                                                //   Padding(
                                                //     padding: EdgeInsets.only(right: 15),
                                                //     child: Icon(Icons.radio_button_unchecked)
                                                //   )
                                                // ]
                                              ),
                                              body: ListView(
                                                controller: scrollCtrl,
                                                children: listView,
                                              )
                                            ),
                                            

                                            Text(AppLocalizations.of(context).globalWIP),
                                          ],
                                        ),
                                      ),
                                      bottomNavigationBar: TabBar(
                                        tabs: [
                                          Tab(text: AppLocalizations.of(context).globalAppTracksQueue),
                                          Tab(text: AppLocalizations.of(context).globalAppTrackLyrics),
                                        ],
                                      ),
                                    )
                                  )
                                )
                              ],
                            )
                          )
                        )
                      );
                    }
                  )
                )
              );
            }
          )
        ]
      )
    );


  }

}



class QueueList extends StatefulWidget {

  final _FrontPlayerViewState parent;

  QueueList(this.parent, {Key key}) : super(key: key);

  @override
  _QueueListState createState() => _QueueListState();
  
}


class _QueueListState extends State<QueueList> {

  _FrontPlayerViewState parent;
  List<DragAndDropList> _contents;

  void _listBuilder() {
    int permaLength = GlobalQueue.permanentQueue.value.length;
    int noPermaLength = (GlobalQueue.noPermanentQueue.value.length-(GlobalQueue.currentQueueIndex+1) > -1 ?
        GlobalQueue.noPermanentQueue.value.length-(GlobalQueue.currentQueueIndex+1) : 0);

    List<DragAndDropItem> permanentItems;
    List<DragAndDropItem> noPermanentItems;

    List<Track> permanentQueue = <Track>[];
    List<Track> noPermanentQueue = <Track>[];

                      
    for(Track tr in GlobalQueue.permanentQueue.value) {
      permanentQueue.add(tr);
    }
    permanentItems = List.generate(
      permaLength,
      (index) {
        return DragAndDropItem(
          child: Container(
            child: Card(
              color: Color(0xFF000000),
              child: Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: ListTile(
                      title: Text(permanentQueue[index].title),
                      leading: FractionallySizedBox(
                        heightFactor: 0.8,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: new Container(
                            decoration: new BoxDecoration(
                              image: new DecorationImage(
                                fit: BoxFit.fitHeight,
                                alignment: FractionalOffset.center,
                                image: NetworkImage(permanentQueue[index].imageUrlLittle),
                              )
                            ),
                          ),
                        )
                      ),
                      subtitle: Text(permanentQueue[index].artist),
                    )
                  ),
                  Flexible(
                    flex: 1,
                    child: Container (
                      margin: EdgeInsets.only(left:20, right: 20),
                      child: Icon(Icons.drag_handle)
                    )
                  )
                ]
              )
            )
          )
        );
      },
    );

    //TODO subString on list to cut it and retrieve only tracks who are after the current one
    for(int i=0; i<GlobalQueue.noPermanentQueue.value.length; i++) {
      if(i>GlobalQueue.currentQueueIndex) {
        noPermanentQueue.add(GlobalQueue.noPermanentQueue.value[i]);
      }
    }
    noPermanentItems = List.generate(
      noPermaLength,
      (index) {
        return DragAndDropItem(
          child: Container(
            child: Card(
              color: Color(0xFF000000),
              child: Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: ListTile(
                      title: Text(noPermanentQueue[index].title),
                      leading: FractionallySizedBox(
                        heightFactor: 0.8,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: new Container(
                            decoration: new BoxDecoration(
                              image: new DecorationImage(
                                fit: BoxFit.fitHeight,
                                alignment: FractionalOffset.center,
                                image: NetworkImage(noPermanentQueue[index].imageUrlLittle),
                              )
                            ),
                          ),
                        )
                      ),
                      subtitle: Text(noPermanentQueue[index].artist),
                    )
                  ),
                  Flexible(
                    flex: 1,
                    child: Container (
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: Icon(Icons.drag_handle)
                    )
                  )
                ]
              )
            )
          )
        );
      },
    );


    DragAndDropList permanentList = DragAndDropList(
      canDrag: false,
      header: Container(
        width: double.infinity,
        margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        child: Text(
          AppLocalizations.of(context).globalAppTracksNextInQueue,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20
          )
        )
      ),
      children: permanentItems
    );

    DragAndDropList noPermanentList = DragAndDropList(
      canDrag: false,
      header: Container(
        width: double.infinity,
        margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        child: Text(
          AppLocalizations.of(context).globalAppPlaylistNextFrom + " " + FrontPlayerController().currentPlaylist.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20
          )
        )
      ),
      children: noPermanentItems
    );

    if(GlobalQueue.permanentQueue.value.isEmpty)
      _contents = [noPermanentList];
    else
      _contents = [permanentList, noPermanentList];

  }

  @override
  void initState() {
    parent = widget.parent;
    FrontPlayerController().currentTrack.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _listBuilder();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context).tabsViewSort),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: IconButton(
              icon: Icon(Icons.done),
              tooltip: AppLocalizations.of(context).confirm,
              onPressed: () {
                FrontPlayerController.fakeScreenUpdate = true;
                parent.setState(() {});
                Navigator.of(context).pop();
              },
            )
          )
        ]
      ),
      body: DragAndDropLists(
        onItemReorder: (int oldIndex, int oldList, int newIndex, int newList) {
          setState(() {
            GlobalQueue().reorder(oldIndex, oldList, newIndex, newList);
          });
        },
        children: _contents,
      )
    );
  }


}