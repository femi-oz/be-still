import 'package:be_still/src/screens/AddPrayer/add_prayer_screen.dart';
import 'package:be_still/src/screens/AddUpdate/add_update.dart';
import 'package:be_still/src/screens/create_group/create_group_screen.dart';
import 'package:be_still/src/screens/security/Create_Account/create_account_screen.dart';
import 'package:be_still/src/screens/security/Forget_Password/forget_password.dart';
import 'package:be_still/src/screens/GrowMyPrayerLife/devotion_and_reading_plans.dart';
import 'package:be_still/src/screens/GrowMyPrayerLife/grow_my_prayer_life_screen.dart';
import 'package:be_still/src/screens/GrowMyPrayerLife/recommended_bibles_screen.dart';
import 'package:be_still/src/screens/security/Login/login_screen.dart';
import 'package:be_still/src/screens/PrayMode/pray_mode_screen.dart';
import 'package:be_still/src/screens/Prayer/prayer_screen.dart';
import 'package:be_still/src/screens/PrayerDetails/prayer_details_screen.dart';
import 'package:be_still/src/screens/Settings/settings_screen.dart';
import 'package:be_still/src/screens/splash/splash_screen.dart';

final routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  PrayerScreen.routeName: (context) => PrayerScreen(),
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
  CreateGroupScreen.routeName: (context) => CreateGroupScreen(),
};
