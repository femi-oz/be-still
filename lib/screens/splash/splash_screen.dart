import 'dart:async';
import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/auth_provider.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/services/v2/migration.service.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _textAnimationController;
  AuthenticationProviderV2 _authenticationProvider = AuthenticationProviderV2();

  var _isInit = true;

  @override
  void initState() {
    _textAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3))
          ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        startTime();
      });
      setState(() => _isInit = false);
    }
    super.didChangeDependencies();
  }

  startTime() async {
    var duration = new Duration(seconds: 5);
    return new Timer(duration, () => route());
  }

  void _getPermissions() async {
    try {
      if (Settings.isAppInit) {
        await Permission.contacts.request().then((p) =>
            Settings.enabledContactPermission = p == PermissionStatus.granted);
      }
    } catch (e, s) {
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), UserDataModel(), s);
    }
  }

  Future<void> setRouteDestination() async {
    try {
      final message =
          Provider.of<NotificationProviderV2>(context, listen: false).message;
      if ((message.entityId ?? '').isNotEmpty) {
        WidgetsBinding.instance?.addPostFrameCallback((_) async {
          if (message.type == NotificationType.prayer_time) {
            AppController appController = Get.find();
            appController.setCurrentPage(2, false, 0);
            Provider.of<MiscProviderV2>(context, listen: false)
                .setLoadStatus(true);
            Navigator.of(context).pushNamedAndRemoveUntil(
                EntryScreen.routeName, (Route<dynamic> route) => false);
          }
          if (message.type == NotificationType.prayer) {
            Provider.of<PrayerProviderV2>(context, listen: false)
                .setCurrentPrayerId(message.entityId ?? '');
          }
        });
        Provider.of<NotificationProviderV2>(context, listen: false)
            .clearMessage();
      } else {
        Provider.of<MiscProviderV2>(context, listen: false).setLoadStatus(true);
        Navigator.of(context).pushNamedAndRemoveUntil(
            EntryScreen.routeName, (Route<dynamic> route) => false);
      }
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  Future closeAllStreams() async {
    await Provider.of<NotificationProviderV2>(context, listen: false).flush();
    await Provider.of<PrayerProviderV2>(context, listen: false).flush();
    await Provider.of<UserProviderV2>(context, listen: false).flush();
    await Provider.of<GroupProviderV2>(context, listen: false).flush();
  }

//check on login
  route() async {
    try {
      final isLoggedIn = await _authenticationProvider.isUserLoggedIn();
      if (Settings.enableLocalAuth) {
        await closeAllStreams();
        Navigator.of(context).pushNamedAndRemoveUntil(
            LoginScreen.routeName, (Route<dynamic> route) => false,
            arguments: true);
      } else {
        if (Settings.rememberMe) {
          if (isLoggedIn) {
            await Provider.of<UserProviderV2>(context, listen: false)
                .getUserDataById(FirebaseAuth.instance.currentUser?.uid ?? '');
            await Provider.of<PrayerProviderV2>(context, listen: false)
                .updatePrayerAutoDelete(true);
            await Provider.of<UserProviderV2>(context, listen: false)
                .setCurrentUser();
            await setRouteDestination();
          } else {
            await closeAllStreams();
            Navigator.of(context).pushNamedAndRemoveUntil(
                LoginScreen.routeName, (Route<dynamic> route) => false,
                arguments: true);
          }
        } else {
          await closeAllStreams();
          await Provider.of<AuthenticationProviderV2>(context, listen: false)
              .signOut();
          Navigator.of(context).pushNamedAndRemoveUntil(
              LoginScreen.routeName, (Route<dynamic> route) => false,
              arguments: true);
        }
      }
    } on HttpException catch (e) {
      if (e.message == "Document does not exist.") {
        await migrateData();
        return;
      }
    } catch (e) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName, (Route<dynamic> route) => false,
          arguments: true);
    }
  }

  final _migrationService = locator<MigrationService>();
  Future<void> migrateData() async {
    try {
      BeStilDialog.showLoading(
          context, 'Please wait, your data is being migrated!');
      await _migrationService
          .migrateUserData(FirebaseAuth.instance.currentUser?.uid ?? '');
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .updatePrayerAutoDelete(true);
      await Provider.of<UserProviderV2>(context, listen: false)
          .setCurrentUser();

      setRouteDestination();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: initScreen(context),
    );
  }

  initScreen(BuildContext context) {
    double targetValue = MediaQuery.of(context).size.height * 0.3;
    return Container(
      height: Get.height,
      decoration: BoxDecoration(
        gradient: Settings.isDarkMode
            ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                    Color(0xFF043569),
                    Color(0xFF011730),
                    Color(0xFF043467),
                    Color(0xFF01162E),
                  ])
            : RadialGradient(colors: [Color(0XFFFFFFFF), Color(0XFFC1C5C8)]),
      ),
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: targetValue),
                  onEnd: () {
                    setState(() => targetValue = targetValue);
                  },
                  duration: Duration(seconds: 2),
                  builder: (BuildContext context, double size, Widget? child) {
                    return Container(
                      height: size,
                      child: Image.asset(
                        StringUtils.logo,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _textAnimationController,
            builder: (context, widget) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.copyright,
                        size: 12,
                        color: AppColors.splashTextColor,
                      ),
                      Text(
                        StringUtils.copyRight1,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.medium10.copyWith(
                          color: AppColors.splashTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AppIcons.bestill_copyright,
                        size: 16,
                        color: AppColors.splashLogo,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        StringUtils.copyRight2,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.medium10.copyWith(
                            color: AppColors.splashTextColor, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 40.0),
        ],
      ),
    );
  }
}
