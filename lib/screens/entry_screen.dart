import 'package:be_still/enums/settings_key.dart';
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
  BuildContext bcontext;
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;

  bool _isSearchMode = false;
  void _switchSearchMode(bool value) => _isSearchMode = value;

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
    super.initState();
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

  void _setDefaultSnooze(selectedDuration, selectedInterval, settingsId) async {
    try {
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSettings(
        Provider.of<UserProvider>(context, listen: false).currentUser.id,
        key: SettingsKey.defaultSnoozeDuration,
        value: selectedDuration,
        settingsId: settingsId,
      );
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSettings(
        Provider.of<UserProvider>(context, listen: false).currentUser.id,
        key: SettingsKey.defaultSnoozeFrequency,
        value: selectedInterval,
        settingsId: settingsId,
      );
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

  void showInfoModal(message, type) {
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
        height: type == 'Group'
            ? MediaQuery.of(context).size.height * 0.4
            : MediaQuery.of(context).size.height * 0.35,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10.0),
            Icon(
              Icons.error,
              color: AppColors.red,
              size: 50,
            ),
            SizedBox(height: 10.0),
            type == 'Group'
                ? Icon(
                    AppIcons.groups,
                    size: 50,
                    color: AppColors.lightBlue4,
                  )
                : Container(),
            const SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.regularText16b
                    .copyWith(color: AppColors.lightBlue4),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: TextButton(
                child: Text('OK',
                    style:
                        AppTextStyles.boldText16.copyWith(color: Colors.white)),
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all<TextStyle>(
                      AppTextStyles.boldText16.copyWith(color: Colors.white)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.all(5.0)),
                  elevation: MaterialStateProperty.all<double>(0.0),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
                  showInfoModal(message, 'PrayerTime');
                } else {
                  _setCurrentIndex(index, true);
                }
                break;
              case 3:
                message = 'This feature will be available soon.';
                showInfoModal(message, 'Group');
                break;
              case 4:
                Scaffold.of(context).openEndDrawer();
                break;
              default:
                _setCurrentIndex(index, true);
                break;
            }
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
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
                icon: Container(
                  key: tabItem.key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      tabItem.icon,
                      SizedBox(height: tabItem.padding),
                      Text(
                        tabItem.title,
                        style: AppTextStyles.boldText14.copyWith(
                          color: AppColors.bottomNavIconColor.withOpacity(0.5),
                          height: 1,
                        ),
                      )
                    ],
                  ),
                ),
                label: '',
              )
          ],
        ),
      );
    });
  }

  List<TabNavigationItem> getItems(miscProvider) => [
        TabNavigationItem(
          page: PrayerList(
            _setCurrentIndex,
            _keyButton,
            _keyButton2,
            _keyButton3,
            _keyButton4,
            _keyButton5,
            _isSearchMode,
            _switchSearchMode,
          ),
          icon: Icon(
            AppIcons.list,
            size: 16,
            color: AppColors.bottomNavIconColor,
          ),
          title: "List",
          padding: 7,
          key: _keyButton,
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
            size: 16,
            color: AppColors.bottomNavIconColor,
          ),
          title: "Add",
          padding: 8,
          key: _keyButton2,
        ),
        TabNavigationItem(
          page: PrayerTime(_setCurrentIndex),
          icon: Icon(
            AppIcons.bestill_menu_logo_lt,
            size: 16,
            color: AppColors.bottomNavIconColor,
          ),
          title: "Pray",
          padding: 7,
          key: _keyButton3,
        ),
        TabNavigationItem(
            page: GroupScreen(),
            icon: Icon(
              AppIcons.groups,
              size: 18,
              color: AppColors.bottomNavIconColor,
            ),
            title: "Groups",
            padding: 4),
        TabNavigationItem(
          page: SettingsScreen(_setDefaultSnooze),
          icon: Icon(
            Icons.more_horiz,
            size: 22,
            color: AppColors.bottomNavIconColor,
          ),
          title: "More",
          padding: 2,
          key: _keyButton4,
        ),
        TabNavigationItem(
            page: DevotionPlans(_setCurrentIndex),
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 7),
        TabNavigationItem(
            page: RecommenededBibles(_setCurrentIndex),
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 7),
      ];
}

class TabNavigationItem {
  final Widget page;
  final String title;
  final Icon icon;
  final double padding;
  final GlobalKey key;

  TabNavigationItem({
    @required this.page,
    @required this.title,
    @required this.icon,
    @required this.padding,
    this.key,
  });
}
