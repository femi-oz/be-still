import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/grow_my_prayer_life/grow_my_prayer_life_screen.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/screens/security/login/login_screen.dart';
import 'package:be_still/utils/essentials.dart';
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

  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthenticationProvider>(context);
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
                image: AssetImage(StringUtils.getBackgroundImage()),
                alignment: Alignment.bottomCenter,
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
                              .copyWith(color: AppColors.bottomNavIconColor),
                        ),
                        onTap: () {
                          _authProvider.signOut();
                          Navigator.of(context)
                              .pushReplacementNamed(LoginScreen.routeName);
                        },
                      ),
                      InkWell(
                        child: Icon(
                          Icons.close,
                          color: AppColors.bottomNavIconColor,
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
                                style: AppTextStyles.drawerMenu),
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
                                style: AppTextStyles.drawerMenu),
                          ),
                          ListTile(
                            onTap: () => Navigator.of(context)
                                .pushReplacementNamed(PrayerMode.routeName),
                            title:
                                Text("PRAY", style: AppTextStyles.drawerMenu),
                          ),
                          ListTile(
                            onTap: _launchURL,
                            title:
                                Text("BIBLE", style: AppTextStyles.drawerMenu),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed(
                                  GrowMyPrayerLifeScreen.routeName);
                            },
                            title: Text("GROW MY PRAYER LIFE",
                                style: AppTextStyles.drawerMenu),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed(
                                  SettingsScreen.routeName);
                            },
                            title: Text("SETTINGS",
                                style: AppTextStyles.drawerMenu),
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
