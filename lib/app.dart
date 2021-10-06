import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/screens/splash/splash_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
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
    Future<void>.delayed(const Duration(milliseconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  @override
  void initState() {
    initDynamicLinks();
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).setDefaultTheme();
    });
    Provider.of<NotificationProvider>(context, listen: false)
        .initLocal(context);
    _initializeFlutterFireFuture = _initializeFlutterFire();
    _getPermissions();

    super.initState();
  }

  Future<void> initDynamicLinks() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        var actionCode = deepLink.queryParameters['oobCode'];
        try {
          await auth.checkActionCode(actionCode);
          await auth.applyActionCode(actionCode).then((value) async {
            NavigationService.instance.navigationKey.currentState.pushNamedAndRemoveUntil(
                EntryScreen.routeName, (Route<dynamic> route) => false);
            print('account verified');
            await Provider.of<MiscProvider>(context, listen: false)
                .setLoadStatus(true);
          });

          // If successful, reload the user:
          auth.currentUser.reload();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'invalid-action-code') {
            print('The code is invalid.');
          }
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  void _getPermissions() async {
    try {
      if (Settings.isAppInit) {
        await Permission.contacts.request().then((p) =>
            Settings.enabledContactPermission = p == PermissionStatus.granted);
      }
    } catch (e, s) {
      BeStilDialog.showErrorDialog(context, e, null, s);
    }
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
        await initDynamicLinks();
        await Future.delayed(Duration(milliseconds: 1000));
        var backgroundTime =
            DateTime.fromMillisecondsSinceEpoch(Settings.backgroundTime);

        if (DateTime.now().difference(backgroundTime) > Duration(hours: 48)) {
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .signOut();
          await NavigationService.instance.navigateTo(LoginScreen.routeName);
        }
        final userId =
            Provider.of<UserProvider>(context, listen: false).currentUser?.id;
        final notifications =
            Provider.of<NotificationProvider>(context, listen: false)
                .localNotifications;
        if (userId != null)
          Provider.of<PrayerProvider>(context, listen: false)
              .checkPrayerValidity(userId, notifications);
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
        Settings.backgroundTime = DateTime.now().millisecondsSinceEpoch;
        print('AppLifecycleState inactive ===> ');
        break;
      case AppLifecycleState.paused:
        print('AppLifecycleState paused ===> ');
        Settings.backgroundTime = DateTime.now().millisecondsSinceEpoch;
        break;
      case AppLifecycleState.detached:
        print('AppLifecycleState detached ===> ');
        Settings.backgroundTime = DateTime.now().millisecondsSinceEpoch;
        break;
    }
  }

  gotoPage(message) async {
    if (message.type == NotificationType.prayer_time) {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayerTimePrayers(message.entityId);

      Provider.of<MiscProvider>(context, listen: false).setCurrentPage(2);
      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
    }
    if (message.type == NotificationType.prayer) {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayer(message.entityId);
      // NavigationService.instance.navigateToReplacement(PrayerDetails());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (ctx, theme, _) => FutureBuilder(
        future: _initializeFlutterFireFuture,
        builder: (contect, snapshot) => MaterialApp(
          builder: (BuildContext context, Widget child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
                data: data.copyWith(textScaleFactor: 1), child: child);
          },
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
