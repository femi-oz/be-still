import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/splash/splash_screen.dart';
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
    Provider.of<ThemeProvider>(context, listen: false).setDefaultTheme();
    // darkThemePref.loadPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Be Still',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).isDarkModeEnabled
          ? appThemeData[AppTheme.DarkTheme]
          : appThemeData[AppTheme.LightTheme],
      initialRoute: '/',
      routes: rt.routes,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (ctx) => SplashScreen());
      },
    );
  }
}
