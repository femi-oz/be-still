import 'package:be_still/utils/prefs.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  DarkThemePreferenes darkThemePref = DarkThemePreferenes();
  bool _isDarkMode = false;
  bool get isDarkModeEnabled {
    return _isDarkMode;
  }

  ThemeMode _colorMode;
  ThemeMode get colorMode => _colorMode;

  Future changeTheme(ThemeMode value) async {
    _colorMode = value;
    if (value == ThemeMode.system) {
      _isDarkMode = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .platformBrightness ==
              Brightness.dark
          ? true
          : false;
    } else {
      _isDarkMode = value == ThemeMode.dark ? true : false;
    }
    await darkThemePref.addThemeMode(value.toString());
    notifyListeners();
  }

  Future setDefaultTheme() async {
    var value = await darkThemePref.getThemeMode();
    if (value == ThemeMode.system.toString()) {
      _isDarkMode = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .platformBrightness ==
              Brightness.dark
          ? true
          : false;
    } else {
      _isDarkMode = value == ThemeMode.dark.toString() ? true : false;
    }
    notifyListeners();
  }
}
