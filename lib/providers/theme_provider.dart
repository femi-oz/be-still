// import 'package:be_still/enums/theme_mode.dart';
// import 'package:be_still/utils/essentials.dart';
// import 'package:be_still/utils/settings.dart';
// import 'package:flutter/material.dart';

// class ThemeProvider with ChangeNotifier {
//   Settings darkThemePref = Settings();

//   bool _isDarkMode = false;
//   bool get isDarkModeEnabled => _isDarkMode;

//   String _currentTheme = BsThemeMode.auto;
//   String get currentTheme => _currentTheme;

//   ThemeData _themeData = ThemeData();
//   ThemeData get currentThemeData => _themeData;

//   Future changeTheme(String theme) async {
//     _currentTheme = theme;
//     _isDarkMode = theme == BsThemeMode.auto
//         ? MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
//                 .platformBrightness ==
//             Brightness.dark
//         : theme == BsThemeMode.dark;

//     AppColors.darkMode = _isDarkMode;
//     Settings.themeMode = theme;
//     notifyListeners();
//   }

//   toggle() async {
//     var theme = _currentTheme == BsThemeMode.dark
//         ? BsThemeMode.light
//         : BsThemeMode.dark;
//     changeTheme(theme);
//   }

//   Future setDefaultTheme() async {
//     _currentTheme = Settings.themeMode;
//     _isDarkMode = _currentTheme == BsThemeMode.auto
//         ? MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
//                 .platformBrightness ==
//             Brightness.dark
//         : _currentTheme == BsThemeMode.dark;

//     AppColors.darkMode = _isDarkMode;
//     Settings.themeMode = _currentTheme;
//     notifyListeners();
//   }
// }
