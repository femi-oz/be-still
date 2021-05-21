import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/prayer_list.dart';
import 'package:be_still/screens/Settings/settings_screen.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/screens/grow_my_prayer_life/devotion_and_reading_plans.dart';
import 'package:be_still/screens/grow_my_prayer_life/recommended_bibles_screen.dart';
import 'package:be_still/screens/prayer_time/prayer_time_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class EntryScreen extends StatefulWidget {
  static const routeName = '/entry';
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

TutorialCoachMark tutorialCoachMark;

class _EntryScreenState extends State<EntryScreen>
    with TickerProviderStateMixin {
  ValueNotifier<double> _notifier;

  BuildContext bcontext;
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;

  final cron = Cron();

  initState() {
    _getPermissions();
    _tabController = new TabController(length: 7, vsync: this);
    final miscProvider = Provider.of<MiscProvider>(context, listen: false);
    _currentIndex = miscProvider.currentPage;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (miscProvider.initialLoad) {
        await _preLoadData();
        miscProvider.setLoadStatus(false);
      }
    });
    _notifier = ValueNotifier<double>(0);

    super.initState();
  }

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  Future<void> _setCurrentIndex(int index, bool animate) async {
    if (animate)
      _tabController.animateTo(index);
    else
      _tabController.index = index;
    setState(() => _currentIndex = index);
    await Provider.of<MiscProvider>(context, listen: false)
        .setCurrentPage(index);
  }

  void _getPermissions() async {
    try {
      if (Settings.isAppInit) {
        await Permission.contacts.request().then((p) =>
            Settings.enabledContactPermission = p == PermissionStatus.granted);
      }
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Future<void> _preLoadData() async {
    try {
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
      await _getPrayers();
      await _getActivePrayers();
      await _getDevotionals();
      await _getBibles();
      //load settings
      await Provider.of<SettingsProvider>(context, listen: false)
          .setPrayerSettings(userId);
      await Provider.of<SettingsProvider>(context, listen: false)
          .setSettings(userId);
      await Provider.of<SettingsProvider>(context, listen: false)
          .setSharingSettings(userId);
      await Provider.of<NotificationProvider>(context, listen: false)
          .setPrayerTimeNotifications(userId);

      //set all users
      Provider.of<UserProvider>(context, listen: false).setAllUsers(userId);

      // get all push notifications
      Provider.of<NotificationProvider>(context, listen: false)
          .setUserNotifications(userId);

      // get all local notifications
      Provider.of<NotificationProvider>(context, listen: false)
          .setLocalNotifications(userId);
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Future<void> _getActivePrayers() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayerTimePrayers(_user.id);
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Future<void> _getPrayers() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      final searchQuery =
          Provider.of<MiscProvider>(context, listen: false).searchQuery;
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayerTimePrayers(_user.id);
      if (searchQuery.isNotEmpty) {
        Provider.of<PrayerProvider>(context, listen: false)
            .searchPrayers(searchQuery, _user.id);
      } else {
        await Provider.of<PrayerProvider>(context, listen: false)
            .setPrayers(_user?.id);
      }
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Future<void> _getDevotionals() async {
    try {
      await Provider.of<DevotionalProvider>(context, listen: false)
          .getDevotionals();
      await Future.delayed(Duration(milliseconds: 300));
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Future<void> _getBibles() async {
    try {
      await Provider.of<DevotionalProvider>(context, listen: false).getBibles();
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  GlobalKey _keyButton = GlobalKey();
  GlobalKey _keyButton2 = GlobalKey();
  GlobalKey _keyButton3 = GlobalKey();
  GlobalKey _keyButton4 = GlobalKey();
  GlobalKey _keyButton5 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final miscProvider = Provider.of<MiscProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
        ),
        child: miscProvider.initialLoad
            ? BeStilDialog.getLoading(context)
            : new TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  getItems(miscProvider).map((e) => e.page).toList()[0],
                  getItems(miscProvider).map((e) => e.page).toList()[1],
                  getItems(miscProvider).map((e) => e.page).toList()[2],
                  getItems(miscProvider).map((e) => e.page).toList()[3],
                  getItems(miscProvider).map((e) => e.page).toList()[4],
                  getItems(miscProvider).map((e) => e.page).toList()[5],
                  getItems(miscProvider).map((e) => e.page).toList()[6],
                ],
              ),
      ),
      bottomNavigationBar:
          _currentIndex == 3 ? null : _createBottomNavigationBar(_currentIndex),
      endDrawer: CustomDrawer(
        _setCurrentIndex,
        _keyButton,
        _keyButton2,
        _keyButton3,
        _keyButton4,
        _keyButton5,
        _scaffoldKey,
      ),
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
          currentIndex: _currentIndex > 4 ? 4 : _currentIndex,
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
                  _setCurrentIndex(index, true);
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
                _setCurrentIndex(index, true);
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
                in getItems(Provider.of<MiscProvider>(context, listen: false))
                    .getRange(0, 5))
              BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: tabItem.padding, top: 5),
                    child: tabItem.icon,
                  ),
                  label: tabItem.title)
          ],
        ),
      );
    });
  }

  List<TabNavigationItem> getItems(miscProvider) => [
        TabNavigationItem(
            page: PrayerList(_setCurrentIndex, _keyButton, _keyButton2,
                _keyButton3, _keyButton4, _keyButton5),
            icon: Icon(
              AppIcons.list,
              size: 16,
              key: _keyButton,
              color: AppColors.bottomNavIconColor,
            ),
            title: "List",
            padding: 5),
        TabNavigationItem(
            page: AddPrayer(
              setCurrentIndex: _setCurrentIndex,
              isEdit: false,
              isGroup: false,
              showCancel: false,
            ),
            icon: Icon(
              AppIcons.bestill_add,
              key: _keyButton2,
              size: 16,
              color: AppColors.bottomNavIconColor,
            ),
            title: "Add",
            padding: 6),
        TabNavigationItem(
            page: PrayerTime(_setCurrentIndex, _notifier),
            icon: Icon(
              AppIcons.bestill_menu_logo_lt,
              key: _keyButton3,
              size: 16,
              color: AppColors.bottomNavIconColor,
            ),
            title: "Pray",
            padding: 5),
        TabNavigationItem(
            page: GroupScreen(),
            icon: Icon(
              AppIcons.groups,
              size: 18,
              color: AppColors.bottomNavIconColor,
            ),
            title: "Groups",
            padding: 2),
        TabNavigationItem(
            page: SettingsScreen(),
            icon: Icon(
              Icons.more_horiz,
              key: _keyButton4,
              size: 22,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 0),
        TabNavigationItem(
            page: DevotionPlans(_setCurrentIndex),
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 5),
        TabNavigationItem(
            page: RecommenededBibles(_setCurrentIndex),
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 5),
      ];
}

class TabNavigationItem {
  final Widget page;
  final String title;
  final Icon icon;
  final double padding;

  TabNavigationItem({
    @required this.page,
    @required this.title,
    @required this.icon,
    @required this.padding,
  });
}
