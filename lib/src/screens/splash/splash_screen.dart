import 'dart:async';

import 'package:be_still/src/Providers/app_provider.dart';
import 'package:be_still/src/screens/Prayer/prayer_screen.dart';
import 'package:be_still/src/screens/security/Login/login_screen.dart';
import 'package:be_still/src/widgets/app_icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/Theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var _isInit = true;

  @override
  void initState() {
    super.initState();
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
    var duration = new Duration(seconds: 3);
    return new Timer(duration, () => route());
  }

  route() async {
    final _app = Provider.of<AppProvider>(context, listen: false);
    if (_app.isAuthenticated) {
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
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.asset(
                    'assets/images/splash_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
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
            SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}
