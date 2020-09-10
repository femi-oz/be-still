import 'package:be_still/Providers/app_provider.dart';
import 'package:be_still/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'widgets/Theme/app_theme.dart';
import './utils/routes.dart' as rt;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Be Still',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<AppProvider>(context).isDarkModeEnabled
          ? appThemeData[AppTheme.DarkTheme]
          : appThemeData[AppTheme.LightTheme],
      initialRoute: '/splash',
      routes: rt.routes,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (ctx) => SplashScreen());
      },
    );
  }
}
