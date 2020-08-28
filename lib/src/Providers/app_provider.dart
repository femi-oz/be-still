import 'package:be_still/src/Models/user.model.dart';
import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  // bool _isDarkModeEnabled = false;
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
  UserModel _user;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  bool get isDarkModeEnabled {
    print(_colorOption == 'dark');
    return _colorMode == 'dark';
  }

  UserModel get user {
    return _user;
  }

  String get colorMode {
    return _colorOption;
  }

  void login() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
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
    // _isDarkModeEnabled = (_colorMode == 'light') ? false : true;
    _colorOption = value;
    notifyListeners();
  }

  void setCurrentUser(user) {
    _user = user;
  }
}
