import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/settings_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Settings/Widgets/my_list.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/settings/Widgets/alexa.dart';
import 'package:be_still/screens/settings/Widgets/general.dart';
import 'package:be_still/screens/settings/Widgets/groups.dart';
import 'package:be_still/screens/settings/Widgets/notifications.dart';
import 'package:be_still/screens/settings/Widgets/prayer_time.dart';
import 'package:be_still/screens/settings/Widgets/sharing.dart';
import 'package:be_still/screens/settings/widgets/settings_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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

  bool _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EntryScreen(screenNumber: 0),
            ))) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final _settingsProvider = Provider.of<SettingsProvider>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 7,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dropShadow,
                    offset: Offset(0.0, 0.5),
                    blurRadius: 5.0,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: AppColors.prayerMenu,
                ),
              ),
              height: 50.0,
              child: new TabBar(
                indicatorColor: Colors.transparent,
                unselectedLabelColor: AppColors.inactvePrayerMenu,
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
                colors: AppColors.backgroundColor,
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
      ),
    );
  }
}
