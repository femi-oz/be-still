import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/prayer_list.dart';
import 'package:be_still/screens/Settings/settings_screen.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/add_update/add_update.dart';
import 'package:be_still/screens/create_group/create_group_screen.dart';
import 'package:be_still/screens/group_prayer_details/group_prayer_details_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/screens/groups/widgets/find_a_group.dart';
import 'package:be_still/screens/groups/widgets/group_prayers.dart';
import 'package:be_still/screens/grow_my_prayer_life/devotion_and_reading_plans.dart';
import 'package:be_still/screens/grow_my_prayer_life/recommended_bibles_screen.dart';
import 'package:be_still/screens/notifications/notifications_screen.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/screens/prayer_time/prayer_time_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/info_modal.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:be_still/widgets/join_group.dart';
import 'package:cron/cron.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class EntryScreen extends StatefulWidget {
  static const routeName = '/entry';
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

late TutorialCoachMark tutorialCoachMark;

class _EntryScreenState extends State<EntryScreen> {
  // BuildContext bcontext;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late FirebaseMessaging messaging;

  bool _isSearchMode = false;
  void _switchSearchMode(bool value) => _isSearchMode = value;

  final cron = Cron();

  initState() {
    try {
      final miscProvider = Provider.of<MiscProvider>(context, listen: false);
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        final user =
            Provider.of<UserProvider>(context, listen: false).currentUser;
        if (miscProvider.initialLoad) {
          await _preLoadData();
          Future.delayed(Duration(milliseconds: 500));
          miscProvider.setLoadStatus(false);

          initDynamicLinks();
        }
        if ((Provider.of<SettingsProvider>(context, listen: false)
                .groupPreferenceSettings
                .enableNotificationForAllGroups ??
            false)) {
          messaging = FirebaseMessaging.instance;
          messaging.getToken().then((value) => {
                Provider.of<NotificationProvider>(context, listen: false)
                    .init(value ?? "", user.id ?? '', user)
              });
        }
      });
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
    super.initState();
  }

  Future<void> initDynamicLinks() async {
    try {
      String _groupId = '';
      FirebaseDynamicLinks.instance.onLink(
          onSuccess: (PendingDynamicLinkData? dynamicLink) async {
        final Uri deepLink = dynamicLink?.link ?? Uri();
        // if (deepLink != null) {
        _groupId = deepLink.queryParameters['groups'] ?? "";

        Provider.of<GroupProvider>(context, listen: false)
            .setJoinGroupId(_groupId);
        // }
      }, onError: (OnLinkErrorException e) async {
        print('onLinkError');
        print(e.message);
      });

      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri deepLink = data?.link ?? Uri();

      _groupId = deepLink.queryParameters['groups'] ?? "";
      Provider.of<GroupProvider>(context, listen: false)
          .setJoinGroupId(_groupId);

      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      if (_groupId.isNotEmpty)
        Provider.of<GroupProvider>(context, listen: false)
            .getGroupFuture(_groupId, userId ?? '')
            .then((groupPrayer) {
          if (!(groupPrayer.groupUsers ?? []).any((u) => u.userId == userId))
            JoinGroup().showAlert(context, groupPrayer);
        });
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  notificationInit() {}

  Future<void> _preLoadData() async {
    try {
      if (Settings.setenableLocalAuth)
        Settings.enableLocalAuth = true;
      else
        Settings.enableLocalAuth = false;

      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;

      await _getPrayers();
      await _getActivePrayers();
      await _getDevotionals();
      await _getBibles();
      //load settings
      await Provider.of<SettingsProvider>(context, listen: false)
          .setPrayerSettings(userId ?? '');
      await Provider.of<SettingsProvider>(context, listen: false)
          .setSettings(userId ?? '');
      await Provider.of<SettingsProvider>(context, listen: false)
          .setSharingSettings(userId ?? '');
      await Provider.of<NotificationProvider>(context, listen: false)
          .setPrayerTimeNotifications(userId ?? '');
      // await Provider.of<SettingsProvider>(context, listen: false)
      //     .setGroupSettings(userId??'');
      await Provider.of<SettingsProvider>(context, listen: false)
          .setGroupPreferenceSettings(userId ?? '');
      await Provider.of<GroupProvider>(context, listen: false)
          .setUserGroups(userId ?? '');
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .setFollowedPrayerByUserId(userId ?? '');

      //set all users
      // await Provider.of<UserProvider>(context, listen: false)
      //     .setAllUsers(userId ?? '');

      // get all push notifications
      await Provider.of<NotificationProvider>(context, listen: false)
          .setUserNotifications(userId ?? '');

      // get all local notifications
      await Provider.of<NotificationProvider>(context, listen: false)
          .setLocalNotifications(userId ?? '');
      await Provider.of<GroupProvider>(context, listen: false)
          .setAllGroups(userId ?? '');
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  Future<void> _getActivePrayers() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayerTimePrayers(_user.id ?? '');
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  Future<void> _getPrayers() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      final searchQuery =
          Provider.of<MiscProvider>(context, listen: false).searchQuery;
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayerTimePrayers(_user.id ?? '');
      if (searchQuery.isNotEmpty) {
        Provider.of<PrayerProvider>(context, listen: false)
            .searchPrayers(searchQuery, _user.id ?? '');
      } else {
        await Provider.of<PrayerProvider>(context, listen: false)
            .setPrayers(_user.id ?? '');
      }
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  Future<void> _getDevotionals() async {
    try {
      await Provider.of<DevotionalProvider>(context, listen: false)
          .getDevotionals();
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  Future<void> _getBibles() async {
    try {
      await Provider.of<DevotionalProvider>(context, listen: false).getBibles();
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  void _setDefaultSnooze(selectedDuration, selectedInterval, settingsId) async {
    try {
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSettings(
        userId ?? '',
        key: SettingsKey.defaultSnoozeDuration,
        value: selectedDuration,
        settingsId: settingsId,
      );
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSettings(
        userId ?? '',
        key: SettingsKey.defaultSnoozeFrequency,
        value: selectedInterval,
        settingsId: settingsId,
      );
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
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

    AppController appController = Get.find();
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
                controller: appController.tabController,
                children: [
                  for (int i = 0; i < getItems().length; i++)
                    getItems().map((e) => e.page).toList()[i],
                ],
              ),
      ),
      bottomNavigationBar:
          _createBottomNavigationBar(appController.currentPage),
      endDrawer: CustomDrawer(
        (index) {
          AppController appController = Get.find();

          appController.setCurrentPage(index, true, 0);
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
            try {
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
                    AppController appController = Get.find();
                    appController.setCurrentPage(index, true, 0);
                  }
                  break;
                case 1:
                  Provider.of<PrayerProvider>(context, listen: false)
                      .setEditMode(false, true);
                  // Provider.of<PrayerProvider>(context, listen: false)
                  //     .setEditPrayer();
                  AppController appController = Get.find();

                  appController.setCurrentPage(1, true, 0);
                  break;
                case 4:
                  Scaffold.of(context).openEndDrawer();
                  break;
                default:
                  AppController appController = Get.find();
                  appController.setCurrentPage(index, true, 0);
                  break;
              }
            } catch (e, s) {
              final user =
                  Provider.of<UserProvider>(context, listen: false).currentUser;
              BeStilDialog.showErrorDialog(
                  context, StringUtils.errorOccured, user, s);
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
                          fontSize: 11,
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
          title: "My Prayers",
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
          padding: 8,
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
            padding: 6),
        TabNavigationItem(
          page: SettingsScreen(_setDefaultSnooze), //4
          icon: Icon(
            Icons.more_horiz,
            size: 22,
            color: AppColors.bottomNavIconColor,
          ),
          title: "More",
          padding: 4,
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
            page: GroupPrayers(_switchSearchMode, _isSearchMode), //8
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
            page: Container(), //10
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
        TabNavigationItem(
            page: AddUpdate(), //13
            icon: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.bottomNavIconColor,
            ),
            title: "More",
            padding: 7),
        TabNavigationItem(
            page: NotificationsScreen(), //14
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
  final GlobalKey? key;

  TabNavigationItem({
    required this.page,
    required this.title,
    required this.icon,
    required this.padding,
    this.key,
  });
}
