import 'dart:async';

import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
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
  AnimationController _textAnimationController;
  AuthenticationProvider _authenticationProvider = AuthenticationProvider();

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
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

  route() async {
    try {
      final isLoggedIn = await _authenticationProvider.isUserLoggedIn();
      if (Settings.enableLocalAuth) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (Route<dynamic> route) => false,
        );
      } else {
        if (Settings.rememberMe) {
          if (isLoggedIn) {
            await Provider.of<UserProvider>(context, listen: false)
                .setCurrentUser(false);
            UserModel _user =
                Provider.of<UserProvider>(context, listen: false).currentUser;

            await Provider.of<NotificationProvider>(context, listen: false)
                .setUserNotifications(_user?.id);

            Navigator.of(context).pushNamedAndRemoveUntil(
                EntryScreen.routeName, (Route<dynamic> route) => false);
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              LoginScreen.routeName,
              (Route<dynamic> route) => false,
            );
          }
        } else {
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .signOut();
          Navigator.of(context).pushNamedAndRemoveUntil(
            LoginScreen.routeName,
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (Route<dynamic> route) => false,
      );
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
    return Scaffold(
      body: Container(
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
                    builder: (BuildContext context, double size, Widget child) {
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
                            color: AppColors.splashTextColor,
                          ),
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
      ),
    );
  }
}
