

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Playlist.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/View/ViewGetter/Librairie/TabsView.dart';

class FrontPlayer {

  static FrontPlayer getInstance(State state, Track track, Map<String, Function> functions) {
    return FrontPlayer(state, track, functions);
  }

  State state;
  Map<String, Function> functions;

  Track selectedTrack = Track(
      service: ServicesLister.DEFAULT,
      artist: '',
      name: '',
      id: null,
      imageUrl: '');
  Playlist selectedPlaylist = Playlist(
    ownerId: '',
    service: ServicesLister.DEFAULT,
    id: null,
    name: ''
  );
  PlatformsController selectedPlatform = PlatformsLister.platforms[ServicesLister.DEFAULT];

  FrontPlayer(State state, Track track, Map<String, Function> functions) {
    this.state = state;
    this.selectedTrack = track;
    this.functions = functions;
  }

  double _screenWidth;
  double _screenHeight;
  double _ratio = 1;

  PanelController _panelCtrl = PanelController();
  TabController _songsTabCtrl;
  int _tabIndex = 0;
  bool _isPanelDraggable = true;

  // Front constant
  double image_size_large;
  double image_size_little;
  double side_marge;
  double botbar_height;
  double playbutton_size_large;
  double playbutton_size_little;
  double text_size_large;
  double text_size_little;

  double _botBarHeight;
  double _imageSize;
  double _sideMarge;
  double _playButtonSize;
  double _textSize;
  double _elementsOpacity;
  String _playButtonIcon = "play";
  double _currentSliderValue;

  setState(Function func) {
    this.state.setState(func);
  }

  constantBuilder() {
    _screenWidth = MediaQuery.of(this.state.context).size.width;
    _screenHeight = MediaQuery.of(this.state.context).size.height;

    image_size_large = _screenWidth * 0.7;
    image_size_little = _screenWidth * 0.16;
    side_marge = (_screenWidth-image_size_little)*0.5;
    //botbar_height = _screenHeight/15;
    botbar_height = 56;
    playbutton_size_large = _screenWidth * 0.15;
    playbutton_size_little = _screenWidth * 0.1;
    text_size_large = _screenHeight *0.02;
    text_size_little = _screenHeight *0.015;

  }

  sizeBuilder() {
    if(_imageSize == null) _imageSize = image_size_little;
    if(_sideMarge == null) _sideMarge = side_marge;
    if(_playButtonSize == null) _playButtonSize = playbutton_size_little;
    if(_textSize == null) _textSize = text_size_little;
    if(_elementsOpacity == null) _elementsOpacity = 0;
  }

  preventFromNullValue(double height) {
    setState(() {

      if (_imageSize < image_size_little) _imageSize = image_size_little;
      if (_playButtonSize < playbutton_size_little) _playButtonSize = playbutton_size_little;
      if (_textSize < text_size_little) _textSize = text_size_little;

    });
  }

  switchPanelSize(double height) {
    setState(() {
      FocusScope.of(this.state.context).unfocus();

      _ratio = height;

      _botBarHeight = botbar_height - (_ratio * botbar_height);
      if (_imageSize >= image_size_little) _imageSize = image_size_large * _ratio;
      _sideMarge = (1 - _ratio) * side_marge;
      if(_playButtonSize >= playbutton_size_little) _playButtonSize = playbutton_size_large * _ratio;
      if(_textSize >= text_size_little) _textSize = text_size_large * _ratio;
      _elementsOpacity = _ratio;

    });
    preventFromNullValue(_ratio);
  }



  buildPanel() {
    return SlidingUpPanel(
      isDraggable: _isPanelDraggable,
      onPanelSlide: (height) => switchPanelSize(height),
      controller: _panelCtrl,
      minHeight: botbar_height+10,
      maxHeight: _screenHeight,
      panelBuilder: (scrollCtrl) {
        if(this.selectedTrack.id == null) _panelCtrl.hide();
        return WillPopScope(
          onWillPop: () async {
            if(_panelCtrl.isPanelOpen) {
              _panelCtrl.close();
              return false;
            } else
              return true;
          },
          child: GestureDetector(
            onTap: () => _panelCtrl.panelPosition < 0.3 ? _panelCtrl.open() : null,
            child: Stack(
              key: ValueKey('FrontPLayer'),
              children: [
                TabBarView(
                controller: _songsTabCtrl,
                  children: List.generate(
                    GlobalQueue.queue.length,
                    (index) {
                      Track track = GlobalQueue.queue[index].key;
                      return Stack(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(track.imageUrl),
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
                          Positioned(
                            top: (_screenHeight * 0.77),
                            right: (_screenWidth / 2) - _screenWidth * 0.45,
                            child: Opacity(
                              opacity: _elementsOpacity,
                              child: InkWell(
                                child: Text(track.totalDuration.toString().split(':')[1] +
                                    ":" + track.totalDuration.toString().split(':')[2].split(".")[0]
                                )
                              )
                            )
                          ),
                          Positioned(
                            top: (_screenHeight * 0.77),
                            left: (_screenWidth / 2) - _screenWidth * 0.45,
                            child: Opacity(
                              opacity: _elementsOpacity,
                              child: InkWell(
                                child: Text(track.currentDuration.toString().split(':')[1] +
                                  ":" + track.currentDuration.toString().split(':')[2].split(".")[0]
                                )
                              )
                            )
                          ),
                          Positioned(
                            top: (_screenHeight * 0.75),
                            left: _screenWidth / 2 - ((_screenWidth - (_screenWidth / 4)) / 2),
                            child: Opacity(
                              opacity: _elementsOpacity,
                              child: Container(
                                width: _screenWidth - (_screenWidth / 4),
                                child: Slider.adaptive(
                                  value: () {
                                    track.currentDuration.inSeconds / track.totalDuration.inSeconds >= 0
                                     && track.currentDuration.inSeconds / track.totalDuration.inSeconds <= 1
                                      ? _currentSliderValue = track.currentDuration.inSeconds / track.totalDuration.inSeconds
                                      : _currentSliderValue = 0.0;
                                      return _currentSliderValue;
                                  }.call(),
                                  onChanged: (double value) {
                                    setState(() {
                                      track.seekTo(Duration(seconds: (value * track.totalDuration.inSeconds).toInt()));
                                    });
                                  },
                                  min: 0,
                                  max: 1,
                                  activeColor: Colors.cyanAccent,
                                )
                              )
                            )
                          ),
                          Positioned(
                            width: _imageSize,
                            height: _imageSize,
                            left: (_screenWidth / 2 - (_imageSize / 2) - _sideMarge),
                            top: (_screenHeight / 4) * _ratio,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(track.imageUrl),
                                )
                              ),
                            ),
                          ),
                          Positioned(
                            left: _screenWidth * 0.2 * (1 - _ratio),
                            top: (_screenHeight * 0.60) * _ratio + (_sideMarge*0.06),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: _screenWidth * 0.15 * _ratio),
                                      width: _screenWidth - (_screenWidth * 0.1 * 4),
                                      child: Text(
                                        track.name,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: _textSize + (5 * _ratio)),
                                      )
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: _screenWidth * 0.15 * _ratio),
                                      width: _screenWidth - (_screenWidth * 0.1 * 4),
                                      child: Text(
                                        track.artist,
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
                                          TabsView.getInstance(this.state).addToPlaylist(this.selectedPlatform, track);
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
                            opacity: 1 - _ratio,
                            child: Container(
                              color: Colors.white,
                              width: track.currentDuration.inSeconds * _screenWidth / track.totalDuration.inSeconds,
                              height: 2,
                            ),
                          )
                        ],
                      );
                    }
                  )
                ),
                Positioned(
                  top: (_screenHeight * 0.80) * _ratio + (_sideMarge*0.07),
                  right: ((_screenWidth / 2) - (_playButtonSize / 2) - _sideMarge),
                  child: InkWell(
                    onTap: () {
                      this.selectedTrack.playPause() == true ? _playButtonIcon = "play" : _playButtonIcon = "pause";
                    },
                    child: Icon(
                      _playButtonIcon == "play" ? Icons.play_arrow : Icons.pause,
                      size: _playButtonSize,
                    )
                  )
                ),
                Positioned(
                  top: (_screenHeight * 0.8),
                  right: (_screenWidth / 2) - (_screenWidth / 4),
                  child: Opacity(
                    opacity: _elementsOpacity,
                    child: InkWell(
                        onTap: () => functions['skip_button_next'],
                        child: Icon(
                        Icons.skip_next,
                        size: _playButtonSize,
                      )
                    )
                  )
                ),
                Positioned(
                  top: (_screenHeight * 0.8),
                  right: _screenWidth - (_screenWidth / 2.5),
                  child: Opacity(
                    opacity: _elementsOpacity,
                    child: InkWell(
                        onTap: () {
                          if(this.selectedTrack.currentDuration.inSeconds >= 1) {
                            setState(() {
                              this.selectedTrack.seekTo(Duration(seconds: 0));
                            });
                            this.selectedTrack.seekTo(Duration(seconds: 0));
                          } else if(_songsTabCtrl.index > 0) {
                            _songsTabCtrl.animateTo(_songsTabCtrl.index-1);
                          }
                        },
                        child: Icon(
                        Icons.skip_previous,
                        size: _playButtonSize,
                      )
                    )
                  )
                ),
                Positioned(
                  top: (_screenHeight * 0.82),
                  right: (_screenWidth / 2) - (_screenWidth / 2.5),
                  child: Opacity(
                    opacity: _elementsOpacity,
                    child: InkWell(
                        onTap: () => this.functions['repeat_button_ontap'],
                        child: Icon( this.functions['repeat_button_icon'].call(),
                        color: this.functions['repeat_button_color'].call(),
                        size: _playButtonSize - 30,
                      )
                    )
                  )
                ),
                Positioned(
                  top: (_screenHeight * 0.82),
                  left: (_screenWidth / 2) - (_screenWidth / 2.5),
                  child: Opacity(
                    opacity: _elementsOpacity,
                    child: InkWell(
                      onTap: this.functions['shuffle_button_ontap'],
                        child: Icon(
                        Icons.shuffle,
                        color: this.functions['shuffle_button_color'].call(),
                        size: _playButtonSize - 30,
                      )
                    )
                  )
                ),
              ],
            )
          )
        );
      },
    );
  }


}