import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/providers/v2/devotional_provider.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
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
import 'package:cron/cron.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      final miscProvider = Provider.of<MiscProviderV2>(context, listen: false);

      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        final user = await Provider.of<UserProviderV2>(context, listen: false)
            .getUserDataById(FirebaseAuth.instance.currentUser?.uid ?? '');
        Provider.of<PrayerProviderV2>(context, listen: false)
            .setPrayerFilterOptions(Status.active);
        if (miscProvider.initialLoad) {
          await _preLoadData();
          Future.delayed(Duration(milliseconds: 500));

          initDynamicLinks();
        }
        if ((user.enableNotificationsForAllGroups ?? false)) {
          messaging = FirebaseMessaging.instance;
          messaging.getToken().then((value) => {
                Provider.of<NotificationProviderV2>(context, listen: false)
                    .init(user.devices ?? <DeviceModel>[])
              });
        }
      });
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
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

        Provider.of<GroupProviderV2>(context, listen: false)
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
      Provider.of<GroupProviderV2>(context, listen: false)
          .setJoinGroupId(_groupId);
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  notificationInit() {}

  Future<void> _preLoadData() async {
    try {
      if (Settings.setenableLocalAuth)
        Settings.enableLocalAuth = true;
      else
        Settings.enableLocalAuth = false;

      //set all users
      await Provider.of<UserProviderV2>(context, listen: false).setAllUsers();
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      Provider.of<MiscProviderV2>(context, listen: false).setDeviceId();
      await Provider.of<DevotionalProviderV2>(context, listen: false)
          .getDevotionals();
      await Provider.of<DevotionalProviderV2>(context, listen: false)
          .getBibles();

      // get all push notifications
      await Provider.of<NotificationProviderV2>(context, listen: false)
          .setUserNotifications(userId);

      // get all local notifications
      await Provider.of<NotificationProviderV2>(context, listen: false)
          .setLocalNotifications();
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  void _setDefaultSnooze(selectedDuration, selectedInterval) async {
    try {
      await Provider.of<UserProviderV2>(context, listen: false)
          .updateUserSettings(
              SettingsKey.defaultSnoozeDuration, selectedDuration);
      await Provider.of<UserProviderV2>(context, listen: false)
          .updateUserSettings(
              SettingsKey.defaultSnoozeFrequency, selectedInterval);
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  GlobalKey _keyButton = GlobalKey();
  GlobalKey _keyButton2 = GlobalKey();
  GlobalKey _keyButton3 = GlobalKey();
  GlobalKey _keyButton4 = GlobalKey();
  GlobalKey _keyButton5 = GlobalKey();
  GlobalKey _keyButton6 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final miscProvider = Provider.of<MiscProviderV2>(context);
    _isSearchMode = Provider.of<MiscProviderV2>(context, listen: false).search;

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
            ? BeStilDialog.getLoading(context, true)
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
        _keyButton6,
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
                      Provider.of<PrayerProviderV2>(context, listen: false)
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
                  Provider.of<PrayerProviderV2>(context, listen: false)
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
              final user = Provider.of<UserProviderV2>(context, listen: false)
                  .currentUser;
              BeStilDialog.showErrorDialog(
                  context, StringUtils.getErrorMessage(e), user, s);
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
            _keyButton6,
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
            padding: 6,
            key: _keyButton6),
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
            page: RecommendedBibles(), //6
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
