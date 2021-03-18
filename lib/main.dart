import 'dart:async';
import 'package:be_still/locator.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/log_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/utils/settings.dart' as st;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/theme_provider.dart';

bool userFirestoreEmulator = false;
void main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    FlutterError.dumpErrorToConsole(details);
    await locator<LogService>()
        .createLog(details.exceptionAsString(), 'onError', 'MAIN/main/onError');
    // if (kReleaseMode) exit(1);
  };
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await st.Settings.init();
  await Firebase.initializeApp();
  if (userFirestoreEmulator) {
    FirebaseFirestore.instance.settings = Settings(
        host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  }
  await runZonedGuarded(() async {
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
          ChangeNotifierProvider(create: (ctx) => NotificationProvider()),
          ChangeNotifierProvider(create: (ctx) => DevotionalProvider()),
          ChangeNotifierProvider(create: (ctx) => LogProvider()),
        ],
        child: MyApp(),
      ),
    );
  }, (Object error, StackTrace stackTrace) async {
    await locator<LogService>().createLog(
        '${error.toString()}===${stackTrace.toString()}',
        'runZonedGuarded',
        'MAIN/main/runZonedGuarded');
  });
}
