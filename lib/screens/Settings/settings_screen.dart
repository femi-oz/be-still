import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/Prayer/prayer_list.dart';
import 'package:be_still/screens/Settings/Widgets/my_list.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/screens/prayer_time/prayer_time_screen.dart';
import 'package:be_still/screens/settings/Widgets/general.dart';
import 'package:be_still/screens/settings/Widgets/prayer_time.dart';
import 'package:be_still/screens/settings/Widgets/sharing.dart';
import 'package:be_still/screens/settings/widgets/settings_bar.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings';
  @override
  _SettingsScreenPage createState() => _SettingsScreenPage();
}

class _SettingsScreenPage extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  TabController tabController;

  @override
  void initState() {
    _currentIndex =
        Provider.of<MiscProvider>(context, listen: false).currentPage;
    super.initState();
    tabController = new TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void showInfoModal(message) {
    final dialogContent = AlertDialog(
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
        height: MediaQuery.of(context).size.height * 0.25,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue4,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * .60,
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
                            'OK',
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
                ],
              ),
            )
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => dialogContent);
  }

  Widget _createBottomNavigationBar() {
    var message = '';
    var prayers = Provider.of<PrayerProvider>(context).filteredPrayerTimeList;

    return Builder(builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.appBarBackground,
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            stops: [0.0, 0.8],
            tileMode: TileMode.clamp,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                NavigationService.instance.goHome(0);
                break;
              case 1:
                NavigationService.instance.goHome(1);
                break;
              case 4:
                Scaffold.of(context).openEndDrawer();
                break;
              case 3:
                message = 'This feature will be available soon.';
                showInfoModal(message);
                break;
              case 2:
                if (prayers.length == 0) {
                  message =
                      'You must have at least one active prayer to start prayer time.';
                  showInfoModal(message);
                } else {
                  NavigationService.instance.goHome(2);
                }

                break;
              default:
                NavigationService.instance.goHome(0);
                break;
            }
          },
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: AppTextStyles.boldText14
              .copyWith(color: AppColors.bottomNavIconColor, height: 1.3),
          unselectedLabelStyle: AppTextStyles.boldText14.copyWith(
              color: AppColors.bottomNavIconColor.withOpacity(0.5),
              height: 1.4),
          unselectedItemColor: AppColors.bottomNavIconColor.withOpacity(0.5),
          selectedItemColor: AppColors.bottomNavIconColor,
          selectedIconTheme: IconThemeData(color: AppColors.bottomNavIconColor),
          items: [
            for (final tabItem in TabNavigationItem.items)
              BottomNavigationBarItem(icon: tabItem.icon, label: tabItem.title)
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: SettingsAppBar(),
      endDrawer: CustomDrawer(),
      body: SettingsTab(),
      bottomNavigationBar:
          _currentIndex == 3 ? null : _createBottomNavigationBar(),
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
    return (NavigationService.instance.goHome(0)) ?? false;
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
                labelStyle: AppTextStyles.boldText24,
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

class TabNavigationItem {
  final Widget page;
  final String title;
  final Icon icon;

  TabNavigationItem({
    @required this.page,
    @required this.title,
    @required this.icon,
  });

  static List<TabNavigationItem> get items => [
        TabNavigationItem(
          page: PrayerList(),
          icon: Icon(
            AppIcons.list,
            size: 18,
            key: Settings.isAppInit ? miscProvider.keyButton : null,
            color: AppColors.bottomNavIconColor,
          ),
          title: "List",
        ),
        TabNavigationItem(
          page: AddPrayer(
            isEdit: false,
            isGroup: false,
            showCancel: false,
          ),
          icon: Icon(AppIcons.bestill_add,
              key: Settings.isAppInit ? miscProvider.keyButton2 : null,
              size: 16,
              color: AppColors.bottomNavIconColor),
          title: "Add",
        ),
        TabNavigationItem(
          page: PrayerTime(),
          icon: Icon(AppIcons.bestill_menu_logo_lt,
              key: Settings.isAppInit ? miscProvider.keyButton3 : null,
              size: 16,
              color: AppColors.bottomNavIconColor),
          title: "Pray",
        ),
        TabNavigationItem(
          page: GroupScreen(),
          icon: Icon(AppIcons.groups,
              size: 16, color: AppColors.bottomNavIconColor),
          title: "Groups",
        ),
        TabNavigationItem(
          page: null,
          icon: Icon(
            Icons.more_horiz,
            key: Settings.isAppInit ? miscProvider.keyButton4 : null,
            size: 20,
            color: AppColors.bottomNavIconColor,
          ),
          title: "More",
        ),
      ];
}
