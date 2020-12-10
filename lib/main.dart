import 'package:be_still/locator.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/theme_provider.dart';

void main() {
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
        ChangeNotifierProvider(create: (ctx) => UserProvider()),
        ChangeNotifierProvider(create: (ctx) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (ctx) => PrayerProvider()),
        ChangeNotifierProvider(create: (ctx) => SettingsProvider()),
        ChangeNotifierProvider(create: (ctx) => GroupProvider()),
        ChangeNotifierProvider(create: (ctx) => MiscProvider()),
      ],
      child: MyApp(),
    ),
  );
}
