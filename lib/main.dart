import 'dart:async';
import 'package:be_still/controllers/root_binding.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/providers/v2/auth_provider.dart';
import 'package:be_still/providers/v2/devotional_provider.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/theme_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/utils/settings.dart' as st;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/v2/notification_provider.dart';

bool userFirestoreEmulator = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await notificationRequest();

  setupLocator();
  await st.Settings.init();

  if (userFirestoreEmulator) {
    FirebaseFirestore.instance.settings = Settings(
        host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  }
  await RootBinding().dependencies();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  await runZonedGuarded(() async {
    runApp(
      MultiProvider(
        providers: [
          //=========================================================//
          ChangeNotifierProvider(create: (ctx) => UserProviderV2()),
          ChangeNotifierProvider(create: (ctx) => AuthenticationProviderV2()),
          ChangeNotifierProvider(create: (ctx) => PrayerProviderV2()),
          ChangeNotifierProvider(create: (ctx) => GroupProviderV2()),
          ChangeNotifierProvider(create: (ctx) => NotificationProviderV2()),
          ChangeNotifierProvider(create: (ctx) => MiscProviderV2()),
          ChangeNotifierProvider(create: (ctx) => DevotionalProviderV2()),
          ChangeNotifierProvider(create: (ctx) => ThemeProviderV2()),
        ],
        child: MyApp(),
      ),
    );
  }, (Object error, StackTrace stackTrace) async {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);

    await locator<LogService>().createLog(
        '${error.toString()}===${stackTrace.toString()}',
        'runZonedGuarded',
        'MAIN/main/runZonedGuarded');
  });
}

notificationRequest() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}
