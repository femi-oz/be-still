import 'dart:async';

import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController _textAnimationController;

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
    final _authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_authProvider.isAuthenticated) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        PrayerScreen.routeName,
        (Route<dynamic> route) => false,
      );
    } else {
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
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              context.splashBgStart,
              context.splashBgEnd,
              context.splashBgStart,
              context.splashBgEnd,
            ],
          ),
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
                          'assets/images/splash_icon.png',
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
                return ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      colors: [Colors.grey, Colors.white, Colors.grey],
                      stops: [
                        _textAnimationController.value - 0.3,
                        _textAnimationController.value,
                        _textAnimationController.value + 0.3
                      ],
                    ).createShader(
                      Rect.fromLTWH(0, 0, rect.width, rect.height),
                    );
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.copyright,
                            size: 12,
                            color: context.brightBlue,
                          ),
                          Text(
                            '2020 All Rights reserved',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: context.brightBlue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.second_logo,
                            size: 16,
                            color: context.brightBlue,
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'BeStill is a ministry of Secnd Baptist Church Houston, TX',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: context.brightBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  blendMode: BlendMode.srcIn,
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
