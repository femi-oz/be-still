import 'package:be_still/src/Providers/app_provider.dart';
import 'package:be_still/src/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/widgets/Theme/app_theme.dart';
import './src/utils/routes.dart' as rt;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
