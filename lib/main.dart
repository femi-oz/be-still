import 'package:be_still/src/screens/AddPrayer/add_prayer_screen.dart';
import 'package:be_still/src/screens/AddUpdate/add_update.dart';
import 'package:be_still/src/screens/GrowMyPrayerLife/devotion_and_reading_plans.dart';
import 'package:be_still/src/screens/GrowMyPrayerLife/grow_my_prayer_life_screen.dart';
import 'package:be_still/src/screens/GrowMyPrayerLife/recommended_bibles_screen.dart';
import 'package:be_still/src/screens/PrayMode/pray_mode_screen.dart';
import 'package:be_still/src/screens/PrayerDetails/prayer_details_screen.dart';
import 'package:flutter/material.dart';
import 'src/screens/Create_Account/create_account_screen.dart';
import 'src/screens/Forget_Password/forget_password.dart';
import 'package:be_still/src/screens/Settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'src/Providers/app_provider.dart';
import 'src/screens/Login/login_screen.dart';
import 'src/screens/Prayer/prayer_screen.dart';
import 'src/widgets/Theme/app_theme.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (ctx) => AppProvider(),
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    return MaterialApp(
      title: 'Be Still',
      theme: _app.isDarkModeEnabled
          ? appThemeData[AppTheme.DarkTheme]
          : appThemeData[AppTheme.LightTheme],
      routes: {
        '/': (context) => LandingPage(),
        SettingsScreen.routeName: (context) => SettingsScreen(),
        CreateAccountScreen.routeName: (context) => CreateAccountScreen(),
        ForgetPassword.routeName: (context) => ForgetPassword(),
        AddPrayer.routeName: (context) => AddPrayer(),
        PrayerDetails.routeName: (context) => PrayerDetails(),
        PrayerMode.routeName: (context) => PrayerMode(),
        AddUpdate.routeName: (context) => AddUpdate(),
        GrowMyPrayerLifeScreen.routeName: (context) => GrowMyPrayerLifeScreen(),
        RecommenededBibles.routeName: (context) => RecommenededBibles(),
        DevotionPlans.routeName: (context) => DevotionPlans(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    return _app.isAuthenticated ? PrayerScreen() : LoginScreen();
  }
}
