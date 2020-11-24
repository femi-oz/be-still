import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Settings/Widgets/my_list.dart';
import 'package:be_still/screens/settings/widgets/settings_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/app_drawer.dart';
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
import 'package:async/async.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings';
  @override
  _SettingsScreenPage createState() => _SettingsScreenPage();
}

class _SettingsScreenPage extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  // String title = "Home";

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
    super.initState();
    tabController = new TabController(length: 5, vsync: this);
  }

  void _getSettings() async {
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<SettingsProvider>(context, listen: false)
          .setPrayerSettings(_user.id);
      await Provider.of<SettingsProvider>(context, listen: false)
          .setSettings(_user.id);
      await Provider.of<SettingsProvider>(context, listen: false)
          .setSharingSettings(_user.id);
    } on HttpException catch (e) {
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  bool _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getSettings();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final _settingsProvider = Provider.of<SettingsProvider>(context);
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.getDropShadow(_themeProvider.isDarkModeEnabled),
                  offset: Offset(0.0, 0.5),
                  blurRadius: 5.0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors:
                    AppColors.getPrayerMenu(_themeProvider.isDarkModeEnabled),
              ),
            ),
            height: 50.0,
            child: new TabBar(
              indicatorColor: Colors.transparent,
              unselectedLabelColor: AppColors.getInactvePrayerMenu(
                  _themeProvider.isDarkModeEnabled),
              labelColor: AppColors.lightBlue4,
              labelStyle: AppTextStyles.boldText20,
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
              colors:
                  AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
            ),
          ),
          child: TabBarView(
            children: [
              GeneralSettings(_settingsProvider.settings),
              MyListSettings(_settingsProvider.settings),
              PrayerTimeSettings(_settingsProvider.prayerSetttings,
                  _settingsProvider.settings),
              NotificationsSettings(_settingsProvider.settings),
              AlexaSettings(_settingsProvider.settings),
              SharingSettings(_settingsProvider.sharingSetttings),
              GroupsSettings(),
            ],
          ),
        ),
      ),
    );
  }
}
