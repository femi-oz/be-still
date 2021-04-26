import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/grow_my_prayer_life/devotion_and_reading_plans.dart';
import 'package:be_still/screens/grow_my_prayer_life/recommended_bibles_screen.dart';
import 'package:be_still/screens/security/login/login_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:be_still/screens/Settings/settings_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _openLogoutConfirmation(BuildContext context) {
    final _authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    AlertDialog dialog = AlertDialog(
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
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue4,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            // GestureDetector(
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      await _authProvider.signOut();
                      await LocalNotification.clearAll();
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: LoginScreen(),
                        ),
                      );
                      // Navigator.of(context).pushNamedAndRemoveUntil(
                      //   LoginScreen.routeName,
                      //   (Route<dynamic> route) => false,
                      // );
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
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'LOGOUT',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'CANCEL',
                            style: TextStyle(
                              color: AppColors.red,
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
                  // color: AppColors.drawerTopColor,
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
                              onTap: () => Navigator.of(context)
                                  .pushReplacementNamed(EntryScreen.routeName),
                              child: Text("MY LIST",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () =>
                                  _launchURL('https://my.bible.com/bible'),
                              child: Text("BIBLE APP",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: RecommenededBibles(),
                                ),
                              ),
                              child: Text("RECOMMENDED BIBLES",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: DevotionPlans(),
                                ),
                              ),
                              child: Text("DEVOTIONALS AND READING PLANS",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () => Navigator.of(context)
                                  .pushReplacementNamed(
                                      SettingsScreen.routeName),
                              child: Text("SETTINGS",
                                  style: AppTextStyles.drawerMenu.copyWith(
                                      color: AppColors.drawerMenuColor)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: InkWell(
                              onTap: () =>
                                  _launchURL('https://www.bestillapp.com'),
                              child: Text("HELP",
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
