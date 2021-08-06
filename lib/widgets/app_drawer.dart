import 'dart:io';

import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/security/login/login_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/initial_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';

class CustomDrawer extends StatefulWidget {
  final Function setCurrentIndex;
  final GlobalKey keyButton;
  final GlobalKey keyButton2;
  final GlobalKey keyButton3;
  final GlobalKey keyButton4;
  final GlobalKey keyButton5;
  final scaffoldKey;
  CustomDrawer(
    this.setCurrentIndex,
    this.keyButton,
    this.keyButton2,
    this.keyButton3,
    this.keyButton4,
    this.keyButton5,
    this.scaffoldKey,
  );

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  initState() {
    super.initState();
  }

  String _shareUri = '';

  void _generateBibleAppUri() async {
    final _userProvider = Provider.of<UserProvider>(context, listen: false);
    if (Platform.isIOS) {
      try {
        await AppAvailability.checkAvailability("youversion://");
        _shareUri = 'youversion://';
      } catch (e, s) {
        BeStilDialog.showErrorDialog(context, e, _userProvider.currentUser, s);
      }
    } else if (Platform.isAndroid) {
      try {
        await AppAvailability.checkAvailability("tv.lifechurch.bible");
        _shareUri = 'tv.lifechurch.bible';
      } catch (e, s) {
        BeStilDialog.showErrorDialog(context, e, _userProvider.currentUser, s);
      }
    }
  }

  _launchURL(url) async {
    _generateBibleAppUri();
    final _userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      AppAvailability.launchApp(_shareUri);
    } catch (_, __) {
      try {
        if (await canLaunch('https://my.bible.com/bible')) {
          await launch('https://my.bible.com/bible');
        } else {
          throw 'Could not launch https://my.bible.com/bible';
        }
      } catch (e, s) {
        BeStilDialog.showErrorDialog(context, e, _userProvider.currentUser, s);
      }
    }
  }

  _openLogoutConfirmation(BuildContext context) {
    final _authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor: AppColors.prayerCardBgColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.25,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                'LOGOUT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue1,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            ),
            Flexible(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regularText16b
                      .copyWith(color: AppColors.lightBlue4),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * .20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'CANCEL',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _authProvider.signOut();
                      Navigator.pushReplacement(
                        context,
                        SlideRightRoute(page: LoginScreen()),
                      );
                    },
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * .20,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'LOGOUT',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   var userId =
    //       Provider.of<UserProvider>(context, listen: false).currentUser.id;
    //   await Provider.of<MiscProvider>(context, listen: false)
    //       .setSearchMode(false);
    //   await Provider.of<MiscProvider>(context, listen: false)
    //       .setSearchQuery('');
    //   await Provider.of<PrayerProvider>(context, listen: false)
    //       .searchPrayers('', userId);
    // });
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.backgroundColor,
              ),
              image: DecorationImage(
                image: AssetImage(StringUtils.drawerBackgroundImage()),
                alignment: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        child: Icon(
                          AppIcons.bestill_close,
                          color: AppColors.topNavTextColor,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 60),
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () => _launchURL(_shareUri),
                              child: Text("BIBLE APP",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () async {
                                await widget.setCurrentIndex(6, false);
                                await Future.delayed(
                                    Duration(milliseconds: 300));
                                Navigator.pop(context);
                              },
                              child: Text("RECOMMENDED BIBLES",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                                onTap: () async {
                                  await widget.setCurrentIndex(5, false);
                                  await Future.delayed(
                                      Duration(milliseconds: 300));
                                  Navigator.pop(context);
                                },
                                child: Text("DEVOTIONALS AND READING PLANS",
                                    style: AppTextStyles.drawerMenu.copyWith(
                                        color: AppColors.drawerMenuColor))),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () async {
                                await widget.setCurrentIndex(4, false);
                                await Future.delayed(
                                    Duration(milliseconds: 300));
                                Navigator.pop(context);
                              },
                              child: Text("SETTINGS",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () =>
                                  _launchURL('https://www.bestillapp.com/help'),
                              child: Text("HELP",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () {
                                widget.setCurrentIndex(0, true);
                                Navigator.pop(context);
                                TutorialTarget.showTutorial(
                                  context,
                                  widget.keyButton,
                                  widget.keyButton2,
                                  widget.keyButton3,
                                  widget.keyButton4,
                                  widget.keyButton5,
                                );
                              },
                              child: Text("QUICK TIPS",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () => _openLogoutConfirmation(context),
                              child: Text("LOGOUT",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
