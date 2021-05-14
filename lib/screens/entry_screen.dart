import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/prayer_list.dart';
import 'package:be_still/screens/Settings/settings_screen.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/screens/prayer_time/prayer_time_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class EntryScreen extends StatefulWidget {
  static const routeName = '/entry';
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

bool _isSearchMode = false;
TutorialCoachMark tutorialCoachMark;

class _EntryScreenState extends State<EntryScreen>
    with TickerProviderStateMixin {
  BuildContext bcontext;
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController controller;
  Animation<double> animation;
  void _switchSearchMode(bool value) => _isSearchMode = value;
  TabController _tabController;
  bool _isInit = true;

  final cron = Cron();

  initState() {
    _tabController = new TabController(length: 5, vsync: this);
    final miscProvider = Provider.of<MiscProvider>(context, listen: false);
    _switchSearchMode(miscProvider.search);
    _currentIndex = miscProvider.currentPage;
    _preLoadData();
    super.initState();
  }

  _setCurrentIndex(index) {
    _tabController.animateTo(index);
    setState(() => _currentIndex = index);
    Provider.of<MiscProvider>(context, listen: false).setCurrentPage(index);
  }

  Future<void> _preLoadData() async {
    if (Settings.setenableLocalAuth)
      Settings.enableLocalAuth = true;
    else
      Settings.enableLocalAuth = false;

    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser?.id;
    if (userId != null) {
      cron.schedule(Schedule.parse('*/10 * * * *'), () async {
        Provider.of<PrayerProvider>(context, listen: false)
            .checkPrayerValidity(userId);
      });
    }
    await Provider.of<PrayerProvider>(context, listen: false)
        .setPrayerTimePrayers(userId);
    //load settings
    await Provider.of<SettingsProvider>(context, listen: false)
        .setPrayerSettings(userId);
    await Provider.of<SettingsProvider>(context, listen: false)
        .setSettings(userId);
    Provider.of<SettingsProvider>(context, listen: false)
        .setSharingSettings(userId);
    await Provider.of<NotificationProvider>(context, listen: false)
        .setPrayerTimeNotifications(userId);

    //set all users
    Provider.of<UserProvider>(context, listen: false).setAllUsers(userId);

    // get all push notifications
    await Provider.of<NotificationProvider>(context, listen: false)
        .setUserNotifications(userId);

    // get all local notifications
    await Provider.of<NotificationProvider>(context, listen: false)
        .setLocalNotifications(userId);
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final miscProvider = Provider.of<MiscProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: _currentIndex != 0
          ? null
          : CustomAppBar(
              showPrayerActions: _currentIndex == 0,
              isSearchMode: _isSearchMode,
              switchSearchMode: (bool val) => _switchSearchMode(val),
            ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
        ),
        child: new TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            getItems(miscProvider).map((e) => e.page).toList()[0],
            getItems(miscProvider).map((e) => e.page).toList()[1],
            getItems(miscProvider).map((e) => e.page).toList()[2],
            getItems(miscProvider).map((e) => e.page).toList()[3],
            getItems(miscProvider).map((e) => e.page).toList()[4],
          ],
        ),
      ),
      bottomNavigationBar:
          _currentIndex == 3 ? null : _createBottomNavigationBar(_currentIndex),
      endDrawer: CustomDrawer(_tabController, _setCurrentIndex),
      endDrawerEnableOpenDragGesture: false,
    );
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

  Widget _createBottomNavigationBar(int _currentIndex) {
    var message = '';

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
          onTap: (index) async {
            switch (index) {
              case 2:
                final prayers =
                    Provider.of<PrayerProvider>(context, listen: false)
                        .filteredPrayerTimeList;
                if (prayers.length == 0) {
                  message =
                      'You must have at least one active prayer to start prayer time.';
                  showInfoModal(message);
                } else {
                  _switchSearchMode(false);
                  _setCurrentIndex(index);
                }
                break;
              case 3:
                message = 'This feature will be available soon.';
                showInfoModal(message);
                break;
              case 4:
                Scaffold.of(context).openEndDrawer();
                break;
              default:
                _switchSearchMode(false);
                _setCurrentIndex(index);
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
            for (final tabItem
                in getItems(Provider.of<MiscProvider>(context, listen: false)))
              BottomNavigationBarItem(icon: tabItem.icon, label: tabItem.title)
          ],
        ),
      );
    });
  }

  List<TabNavigationItem> getItems(miscProvider) => [
        TabNavigationItem(
          page: PrayerList(_setCurrentIndex),
          icon: Icon(
            AppIcons.list,
            size: 16,
            key: Settings.isAppInit ? miscProvider.keyButton : null,
            color: AppColors.bottomNavIconColor,
          ),
          title: "List",
        ),
        TabNavigationItem(
          page: AddPrayer(
            setCurrentIndex: _setCurrentIndex,
            isEdit: false,
            isGroup: false,
            showCancel: false,
          ),
          icon: Icon(
            AppIcons.bestill_add,
            key: Settings.isAppInit ? miscProvider.keyButton2 : null,
            size: 16,
            color: AppColors.bottomNavIconColor,
          ),
          title: "Add",
        ),
        TabNavigationItem(
          page: PrayerTime(_setCurrentIndex),
          icon: Icon(
            AppIcons.bestill_menu_logo_lt,
            key: Settings.isAppInit ? miscProvider.keyButton3 : null,
            size: 16,
            color: AppColors.bottomNavIconColor,
          ),
          title: "Pray",
        ),
        TabNavigationItem(
          page: GroupScreen(),
          icon: Icon(
            AppIcons.groups,
            size: 16,
            color: AppColors.bottomNavIconColor,
          ),
          title: "Groups",
        ),
        TabNavigationItem(
          page: SettingsScreen(),
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

class TabNavigationItem {
  final Widget page;
  final String title;
  final Icon icon;

  TabNavigationItem({
    @required this.page,
    @required this.title,
    @required this.icon,
  });
}
