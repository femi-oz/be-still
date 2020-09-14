import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  String _colorOption =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .platformBrightness ==
              Brightness.dark
          ? 'dark'
          : 'light';
  String _colorMode = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
              .platformBrightness ==
          Brightness.dark
      ? 'dark'
      : 'light';

  bool get isDarkModeEnabled {
    print(_colorOption == 'dark');
    return _colorMode == 'dark';
  }

  String get colorMode {
    return _colorOption;
  }

  void changeTheme(value) {
    _colorMode = value;
    if (_colorMode == 'auto') {
      _colorMode = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .platformBrightness ==
              Brightness.dark
          ? 'dark'
          : 'light';
    }
    _colorOption = value;
    notifyListeners();
  }
}
