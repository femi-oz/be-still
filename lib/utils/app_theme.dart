import 'package:flutter/material.dart';

enum AppTheme { DarkTheme, LightTheme }
final appThemeData = {
  AppTheme.DarkTheme: ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Avenir Next',
    appBarTheme: AppBarTheme(
      color: Color(0xFF0D1319),
    ),
  ),
  AppTheme.LightTheme: ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Avenir Next',
    appBarTheme: AppBarTheme(
      color: Color(0xFFFFFFFF),
    ),
  ),
};
