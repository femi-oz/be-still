import 'package:be_still/enums/theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static SharedPreferences sharedPrefs;
  static Future init() async =>
      sharedPrefs = await SharedPreferences.getInstance();

  static const String THEME_MODE_KEY = 'theme_mode';
  static const String REMEMBER_ME_KEY = 'remember_me';
  static const String LAST_USER = 'last_user';
  static const String LAST_FOREGROUND_TIME = 'last_foreground_time';
  static const String LAST_BACKGROUND_TIME = 'last_background_time';
  static const String USER_KEY_REFERENCE = 'user_key_reference';
  static const String USER_PASSWORD = 'user_password';
  static const String ENABLE_LOCAL_AUTH = 'enable_local_auth';
  static const String CONTACT_PERMISSION = 'contact_permission';
  static const String APP_INIT = 'app_init';

  static set themeMode(String mode) =>
      sharedPrefs.setString(THEME_MODE_KEY, mode);

  static String get themeMode =>
      sharedPrefs.getString(THEME_MODE_KEY) ?? BsThemeMode.light;

  static bool _dark = false;

  static bool get dark => _dark;
  static setDark(bool value) => _dark = value;

  static bool isDarkMode =
      (sharedPrefs.getString(THEME_MODE_KEY) == BsThemeMode.auto
          ? MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .platformBrightness ==
              Brightness.dark
          : sharedPrefs.getString(THEME_MODE_KEY) == BsThemeMode.dark);

  static set rememberMe(bool value) =>
      sharedPrefs.setBool(REMEMBER_ME_KEY, value);

  static bool get rememberMe => sharedPrefs.getBool(REMEMBER_ME_KEY) ?? false;

  static set lastUser(String username) =>
      sharedPrefs.setString(LAST_USER, username);

  static String get lastUser => sharedPrefs.getString(LAST_USER) ?? '';

  static set userKeyRefernce(String keyReference) =>
      sharedPrefs.setString(USER_KEY_REFERENCE, keyReference);

  static String get userKeyRefernce =>
      sharedPrefs.getString(USER_KEY_REFERENCE) ?? '';

  static set userPassword(String password) =>
      sharedPrefs.setString(USER_PASSWORD, password);
  static String get userPassword => sharedPrefs.getString(USER_PASSWORD) ?? '';

  static set lastForegroundTime(String foregroundtime) =>
      sharedPrefs.setString(LAST_FOREGROUND_TIME, foregroundtime);
  static String get lastForegroundTime =>
      sharedPrefs.getString(LAST_FOREGROUND_TIME) ?? '';

  static set lastBackgroundTime(String backgroundtime) =>
      sharedPrefs.setString(LAST_BACKGROUND_TIME, backgroundtime);
  static String get lastBackgroundTime =>
      sharedPrefs.getString(LAST_BACKGROUND_TIME) ?? '';

  static set enableLocalAuth(bool isAuthEnabled) =>
      sharedPrefs.setBool(ENABLE_LOCAL_AUTH, isAuthEnabled);

  static bool get enableLocalAuth =>
      sharedPrefs.getBool(ENABLE_LOCAL_AUTH) ?? false;

  static set isAppInit(bool isAppInit) =>
      sharedPrefs.setBool(APP_INIT, isAppInit);

  static bool get isAppInit => sharedPrefs.getBool(APP_INIT) ?? true;
  static set enabledContactPermission(bool isContactEnabled) =>
      sharedPrefs.setBool(CONTACT_PERMISSION, isContactEnabled);

  static bool get enabledContactPermission =>
      sharedPrefs.getBool(CONTACT_PERMISSION) ?? false;
}
