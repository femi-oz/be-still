import 'package:be_still/screens/add_update/add_update.dart';
import 'package:be_still/screens/create_group/create_group_screen.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/notifications/notifications_screen.dart';
import 'package:be_still/screens/security/Create_Account/Widgets/success.dart';
import 'package:be_still/screens/security/Create_Account/create_account_screen.dart';
import 'package:be_still/screens/security/Forget_Password/forget_password.dart';
import 'package:be_still/screens/grow_my_prayer_life/devotion_and_reading_plans.dart';
import 'package:be_still/screens/grow_my_prayer_life/grow_my_prayer_life_screen.dart';
import 'package:be_still/screens/grow_my_prayer_life/recommended_bibles_screen.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/screens/Settings/settings_screen.dart';
import 'package:be_still/screens/security/local_auth/local_auth.dart';
import 'package:be_still/screens/splash/splash_screen.dart';

final routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  EntryScreen.routeName: (context) => PrayerScreen(),
  SettingsScreen.routeName: (context) => SettingsScreen(),
  CreateAccountScreen.routeName: (context) => CreateAccountScreen(),
  ForgetPassword.routeName: (context) => ForgetPassword(),
  PrayerDetails.routeName: (context) => PrayerDetails(),
  PrayerMode.routeName: (context) => PrayerMode(),
  AddUpdate.routeName: (context) => AddUpdate(),
  GrowMyPrayerLifeScreen.routeName: (context) => GrowMyPrayerLifeScreen(),
  RecommenededBibles.routeName: (context) => RecommenededBibles(),
  DevotionPlans.routeName: (context) => DevotionPlans(),
  CreateGroupScreen.routeName: (context) => CreateGroupScreen(),
  LocalAuth.routeName: (context) => LocalAuth(),
  CreateAccountSuccess.routeName: (context) => CreateAccountSuccess(),
  NotificationsScreen.routeName: (context) => NotificationsScreen(),
  EntryScreen.routeName: (ctx) => EntryScreen(),
};
