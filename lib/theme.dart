import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { DARK, LIGHT }

class ThemeState extends ChangeNotifier {
  bool _isDarkTheme = false;

  ThemeState() {
    getTheme().then((type) {
      _isDarkTheme = type == ThemeType.DARK;
      notifyListeners();
    });
  }

  ThemeType get theme => _isDarkTheme ? ThemeType.DARK : ThemeType.LIGHT;
  set theme(ThemeType type) => setTheme(type);

  void setTheme(ThemeType type) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _isDarkTheme = type == ThemeType.DARK;
    bool status = await preferences.setBool('isDark', _isDarkTheme);

    if (status) notifyListeners();
  }

  Future<ThemeType> getTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _isDarkTheme = preferences.getBool('isDark') ?? false;
    return _isDarkTheme ? ThemeType.DARK : ThemeType.LIGHT;
  }
}

//Color(0xFF343539)

class ThemeDark {
  ThemeData view = ThemeData(
    /// FONT
    fontFamily: 'CormorantGaramond',

    /// GENERAL COLORS
    brightness: Brightness.dark,
    backgroundColor: Color(0xFF343539),

    /// SPECIFIC COLORS
    cardColor: Colors.grey[850],
    cursorColor: Colors.white54,
    shadowColor: Colors.white54,

    /// OTHER
    appBarTheme: AppBarTheme(shadowColor: Colors.grey[600]),
    unselectedWidgetColor: Colors.white54,

    /// TEXT
    textSelectionColor: Colors.white,
    textTheme: TextTheme(
      //body 1
      bodyText1: TextStyle(fontSize: 19.0, color: Colors.white),
      subtitle1: TextStyle(fontSize: 17.0, color: Colors.white54),
      //body 2
      bodyText2: TextStyle(fontSize: 17.0, color: Colors.white),
      subtitle2: TextStyle(fontSize: 15.0, color: Colors.white54),

      //headlines
      headline1: TextStyle(
          fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.w600),
      headline2: TextStyle(
          fontSize: 22.0, color: Colors.white, fontWeight: FontWeight.w600),
      headline3: TextStyle(
          fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w600),
      headline4: TextStyle(fontSize: 20.0, color: Colors.white54),
    ),
  );
}

//Color(0xFFf8f8f8)

class ThemeLight {
  ThemeData view = ThemeData(
    /// FONT
    fontFamily: 'CormorantGaramond',

    /// GENERAL COLORS
    brightness: Brightness.light,
    backgroundColor: Color(0xFFf5f5f5),

    /// SPECIFIC COLORS
    cardColor: Colors.grey[200],
    cursorColor: Colors.black54,
    shadowColor: Colors.black54,

    /// OTHER
    appBarTheme: AppBarTheme(shadowColor: Colors.black54),
    unselectedWidgetColor: Colors.grey[500],

    /// TEXT
    textSelectionColor: Colors.black,
    textTheme: TextTheme(
      //body 1
      bodyText1: TextStyle(fontSize: 19.0, color: Colors.black),
      subtitle1: TextStyle(fontSize: 17.0, color: Colors.black54),
      //body 2
      bodyText2: TextStyle(fontSize: 17.0, color: Colors.black),
      subtitle2: TextStyle(fontSize: 15.0, color: Colors.black54),

      //headlines
      headline1: TextStyle(
          fontSize: 25.0, color: Colors.black, fontWeight: FontWeight.w600),
      headline2: TextStyle(
          fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.w600),
      headline3: TextStyle(
          fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.w600),
      headline4: TextStyle(fontSize: 20.0, color: Colors.black54),
    ),
  );
}
