import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/prayer_list.dart';
import 'package:be_still/screens/Settings/settings_screen.dart';
import 'package:be_still/screens/add_prayer/add_group_prayer_screen.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/create_group/create_group_screen.dart';
import 'package:be_still/screens/group_prayer_details/group_prayer_details_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/screens/groups/widgets/find_a_group.dart';
import 'package:be_still/screens/groups/widgets/group_prayers.dart';
import 'package:be_still/screens/grow_my_prayer_life/devotion_and_reading_plans.dart';
import 'package:be_still/screens/grow_my_prayer_life/recommended_bibles_screen.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/screens/prayer_time/prayer_time_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/info_modal.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class EntryScreen extends StatefulWidget {
  static const routeName = '/entry';
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

TutorialCoachMark tutorialCoachMark;

class _EntryScreenState extends State<EntryScreen> {
  BuildContext bcontext;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSearchMode = false;
  void _switchSearchMode(bool value) => _isSearchMode = value;

  final cron = Cron();

  initState() {
    final miscProvider = Provider.of<MiscProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (miscProvider.initialLoad) {
        await _preLoadData();
        miscProvider.setLoadStatus(false);
      }
    });
    super.initState();
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
      await Provider.of<SettingsProvider>(context, listen: false)
          .setGroupSettings(userId);
      await Provider.of<SettingsProvider>(context, listen: false)
          .setGroupPreferenceSettings(userId);

      //set all users
      Provider.of<UserProvider>(context, listen: false).setAllUsers(userId);

      // get all push notifications
      Provider.of<NotificationProvider>(context, listen: false)
          .setUserNotifications(userId);

      // get all local notifications
      Provider.of<NotificationProvider>(context, listen: false)
          .setLocalNotifications(userId);
      await Provider.of<GroupProvider>(context, listen: false)
          .setAllGroups(userId);
      await Provider.of<GroupProvider>(context, listen: false)
          .setUserGroups(userId);
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
    _isSearchMode = Provider.of<MiscProvider>(context, listen: false).search;

    AppCOntroller appCOntroller = Get.find();
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
                controller: appCOntroller.tabController,
                children: [
                  for (int i = 0; i < getItems().length; i++)
                    getItems().map((e) => e.page).toList()[i],
                ],
              ),
      ),
      bottomNavigationBar:
          _createBottomNavigationBar(appCOntroller.currentPage),
      endDrawer: CustomDrawer(
        (index) {
          AppCOntroller appCOntroller = Get.find();

          appCOntroller.setCurrentPage(index, true);
        },
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
                  showInfoModal(message, 'PrayerTime', context);
                } else {
                  AppCOntroller appCOntroller = Get.find();

                  appCOntroller.setCurrentPage(index, true);
                }
                break;
              case 1:
                Provider.of<PrayerProvider>(context, listen: false)
                    .setEditMode(false);
                Provider.of<PrayerProvider>(context, listen: false)
                    .setEditPrayer(null);
                AppCOntroller appCOntroller = Get.find();

                appCOntroller.setCurrentPage(1, true);
                break;
              case 4:
                Scaffold.of(context).openEndDrawer();
                break;
              default:
                AppCOntroller appCOntroller = Get.find();

                appCOntroller.setCurrentPage(index, true);
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
            for (final tabItem in getItems().getRange(0, 5))
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

  List<TabNavigationItem> getItems() => [
        TabNavigationItem(
          page: PrayerList(
            _keyButton,
            _keyButton2,
            _keyButton3,
            _keyButton4,
            _keyButton5,
            _isSearchMode,
            _switchSearchMode, //0
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
          page: AddPrayer(), //1
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
          page: PrayerTime(), //2
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
            page: GroupScreen(), //3
            icon: Icon(
              AppIcons.groups,
              size: 18,
              color: AppColors.bottomNavIconColor,
            ),
            title: "Groups",
            padding: 4),
        TabNavigationItem(
          page: SettingsScreen(_setDefaultSnooze), //4
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
            page: DevotionPlans(), //5
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 7),
        TabNavigationItem(
            page: RecommenededBibles(), //6
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 7),
        TabNavigationItem(
            page: PrayerDetails(), //7
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 7),
        TabNavigationItem(
            page: GroupPrayers(), //8
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 7),
        TabNavigationItem(
            page: GroupPrayerDetails(), //9
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 7),
        TabNavigationItem(
            page: AddGroupPrayer(), //10
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 7),
        TabNavigationItem(
            page: FindAGroup(), //11
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 7),
        TabNavigationItem(
            page: CreateGroupScreen(), //12
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
