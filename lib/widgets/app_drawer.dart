import 'dart:io';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/providers/v2/auth_provider.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/security/login/login_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/initial_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';

class CustomDrawer extends StatefulWidget {
  final Function(int) setCurrentIndex;
  final GlobalKey keyButton;
  final GlobalKey keyButton2;
  final GlobalKey keyButton3;
  final GlobalKey keyButton4;
  final GlobalKey keyButton5;
  final GlobalKey keyButton6;
  final GlobalKey keyButton7;
  final scaffoldKey;
  CustomDrawer(
    this.setCurrentIndex,
    this.keyButton,
    this.keyButton2,
    this.keyButton3,
    this.keyButton4,
    this.keyButton5,
    this.keyButton6,
    this.keyButton7,
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

  _launchHelpURL() async {
    try {
      if (await canLaunchUrl(Uri.parse('https://www.bestillapp.com/help'))) {
        await launchUrl(Uri.parse('https://www.bestillapp.com/help'));
      } else {
        throw 'Could not launch https://www.bestillapp.com/help';
      }
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  _launchPrivacyURL() async {
    try {
      if (await canLaunchUrl(
          Uri.parse('https://bestillapp.com/privacy-policy/'))) {
        await launchUrl(Uri.parse('https://bestillapp.com/privacy-policy/'));
      } else {
        throw 'Could not launch https://bestillapp.com/privacy-policy/';
      }
    } catch (e, s) {
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), null, s);
    }
  }

  _launchTermsURL() async {
    try {
      if (await canLaunchUrl(
          Uri.parse('https://bestillapp.com/terms-of-use/'))) {
        await launchUrl(Uri.parse('https://bestillapp.com/terms-of-use/'));
      } else {
        throw 'Could not launch https://bestillapp.com/terms-of-use/';
      }
    } catch (e, s) {
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), null, s);
    }
  }

  _launchURL(url) async {
    try {
      if (Platform.isAndroid) {
        await AppAvailability.checkAvailability(
            "com.sirma.mobile.bible.android");
        _shareUri = 'com.sirma.mobile.bible.android';
      } else if (Platform.isIOS) {
        await AppAvailability.checkAvailability("youversion://");
        _shareUri = 'youversion://';
      }
      AppAvailability.launchApp(_shareUri);
    } catch (_, __) {
      try {
        if (await canLaunchUrl(Uri.parse('https://my.bible.com/bible'))) {
          await launchUrl(Uri.parse('https://my.bible.com/bible'));
        } else {
          throw 'Could not launch https://my.bible.com/bible';
        }
      } catch (e, s) {
        final user =
            Provider.of<UserProviderV2>(context, listen: false).currentUser;
        BeStilDialog.showErrorDialog(
            context, StringUtils.getErrorMessage(e), user, s);
      }
    }
  }

  Future closeAllStreams() async {
    await Provider.of<NotificationProviderV2>(context, listen: false).flush();
    await Provider.of<PrayerProviderV2>(context, listen: false).flush();
    await Provider.of<UserProviderV2>(context, listen: false).flush();
    await Provider.of<GroupProviderV2>(context, listen: false).flush();
  }

  _openLogoutConfirmation(BuildContext context) {
    final _authProvider =
        Provider.of<AuthenticationProviderV2>(context, listen: false);
    final user =
        Provider.of<UserProviderV2>(context, listen: false).currentUser;

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
                      child: Center(
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            height: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Provider.of<NotificationProviderV2>(context,
                              listen: false)
                          .cancelLocalNotifications();
                      await Provider.of<UserProviderV2>(context, listen: false)
                          .removePushToken(user.devices ?? []);
                      await closeAllStreams();
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
                      child: Center(
                        child: Text(
                          'LOGOUT',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            height: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                          // appController appController = Get.find();
                          // appController.setCurrentPage(0, false);
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 0),
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
                              AppController appController = Get.find();

                              appController.setCurrentPage(6, false, 0);
                              await Future.delayed(Duration(milliseconds: 300));
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
                                AppController appController = Get.find();

                                appController.setCurrentPage(5, false, 0);
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
                              AppController appController = Get.find();

                              appController.setCurrentPage(4, false, 0);
                              appController.settingsTab = 0;
                              await Future.delayed(Duration(milliseconds: 300));
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
                            onTap: () => _launchHelpURL(),
                            child: Text("HELP",
                                style: AppTextStyles.drawerMenu.copyWith(
                                    color: AppColors.drawerMenuColor)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: InkWell(
                            onTap: () {
                              AppController appController = Get.find();

                              appController.setCurrentPage(0, true, 0);
                              Navigator.pop(context);
                              TutorialTarget().showTutorial(
                                context,
                                widget.keyButton,
                                widget.keyButton2,
                                widget.keyButton3,
                                widget.keyButton4,
                                widget.keyButton5,
                                widget.keyButton6,
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
                            onTap: () => _launchPrivacyURL(),
                            child: Container(
                              child: Text("PRIVACY POLICY",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: InkWell(
                            onTap: () => _launchTermsURL(),
                            child: Container(
                              child: Text("TERMS OF USE",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: InkWell(
                            onTap: () => _openLogoutConfirmation(context),
                            child: Container(
                              width: 100,
                              child: Text("LOGOUT",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                        ),
                      ],
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
