import 'package:be_still/src/screens/Settings/Widgets/app_bar.dart';
import 'package:be_still/src/screens/Settings/Widgets/my_list.dart';
import 'package:be_still/src/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';

import 'Widgets/alexa.dart';
import 'Widgets/general.dart';
import 'Widgets/groups.dart';
import 'Widgets/notifications.dart';
import 'Widgets/prayer_time.dart';
import 'Widgets/sharing.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings';
  @override
  _SettingsScreenPage createState() => _SettingsScreenPage();
}

class _SettingsScreenPage extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  String title = "Home";

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: SettingsAppBar(), endDrawer: CustomDrawer(), body: FirstTab());
  }
}

class FirstTab extends StatefulWidget {
  @override
  FirstTabState createState() => FirstTabState();
}

class FirstTabState extends State<FirstTab>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: context.dropShadow,
                  offset: Offset(0.0, 0.5),
                  blurRadius: 5.0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  context.prayerMenuStart,
                  context.prayerMenuEnd,
                ],
              ),
            ),
            height: 50.0,
            child: new TabBar(
              indicatorColor: Colors.transparent,
              unselectedLabelColor: context.prayerMenuInactive,
              labelColor: context.brightBlue,
              isScrollable: true,
              tabs: [
                Tab(
                  text: "General",
                ),
                Tab(
                  text: "My List",
                ),
                Tab(
                  text: "Prayer Time",
                ),
                Tab(
                  text: "Notifications",
                ),
                Tab(
                  text: "Alexa",
                ),
                Tab(
                  text: "Sharing",
                ),
                Tab(
                  text: "Groups",
                ),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.mainBgStart,
                context.mainBgEnd,
              ],
            ),
          ),
          child: TabBarView(
            children: [
              GeneralSettings(),
              MyListSettings(),
              PrayerTimeSettings(),
              NotificationsSettings(),
              AlexaSettings(),
              SharingSettings(),
              GroupsSettings(),
            ],
          ),
        ),
      ),
    );
  }
}
