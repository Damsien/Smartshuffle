import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';


class GlobalTheme {

  static Map<int, Color> _colorCodes = {
    50: Colors.deepPurple[50],
    100: Colors.deepPurpleAccent[100],
    200: Colors.deepPurple[200],
    300: Colors.deepPurple[300],
    400: Colors.deepPurpleAccent[400],
    500: Colors.deepPurple[500],
    600: Colors.deepPurple[600],
    700: Colors.deepPurpleAccent[700],
    800: Colors.deepPurple[800],
    900: Colors.deepPurple[900]
  };

  // ignore: non_constant_identifier_names
  static final MaterialColor material_color = MaterialColor(0xFF7E57C2, _colorCodes);

  static ThemeData themeData = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: material_color,
    accentColor: material_color.shade100,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    focusColor: material_color.shade400,
    canvasColor: Color(0xff1D1E33),
    scaffoldBackgroundColor: Colors.black
    // scaffoldBackgroundColor: Color(0xff1D1E33)
  );

}

class StatesManager {
  static Map<String, State> states = Map<String, State>();

  static void setPlaylistsPageState(State state) {
    states['PlaylistsPage'] = state;
  }

  static void setSearchPageState(State state) {
    states['SearchPage'] = state;
  }

  static void setProfilePageState(State state) {
    states['ProfilePage'] = state;
  }
  
  static void updateState(String stringState) {
    State<dynamic> state = states[stringState];
    // ignore: invalid_use_of_protected_member
    state.setState(() {
      // state.widget.createState().key = UniqueKey();
    });
  }

  static void updateStates() {
    for (MapEntry state in states.entries) {
      state.value.setState(() {
        // state.value.widget.createState().key = UniqueKey();
      });
    }
  }
}

class SnackBarController {

  GlobalKey<ScaffoldState> _scaffoldKey;
  
  SnackBarController._singleton();
  factory SnackBarController() {
    return _instance;
  }

  static final SnackBarController _instance = SnackBarController._singleton();

  set key(GlobalKey<ScaffoldState> scaffoldKey) => _scaffoldKey = scaffoldKey;

  void showSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(snackBar);
  }
  

}

class Util {

  static Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  static Color stringToColor(String c) {
    String valueString = c.split('(0x')[1].split(')')[0];
    int value = int.parse(valueString, radix: 16);
    return Color(value);
  }

  static String serviceToString(ServicesLister service) => service.toString().split(".")[1];

  static int _parseTime(String duration, String timeUnit) {
    final timeMatch = RegExp(r"\d+" + timeUnit).firstMatch(duration);

    if (timeMatch == null) {
      return 0;
    }
    final timeString = timeMatch.group(0);
    return int.parse(timeString.substring(0, timeString.length - 1));
  }
  static Duration toDuration(String isoString) {
    if (!RegExp(
            r"^(-|\+)?P(?:([-+]?[0-9,.]*)Y)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)W)?(?:([-+]?[0-9,.]*)D)?(?:T(?:([-+]?[0-9,.]*)H)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)S)?)?$")
        .hasMatch(isoString)) {
      throw ArgumentError("String does not follow correct format");
    }

    final weeks = _parseTime(isoString, "W");
    final days = _parseTime(isoString, "D");
    final hours = _parseTime(isoString, "H");
    final minutes = _parseTime(isoString, "M");
    final seconds = _parseTime(isoString, "S");

    return Duration(
      days: days + (weeks * 7),
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }


}