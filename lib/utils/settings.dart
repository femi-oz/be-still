import 'package:be_still/enums/theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static SharedPreferences? sharedPrefs;
  static Future init() async =>
      sharedPrefs = await SharedPreferences.getInstance();

  static const String THEME_MODE_KEY = 'theme_mode';
  static const String REMEMBER_ME_KEY = 'remember_me_';
  static const String LAST_USER = 'last_user_info_';
  static const String USER_PASSWORD = 'user_password_';
  static const String SNOOZE_DURATION = 'snooze_duration';
  static const String SNOOZE_INTERVAL = 'snooze_interval';
  static const String ENABLE_LOCAL_AUTH = 'enable_local_auth_';
  static const String SET_ENABLE_LOCAL_AUTH = 'set_enable_local_auth_';
  static const String CONTACT_PERMISSION = 'contact_permission';
  static const String BACKGROUND_TIME = 'background_time';
  static const String APP_INIT = 'app_init';

  static set themeMode(String mode) =>
      sharedPrefs?.setString(THEME_MODE_KEY, mode);

  static String get themeMode =>
      sharedPrefs?.getString(THEME_MODE_KEY) ?? BsThemeMode.light;

  static bool _dark = false;

  static bool get dark => _dark;
  static setDark(bool value) => _dark = value;

  static bool isDarkMode =
      (sharedPrefs?.getString(THEME_MODE_KEY) == BsThemeMode.auto
          ? MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .platformBrightness ==
              Brightness.dark
          : sharedPrefs?.getString(THEME_MODE_KEY) == BsThemeMode.dark);

  static set rememberMe(bool value) =>
      sharedPrefs?.setBool(REMEMBER_ME_KEY, value);

  static bool get rememberMe => sharedPrefs?.getBool(REMEMBER_ME_KEY) ?? false;

  static set lastUser(String user) => sharedPrefs?.setString(LAST_USER, user);

  static String get lastUser => sharedPrefs?.getString(LAST_USER) ?? '';

  static set userPassword(String password) =>
      sharedPrefs?.setString(USER_PASSWORD, password);
  static String get userPassword => sharedPrefs?.getString(USER_PASSWORD) ?? '';

  static set backgroundTime(int time) =>
      sharedPrefs?.setInt(BACKGROUND_TIME, time);
  static int get backgroundTime => sharedPrefs?.getInt(BACKGROUND_TIME) ?? 0;

  static set snoozeDuration(String duration) =>
      sharedPrefs?.setString(SNOOZE_DURATION, duration);
  static String get snoozeDuration =>
      sharedPrefs?.getString(SNOOZE_DURATION) ?? '0';

  static set snoozeInterval(String interval) =>
      sharedPrefs?.setString(SNOOZE_INTERVAL, interval);
  static String get snoozeInterval =>
      sharedPrefs?.getString(SNOOZE_INTERVAL) ?? '0';

  static set enableLocalAuth(bool isAuthEnabled) =>
      sharedPrefs?.setBool(ENABLE_LOCAL_AUTH, isAuthEnabled);

  static bool get enableLocalAuth =>
      sharedPrefs?.getBool(ENABLE_LOCAL_AUTH) ?? false;

  static set setenableLocalAuth(bool isAuthEnabled) =>
      sharedPrefs?.setBool(SET_ENABLE_LOCAL_AUTH, isAuthEnabled);

  static bool get setenableLocalAuth =>
      sharedPrefs?.getBool(SET_ENABLE_LOCAL_AUTH) ?? false;

  static set isAppInit(bool isAppInit) =>
      sharedPrefs?.setBool(APP_INIT, isAppInit);

  static bool get isAppInit => sharedPrefs?.getBool(APP_INIT) ?? true;
  static set enabledContactPermission(bool isContactEnabled) =>
      sharedPrefs?.setBool(CONTACT_PERMISSION, isContactEnabled);

  static bool get enabledContactPermission =>
      sharedPrefs?.getBool(CONTACT_PERMISSION) ?? false;
}
