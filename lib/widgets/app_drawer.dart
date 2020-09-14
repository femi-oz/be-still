import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/grow_my_prayer_life/grow_my_prayer_life_screen.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/screens/security/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:be_still/screens/Settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

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
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final _authProvider = Provider.of<AuthProvider>(context);
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
                  colors: [
                    context.mainBgStart,
                    context.mainBgEnd,
                  ]),
              image: DecorationImage(
                image: AssetImage(_themeProvider.isDarkModeEnabled
                    ? 'assets/images/drawer-bck-dark.png'
                    : 'assets/images/drawer-bck-light.png'),
                alignment: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  color: Theme.of(context).appBarTheme.color,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Text(
                          'LOGOUT',
                          style: TextStyle(
                            color: context.appBarActive,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          _authProvider.logout();
                          Navigator.of(context)
                              .pushReplacementNamed(LoginScreen.routeName);
                        },
                      ),
                      InkWell(
                        child: Icon(
                          Icons.close,
                          color: context.appBarActive,
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
                                  .pushReplacementNamed(PrayerScreen.routeName);
                            },
                            title: Text(
                              "MY LIST",
                              style: TextStyle(
                                color: context.brightBlue2,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () => Navigator.of(context).pushNamed(
                              AddPrayer.routeName,
                              arguments: AddRouteArguments(false, null),
                            ),
                            title: Text(
                              "ADD A PRAYER",
                              style: TextStyle(
                                color: context.brightBlue2,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () => Navigator.of(context)
                                .pushReplacementNamed(PrayerMode.routeName),
                            title: Text(
                              "PRAY",
                              style: TextStyle(
                                color: context.brightBlue2,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: _launchURL,
                            title: Text(
                              "BIBLE",
                              style: TextStyle(
                                color: context.brightBlue2,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed(
                                  GrowMyPrayerLifeScreen.routeName);
                            },
                            title: Text(
                              "GROW MY PRAYER LIFE",
                              style: TextStyle(
                                color: context.brightBlue2,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed(
                                  SettingsScreen.routeName);
                            },
                            title: Text(
                              "SETTINGS",
                              style: TextStyle(
                                color: context.brightBlue2,
                                fontSize: 16,
                              ),
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
