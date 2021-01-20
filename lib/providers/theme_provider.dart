import 'package:be_still/enums/theme_mode.dart';
import 'package:be_still/utils/settings.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  Settings darkThemePref = Settings();
  bool _isDarkMode = false;
  bool get isDarkModeEnabled => _isDarkMode;

  String _currentTheme;
  String get currentTheme => _currentTheme;

  Future changeTheme(String theme) async {
    _currentTheme = theme;
    _isDarkMode = theme == BsThemeMode.auto ? MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness == Brightness.dark : theme == BsThemeMode.dark;

    Settings.themeMode = theme;
    notifyListeners();
  }

  Future setDefaultTheme() async {
    _currentTheme = Settings.themeMode ?? BsThemeMode.auto;
    _isDarkMode = _currentTheme == BsThemeMode.auto
        ? MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness == Brightness.dark
        : _currentTheme == BsThemeMode.dark;
  }
}
