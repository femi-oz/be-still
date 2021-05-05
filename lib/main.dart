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
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/theme_provider.dart';

bool userFirestoreEmulator = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  setupLocator();
  await st.Settings.init();

  if (userFirestoreEmulator) {
    FirebaseFirestore.instance.settings = Settings(
        host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  }
//   FlutterError.onError = (FlutterErrorDetails details) async {
//     FlutterError.dumpErrorToConsole(details);
//     await Sentry.captureException(
//       details.exception,
//       stackTrace: details.stack,
//     );
//     await FirebaseCrashlytics.instance.recordError(
//   details.exception,
//   details.stack,
//   reason: 'a fatal error',
//   // Pass in 'fatal' argument
//   // fatal: true
// );
//     await locator<LogService>()
//         .createLog(details.exceptionAsString(), 'onError', 'MAIN/main/onError');
//     // if (kReleaseMode) exit(1);
//   };
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  await runZonedGuarded(() async {
    // await SentryFlutter.init((options) {
    //   options.dsn =
    //       'https://6a3b3509ae7e44ef8a8437960e2a7a14@o554552.ingest.sentry.io/5683235';
    // },
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
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);

    // await Sentry.captureException(
    //   error,
    //   stackTrace: stackTrace,
    // );
    await locator<LogService>().createLog(
        '${error.toString()}===${stackTrace.toString()}',
        'runZonedGuarded',
        'MAIN/main/runZonedGuarded');
  });
}
