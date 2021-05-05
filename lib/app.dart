import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_time/prayer_time_screen.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/screens/security/login/login_screen.dart';
import 'package:be_still/screens/splash/splash_screen.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import './utils/routes.dart' as rt;

final _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
final _kTestingCrashlytics = true;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).setDefaultTheme();
    });
    Provider.of<NotificationProvider>(context, listen: false)
        .initLocal(context);
    // FirebaseCrashlytics.instance.crash();
    _initializeFlutterFireFuture = _initializeFlutterFire();

    super.initState();
  }

  Future<void> _initializeFlutterFire() async {
    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    // Pass all uncaught errors to Crashlytics.
    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    };

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        var backgroundTime = DateTime.parse(Settings.backgroundTime);
        if (DateTime.now().difference(backgroundTime) > Duration(hours: 24)) {
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .signOut();
          await LocalNotification.clearAll();
          Navigator.of(context).pushNamedAndRemoveUntil(
            LoginScreen.routeName,
            (Route<dynamic> route) => false,
          );
        }
        final userId =
            Provider.of<UserProvider>(context, listen: false).currentUser?.id;
        if (userId != null)
          Provider.of<PrayerProvider>(context, listen: false)
              .checkPrayerValidity(userId);
        print(
            'message -- didChangeAppLifecycleState before ===> ${Provider.of<NotificationProvider>(context, listen: false).message}');

        await Provider.of<NotificationProvider>(context, listen: false)
            .initLocal(context);
        print(
            'message -- didChangeAppLifecycleState after ===> ${Provider.of<NotificationProvider>(context, listen: false).message}');

        var message =
            Provider.of<NotificationProvider>(context, listen: false).message;
        if (message != null) {
          print('AppLifecycleState resume ===> ${message.entityId}');
          await gotoPage(message);
          Provider.of<NotificationProvider>(context, listen: false)
              .clearMessage();
        }
        // do check, route, clear message
        break;
      case AppLifecycleState.inactive:
        Settings.backgroundTime = DateTime.now().toString();
        print('AppLifecycleState inactive ===> ');
        break;
      case AppLifecycleState.paused:
        print('AppLifecycleState paused ===> ');
        break;
      case AppLifecycleState.detached:
        print('AppLifecycleState detached ===> ');
        break;
    }
  }

  gotoPage(message) async {
    if (message.type == NotificationType.prayer_time) {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayerTimePrayers(message.entityId);

      NavigationService.instance.navigateToReplacement(PrayerTime());
    }
    if (message.type == NotificationType.prayer) {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayer(message.entityId);
      NavigationService.instance.navigateToReplacement(PrayerDetails());
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Consumer<ThemeProvider>(
      builder: (ctx, theme, _) => FutureBuilder(
        future: _initializeFlutterFireFuture,
        builder: (contect, snapshot) => MaterialApp(
          title: 'Be Still',
          debugShowCheckedModeBanner: false,
          theme: theme.isDarkModeEnabled
              ? appThemeData[AppTheme.DarkTheme]
              : appThemeData[AppTheme.LightTheme],
          initialRoute: '/',
          routes: rt.routes,
          navigatorKey: NavigationService.instance.navigationKey,
          onUnknownRoute: (settings) {
            return MaterialPageRoute(builder: (ctx) => SplashScreen());
          },
        ),
      ),
    );
  }
}
