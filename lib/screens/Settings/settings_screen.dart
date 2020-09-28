import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/providers/prayer_settings_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/sharing_settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Settings/Widgets/my_list.dart';
import 'package:be_still/screens/settings/widgets/settings_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:provider/provider.dart';

import 'Widgets/alexa.dart';
import 'Widgets/general.dart';
import 'Widgets/groups.dart';
import 'Widgets/notifications.dart';
import 'Widgets/prayer_time.dart';
import 'Widgets/sharing.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

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
        appBar: SettingsAppBar(),
        endDrawer: CustomDrawer(),
        body: SettingsTab());
  }
}

class SettingsTab extends StatefulWidget {
  @override
  SettingsTabState createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    setupData();
    super.initState();
    tabController = new TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  List<dynamic> dataList = [];
  Future<Stream> getData() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final shareSettingsProvider =
        Provider.of<SharingSettingsProvider>(context, listen: false);

    final prayerSettingsProvider =
        Provider.of<PrayerSettingsProvider>(context, listen: false);
    Stream settings = settingsProvider.getSettings(userProvider.currentUser.id);
    Stream shareSettings =
        shareSettingsProvider.getSharingSettings(userProvider.currentUser.id);
    Stream prayerSettings =
        prayerSettingsProvider.getPrayerSettings(userProvider.currentUser.id);

    return StreamZip([settings, shareSettings, prayerSettings])
        .asBroadcastStream();
  }

  List<SettingsModel> settings = [];
  List<SharingSettingsModel> shareSettings = [];
  List<PrayerSettingsModel> prayerSettings = [];

  setupData() async {
    Stream stream = await getData()
      ..asBroadcastStream();
    stream.listen((data) {
      setState(() {
        settings = data[0];
        shareSettings = data[1];
        prayerSettings = data[2];
      });
    });
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
              GeneralSettings(settings[0]),
              MyListSettings(),
              PrayerTimeSettings(prayerSettings[0]),
              NotificationsSettings(),
              AlexaSettings(),
              SharingSettings(shareSettings[0]),
              GroupsSettings(),
            ],
          ),
        ),
      ),
    );
  }
}
