

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smartshuffle/Controller/Players/FrontPlayer.dart';

class FrontPlayerView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _FrontPlayerViewState();
  
}


class _FrontPlayerViewState extends State<FrontPlayerView> {

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
  static double _botbar_height = 56;
  static double _playbutton_size_large;
  static double _playbutton_size_little;
  static double _text_size_large;
  static double _text_size_little;
  static Color _main_image_color = Colors.black87;

  // Front variables
  double _botBarHeight;
  double _imageSize;
  double _sideMarge;
  double _playButtonSize;
  double _textSize;
  double _elementsOpacity;
  String _playButtonIcon = 'play';
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

      _botBarHeight = _botbar_height - (_ratio * _botbar_height);
      if (_imageSize >= _image_size_little) _imageSize = _image_size_large * _ratio;
      _sideMarge = (1 - _ratio) * _side_marge;
      if(_playButtonSize >= _playbutton_size_little) _playButtonSize = _playbutton_size_large * _ratio;
      if(_textSize >= _text_size_little) _textSize = _text_size_large * _ratio;
      _elementsOpacity = _ratio;

      _preventFromNullValue(_ratio);
    });
  }


  /* =========================== */

  Future _initAudioService() async {
    await AudioService.connect();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  @override
  void initState() {
    FrontPlayerController().onBuildPage();
    _initAudioService();
    super.initState();
  }

  @override
  void dispose() {
    AudioService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    _constantBuilder();
    _sizeBuilder();
  }

}