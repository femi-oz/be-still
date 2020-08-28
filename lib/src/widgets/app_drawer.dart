import 'package:be_still/src/screens/AddPrayer/add_prayer_screen.dart';
import 'package:be_still/src/screens/GrowMyPrayerLife/grow_my_prayer_life_screen.dart';
import 'package:be_still/src/screens/PrayMode/pray_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:be_still/src/screens/Settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Theme/app_theme.dart';
import '../Providers/app_provider.dart';

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
    final _app = Provider.of<AppProvider>(context);
    return SafeArea(
      child: Container(
        width: double.infinity,
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
                image: AssetImage(_app.isDarkModeEnabled
                    ? 'assets/images/drawer-bck-dark.png'
                    : 'assets/images/drawer-bck-light.png'),
                alignment: Alignment.bottomCenter,
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
                          _app.logout();
                          Navigator.of(context).pushReplacementNamed('/');
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
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Center(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.2,
                        horizontal: 60,
                      ),
                      children: <Widget>[
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pushReplacementNamed('/');
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
                            Navigator.of(context)
                                .pushReplacementNamed(SettingsScreen.routeName);
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
