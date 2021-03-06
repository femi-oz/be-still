import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/theme_mode.dart';
import 'package:be_still/models/v2/notification_message.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/auth_provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/theme_provider.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/screens/splash/splash_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
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
  late Future<void> _initializeFlutterFireFuture;
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(milliseconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  @override
  void didChangePlatformBrightness() {
    print(WidgetsBinding.instance.window.platformBrightness);

    Provider.of<ThemeProviderV2>(context, listen: false)
        .changeTheme(BsThemeMode.auto);
    super.didChangePlatformBrightness();
  }

  @override
  void initState() {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      WidgetsBinding.instance.addObserver(this);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ThemeProviderV2>(context, listen: false).setDefaultTheme();
      });
      Provider.of<NotificationProviderV2>(context, listen: false)
          .initLocal(context);
      _initializeFlutterFireFuture = _initializeFlutterFire();

      var initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      var initializationSettingsIOs = IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification: (_, __, ___, ____) {
            Provider.of<NotificationProviderV2>(context, listen: false)
                .setLocalNotifications();
            _flutterLocalNotificationsPlugin.show(
              _,
              __,
              ___,
              NotificationDetails(
                  android: androidNotificationAndroidSpecifics,
                  iOS: iOSPlatformChannelSpecifics),
              payload: "{\"type\": \"fcm message\"}",
            );
            print('on message');
          });
      var initSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOs);

      _flutterLocalNotificationsPlugin.initialize(initSettings,
          onSelectNotification: _onSelectNotification);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        showNotification(message);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        AppController appController = Get.find();
        appController.setCurrentPage(14, false, 0);
      });
      FirebaseMessaging.instance.getInitialMessage().then((value) {
        if (value != null) {
          AppController appController = Get.find();
          appController.setCurrentPage(14, false, 0);
        }
      });
    } catch (e, s) {
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, null, s);
    }

    super.initState();
  }

  final IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(threadIdentifier: 'thread_id');
  final AndroidNotificationDetails androidNotificationAndroidSpecifics =
      AndroidNotificationDetails('groupChannelId', 'groupChannelName',
          channelDescription: 'groupChannelDescription',
          importance: Importance.max,
          priority: Priority.high,
          groupKey: 'groupKey');
  Future<void> showNotification(RemoteMessage message) async {
    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      NotificationDetails(
          android: androidNotificationAndroidSpecifics,
          iOS: iOSPlatformChannelSpecifics),
      payload: "{\"type\": \"fcm message\"}",
    );
  }

  Future _onSelectNotification(String? payload) async {
    AppController appController = Get.find();
    appController.setCurrentPage(14, false, 0);
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
    Function(FlutterErrorDetails)? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      if (originalOnError != null) originalOnError(errorDetails);
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
    try {
      switch (state) {
        case AppLifecycleState.resumed:
          await Future.delayed(Duration(milliseconds: 1000));
          var backgroundTime =
              DateTime.fromMillisecondsSinceEpoch(Settings.backgroundTime);

          if (DateTime.now().difference(backgroundTime) > Duration(hours: 48)) {
            await Provider.of<AuthenticationProviderV2>(context, listen: false)
                .signOut();
            await NavigationService.instance.navigateTo(LoginScreen.routeName);
          }

          print(
              'message -- didChangeAppLifecycleState before ===> ${Provider.of<NotificationProviderV2>(context, listen: false).message}');

          await Provider.of<NotificationProviderV2>(context, listen: false)
              .initLocal(context);
          print(
              'message -- didChangeAppLifecycleState after ===> ${Provider.of<NotificationProviderV2>(context, listen: false).message}');

          var message =
              Provider.of<NotificationProviderV2>(context, listen: false)
                  .message;
          if ((message.entityId ?? '').isNotEmpty) {
            print('AppLifecycleState resume ===> ${message.entityId}');
            await gotoPage(message);
            Provider.of<NotificationProviderV2>(context, listen: false)
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
    } catch (e, s) {
      BeStilDialog.showErrorDialog(
          context, StringUtils.errorOccured, UserDataModel(), s);
    }
  }

  gotoPage(NotificationMessageModel message) async {
    try {
      if (message.type == NotificationType.prayer_time) {
        AppController appController = Get.find();
        appController.setCurrentPage(2, false, 0);
      }
      if (message.type == NotificationType.reminder) {
        if (message.isGroup ?? false) {
          AppController appController = Get.find();
          appController.setCurrentPage(9, false, 0);
        } else {
          Provider.of<PrayerProviderV2>(context, listen: false)
              .setCurrentPrayerId(message.entityId ?? '');
          AppController appController = Get.find();
          appController.setCurrentPage(7, false, 0);
        }
      }
    } catch (e, s) {
      BeStilDialog.showErrorDialog(
          context, StringUtils.errorOccured, UserDataModel(), s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderV2>(
      builder: (ctx, theme, _) => FutureBuilder(
        future: _initializeFlutterFireFuture,
        builder: (contect, snapshot) => GetMaterialApp(
          builder: (BuildContext context, Widget? child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
                data: data.copyWith(textScaleFactor: 1),
                child: child ?? SizedBox.shrink());
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
