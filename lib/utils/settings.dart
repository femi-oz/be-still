import 'package:be_still/enums/theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static SharedPreferences sharedPrefs;
  static Future init() async => sharedPrefs = await SharedPreferences.getInstance();

  static const String THEME_MODE_KEY = 'theme_mode';

  static set themeMode(String mode) => sharedPrefs.setString(THEME_MODE_KEY, mode);

  static String get themeMode => sharedPrefs.getString(THEME_MODE_KEY) ?? BsThemeMode.light;

  static bool isDarkMode = !(sharedPrefs.getString(THEME_MODE_KEY) == BsThemeMode.auto
      ? MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness == Brightness.dark
      : sharedPrefs.getString(THEME_MODE_KEY) == BsThemeMode.dark);
}
