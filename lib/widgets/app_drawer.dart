import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:be_still/screens/security/login/login_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:be_still/screens/Settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  _launchURL() async {
    const url = 'https://my.bible.com/bible';
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
                    onTap: () {
                      _authProvider.signOut();
                      Navigator.of(context)
                          .pushReplacementNamed(LoginScreen.routeName);
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

    showDialog(context: context, child: dialog);
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
                  color: AppColors.drawerTopColor,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Text(
                          'LOGOUT',
                          style: AppTextStyles.boldText20
                              .copyWith(color: AppColors.topNavTextColor),
                        ),
                        onTap: () {
                          // _authProvider.signOut();
                          // Navigator.of(context)
                          //     .pushReplacementNamed(LoginScreen.routeName);
                          _openLogoutConfirmation(context);
                        },
                      ),
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
                Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  padding: EdgeInsets.symmetric(
                    horizontal: 60,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.22,
                      ),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(EntryScreen.routeName);
                            },
                            title: Text("MY LIST",
                                style: AppTextStyles.drawerMenu.copyWith(
                                    color: AppColors.drawerMenuColor)),
                          ),
                          ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EntryScreen(screenNumber: 2),
                              ),
                            ),
                            title: Text("ADD A PRAYER",
                                style: AppTextStyles.drawerMenu.copyWith(
                                    color: AppColors.drawerMenuColor)),
                          ),
                          ListTile(
                            onTap: () => Navigator.of(context)
                                .pushReplacementNamed(PrayerMode.routeName),
                            title: Text("PRAY",
                                style: AppTextStyles.drawerMenu.copyWith(
                                    color: AppColors.drawerMenuColor)),
                          ),
                          ListTile(
                            onTap: _launchURL,
                            title: Text("BIBLE",
                                style: AppTextStyles.drawerMenu.copyWith(
                                    color: AppColors.drawerMenuColor)),
                          ),
                          ListTile(
                            onTap: () {
                              // Navigator.of(context).pushReplacementNamed(
                              //     GrowMyPrayerLifeScreen.routeName);
                            },
                            title: Text("GROW MY PRAYER LIFE",
                                style: AppTextStyles.drawerMenu.copyWith(
                                    color: AppColors.drawerMenuColor)),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed(
                                  SettingsScreen.routeName);
                            },
                            title: Text("SETTINGS",
                                style: AppTextStyles.drawerMenu.copyWith(
                                    color: AppColors.drawerMenuColor)),
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
