import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/screens/prayer_time/prayer_time_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:be_still/widgets/initial_tutorial.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'Prayer/prayer_list.dart';

class EntryScreen extends StatefulWidget {
  static const routeName = '/entry';
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

bool _isSearchMode = false;
TutorialCoachMark tutorialCoachMark;
var miscProvider;

class _EntryScreenState extends State<EntryScreen>
    with TickerProviderStateMixin {
  BuildContext bcontext;
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController controller;
  Animation<double> animation;

  void _switchSearchMode(bool value) => setState(() => _isSearchMode = value);
  @override
  void initState() {
    _isInit = false;
    super.initState();
  }

  bool _isInit = true;

  final cron = Cron();

  Future<void> _preLoadData() async {
    if (Settings.setenableLocalAuth) {
      setState(() {
        Settings.enableLocalAuth = true;
      });
    } else {
      setState(() {
        Settings.enableLocalAuth = false;
      });
    }

    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser?.id;
    if (userId != null) {
      cron.schedule(Schedule.parse('*/10 * * * *'), () async {
        Provider.of<PrayerProvider>(context, listen: false)
            .checkPrayerValidity(userId);
      });
    }

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
    Provider.of<NotificationProvider>(context, listen: false)
        .setLocalNotifications(userId);
  }

  @override
  Widget build(BuildContext context) {
    miscProvider = Provider.of<MiscProvider>(context);
    _currentIndex = Provider.of<MiscProvider>(context).currentPage;
    final isSearchMode =
        Provider.of<MiscProvider>(context, listen: false).search;
    _switchSearchMode(isSearchMode);
    return Scaffold(
      key: _scaffoldKey,
      appBar: _currentIndex == 2 || _currentIndex == 3
          ? null
          : CustomAppBar(
              showPrayerActions: _currentIndex == 0,
              isSearchMode: _isSearchMode,
              switchSearchMode: (bool val) => _switchSearchMode(val),
            ),
      body: FutureBuilder(
        future: _preLoadData(),
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _currentIndex == 0 &&
              _isInit) {
            return BeStilDialog.getLoading();
          }
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.backgroundColor,
              ),
            ),
            child: Transform.translate(
              offset: Offset(animation?.value ?? 0, 0),
              child: TabNavigationItem.items[_currentIndex].page,
            ),
          );
        },
      ),
      bottomNavigationBar:
          _currentIndex == 3 ? null : _createBottomNavigationBar(),
      endDrawer: CustomDrawer(),
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
            if (index == 2 && prayers.length == 0) {
              message =
                  'You must have at least one active prayer to start prayer time.';
              showInfoModal(message);
              return;
            }
            switch (index) {
              case 3:
                message = 'This feature will be available soon.';
                showInfoModal(message);
                break;
              case 4:
                Scaffold.of(context).openEndDrawer();
                break;
              default:
                Provider.of<MiscProvider>(context, listen: false)
                    .setCurrentPage(index);
                controller = new AnimationController(
                    duration: Duration(milliseconds: 300), vsync: this)
                  ..addListener(() => setState(() {}));
                animation = _currentIndex > index
                    ? Tween(begin: MediaQuery.of(context).size.width, end: 0.0)
                        .animate(controller)
                    : _currentIndex == index
                        ? Tween(begin: 0.0, end: 0.0).animate(controller)
                        : Tween(
                                begin: -MediaQuery.of(context).size.width,
                                end: 0.0)
                            .animate(controller);
                controller.forward();
                _currentIndex = index;
                _switchSearchMode(false);
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
