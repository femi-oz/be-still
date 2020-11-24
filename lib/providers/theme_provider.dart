import 'package:be_still/enums/theme_mode.dart';
import 'package:be_still/utils/prefs.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  DarkThemePreferenes darkThemePref = DarkThemePreferenes();
  bool _isDarkMode = false;
  bool get isDarkModeEnabled {
    return _isDarkMode;
  }

  String _colorMode;
  String get colorMode => _colorMode;

  Future changeTheme(String value) async {
    _colorMode = value;
    if (value == BThemeMode.auto) {
      _isDarkMode = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .platformBrightness ==
              Brightness.dark
          ? true
          : false;
    } else {
      _isDarkMode = value == BThemeMode.dark ? true : false;
    }
    await darkThemePref.setThemeMode(value);
    notifyListeners();
  }

  Future setDefaultTheme() async {
    var value = await darkThemePref.getThemeMode();
    _colorMode = value == BThemeMode.auto
        ? BThemeMode.auto
        : value == BThemeMode.dark
            ? BThemeMode.dark
            : BThemeMode.light;
    if (value == BThemeMode.auto) {
      _isDarkMode = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .platformBrightness ==
              Brightness.dark
          ? true
          : false;
    } else {
      _isDarkMode = value == BThemeMode.dark ? true : false;
    }
    notifyListeners();
  }
}
