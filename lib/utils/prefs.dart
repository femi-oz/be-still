import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkThemePreferenes {
  addThemeMode(String themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', themeMode);
  }

  Future<String> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeMode =
        prefs.getString('themeMode') ?? ThemeMode.light.toString();
    return themeMode;
  }
}
