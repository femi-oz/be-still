import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/theme_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/Settings/Widgets/general.dart';
import 'package:be_still/screens/Settings/Widgets/groups.dart';
import 'package:be_still/screens/Settings/Widgets/my_list.dart';
import 'package:be_still/screens/Settings/Widgets/prayer_time.dart';
import 'package:be_still/screens/settings/Widgets/sharing.dart';
import 'package:be_still/screens/settings/widgets/settings_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings';
  final Function setDefaultSnooze;
  SettingsScreen(this.setDefaultSnooze);
  @override
  _SettingsScreenPage createState() => _SettingsScreenPage();
}

class _SettingsScreenPage extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 5, vsync: this);
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        var userId = FirebaseAuth.instance.currentUser?.uid;
        await Provider.of<MiscProviderV2>(context, listen: false)
            .setSearchMode(false);
        await Provider.of<MiscProviderV2>(context, listen: false)
            .setSearchQuery('');
        await Provider.of<PrayerProviderV2>(context, listen: false)
            .searchPrayers('', userId ?? '');
      } catch (e, s) {
        final user =
            Provider.of<UserProviderV2>(context, listen: false).currentUser;
        BeStilDialog.showErrorDialog(
            context, StringUtils.getErrorMessage(e), user, s);
      }
    });
    super.didChangeDependencies();
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
      body: SettingsTab(widget.setDefaultSnooze),
    );
  }
}

class SettingsTab extends StatefulWidget {
  final Function setDefaultSnooze;
  SettingsTab(this.setDefaultSnooze);

  @override
  SettingsTabState createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
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
    // return (Navigator.of(context).pushNamedAndRemoveUntil(
    //         EntryScreen.routeName, (Route<dynamic> route) => false)) ??
    //     false;
    return false;
  }

  AppController appController = Get.find();

  @override
  Widget build(BuildContext context) {
    final _userProvider = Provider.of<UserProviderV2>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        initialIndex: appController.settingsTab,
        length: 5,
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
                color: !Provider.of<ThemeProviderV2>(context).isDarkModeEnabled
                    ? Color(0xFFFFFFFF)
                    : Color(0xFF005780),
              ),
              height: 50.0,
              child: new TabBar(
                indicatorColor: Colors.transparent,
                unselectedLabelColor:
                    !Provider.of<ThemeProviderV2>(context).isDarkModeEnabled
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
                    text: "My Prayers",
                  ),
                  Tab(
                    text: "Set Reminder",
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
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                GeneralSettings(_scaffoldKey),
                MyListSettings(
                    _userProvider.currentUser, widget.setDefaultSnooze),
                PrayerTimeSettings(),
                SharingSettings(),
                GroupsSettings(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
