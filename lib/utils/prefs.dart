import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkThemePreferenes {
  setThemeMode(String themeMode) async {
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

class SettingsPrefrences {
  setFaceIdSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFaceIdEnabled', value);
  }

  setContactAccessSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasAccessToContact', value);
  }

  Future<bool> getFaceIdSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFaceIdEnabled = prefs.getBool('isFaceIdEnabled') ?? false;
    return isFaceIdEnabled;
  }

  Future<bool> getContactAccessSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasAccessToContact = prefs.getBool('hasAccessToContact') ?? false;
    return hasAccessToContact;
  }
}
