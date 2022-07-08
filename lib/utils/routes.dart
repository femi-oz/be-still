import 'package:be_still/screens/create_group/create_group_screen.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/notifications/notifications_screen.dart';
import 'package:be_still/screens/security/Create_Account/Widgets/success.dart';
import 'package:be_still/screens/security/Create_Account/create_account_screen.dart';
import 'package:be_still/screens/security/Forget_Password/forget_password.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/screens/security/local_auth/local_auth.dart';
import 'package:be_still/screens/splash/splash_screen.dart';

final routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  CreateAccountScreen.routeName: (context) => CreateAccountScreen(),
  ForgetPassword.routeName: (context) => ForgetPassword(),
  // PrayerDetails.routeName: (context) => PrayerDetails(),
  // AddUpdate.routeName: (context) => AddUpdate(),
  CreateGroupScreen.routeName: (context) => CreateGroupScreen(),
  LocalAuth.routeName: (context) => LocalAuth(),
  CreateAccountSuccess.routeName: (context) => CreateAccountSuccess(),
  NotificationsScreen.routeName: (context) => NotificationsScreen(),
  EntryScreen.routeName: (context) => EntryScreen(),
};
