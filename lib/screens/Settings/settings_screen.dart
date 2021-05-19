import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/Settings/Widgets/my_list.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/settings/Widgets/general.dart';
import 'package:be_still/screens/settings/Widgets/prayer_time.dart';
import 'package:be_still/screens/settings/Widgets/sharing.dart';
import 'package:be_still/screens/settings/widgets/settings_bar.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings';
  @override
  _SettingsScreenPage createState() => _SettingsScreenPage();
}

class _SettingsScreenPage extends State<SettingsScreen>
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
    return new Scaffold(
      appBar: SettingsAppBar(),
      endDrawer: null,
      endDrawerEnableOpenDragGesture: false,
      body: SettingsTab(),
    );
  }
}

class SettingsTab extends StatefulWidget {
  @override
  SettingsTabState createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    return (Navigator.of(context).pushNamedAndRemoveUntil(
            EntryScreen.routeName, (Route<dynamic> route) => false)) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final _settingsProvider = Provider.of<SettingsProvider>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          key: _scaffoldKey,
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
                color: !Provider.of<ThemeProvider>(context).isDarkModeEnabled
                    ? Color(0xFFFFFFFF)
                    : Color(0xFF005780),
              ),
              height: 50.0,
              child: new TabBar(
                indicatorColor: Colors.transparent,
                unselectedLabelColor:
                    !Provider.of<ThemeProvider>(context).isDarkModeEnabled
                        ? Color(0xFF718B92)
                        : Color(0xB3FFFFFF),
                labelColor: AppColors.actveTabMenu,
                labelStyle: AppTextStyles.boldText16b,
                isScrollable: true,
                tabs: [
                  Tab(
                    text: "General",
                  ),
                  Tab(
                    text: "My List",
                  ),
                  Tab(
                    text: "Set Reminder",
                  ),
                  Tab(
                    text: "Sharing",
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                GeneralSettings(_settingsProvider.settings, _scaffoldKey),
                MyListSettings(_settingsProvider.settings),
                PrayerTimeSettings(_settingsProvider.prayerSetttings,
                    _settingsProvider.settings),
                // NotificationsSettings(_settingsProvider.settings),
                // AlexaSettings(_settingsProvider.settings),
                SharingSettings(),
                // GroupsSettings(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
