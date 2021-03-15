import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/screens/splash/splash_screen.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import './utils/routes.dart' as rt;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).setDefaultTheme();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();

    return Consumer<ThemeProvider>(
      builder: (ctx, theme, _) => MaterialApp(
        title: 'Be Still',
        debugShowCheckedModeBanner: false,
        theme: theme.isDarkModeEnabled
            ? appThemeData[AppTheme.DarkTheme]
            : appThemeData[AppTheme.LightTheme],
        initialRoute: '/',
        routes: rt.routes,
        navigatorKey: navState,
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (ctx) => SplashScreen());
        },
      ),
    );
  }
}
