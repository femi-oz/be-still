import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/screens/grow_my_prayer_life/grow_my_prayer_life_screen.dart';
import 'package:be_still/screens/prayer/prayer_list.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryScreen extends StatefulWidget {
  static const routeName = '/entry';
  final int screenNumber;

  EntryScreen({this.screenNumber = 0});
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

bool _isSearchMode = false;

class _EntryScreenState extends State<EntryScreen> {
  BuildContext bcontext;
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _switchSearchMode(bool value) => setState(() => _isSearchMode = value);

  @override
  void initState() {
    _currentIndex = widget.screenNumber;
    _switchSearchMode(false);
    super.initState();
  }

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
    if (userId != null)
      cron.schedule(Schedule.parse('*/10 * * * *'), () async {
        Provider.of<PrayerProvider>(context, listen: false)
            .checkPrayerValidity(userId);
      });
    UserModel _user =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    // final options =
    //     Provider.of<PrayerProvider>(context, listen: false).filterOptions;
    // final settings =
    //     Provider.of<SettingsProvider>(context, listen: false).settings;
    // await Provider.of<PrayerProvider>(context, listen: false).setPrayers(
    //     _user?.id,
    //     options.contains(Status.archived) && options.length == 1
    //         ? settings.archiveSortBy
    //         : settings.defaultSortBy);

    //load settings
    await Provider.of<SettingsProvider>(context, listen: false)
        .setPrayerSettings(_user.id);
    await Provider.of<SettingsProvider>(context, listen: false)
        .setSettings(_user.id);
    Provider.of<SettingsProvider>(context, listen: false)
        .setSharingSettings(_user.id);

    await Provider.of<NotificationProvider>(context, listen: false)
        .setPrayerTimeNotifications(userId);

    //get all users
    Provider.of<UserProvider>(context, listen: false).setAllUsers(_user.id);

    // get all push notifications
    await Provider.of<NotificationProvider>(context, listen: false)
        .setUserNotifications(_user?.id);

    // get all local notifications
    Provider.of<NotificationProvider>(context, listen: false)
        .setLocalNotifications(_user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _currentIndex == 2
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
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
                height: double.infinity,
                child: TabNavigationItem.items[_currentIndex].page);
          } else
            return BeStilDialog.getLoading();
        },
      ),
      bottomNavigationBar: _createBottomNavigationBar(),
      endDrawer: CustomDrawer(),
    );
  }

  showInfoModal() {
    // BeStilDialog.showConfirmDialog(context,
    //     message: 'This feature will be available soon.');
    //
    AlertDialog dialog = AlertDialog(
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
                'This feature will be available soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue4,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            // GestureDetector(
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
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Widget _createBottomNavigationBar() {
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
            if (index == 1) {
              showInfoModal();
              return;
            }
            if (index == 4) {
              Scaffold.of(context).openEndDrawer();
              return;
            }

            _currentIndex = index;
            _switchSearchMode(false);
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          unselectedItemColor: AppColors.bottomNavIconColor,
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
            Icons.home,
            size: 26,
            color: AppColors.bottomNavIconColor,
          ),
          title: "prayer",
        ),
        TabNavigationItem(
          page: GroupScreen(),
          icon: Icon(AppIcons.bestill_groups,
              size: 18, color: AppColors.bottomNavIconColor),
          title: "group",
        ),
        TabNavigationItem(
          page: AddPrayer(
            isEdit: false,
            isGroup: false,
            showCancel: false,
          ),
          icon: Icon(AppIcons.bestill_add,
              size: 18, color: AppColors.bottomNavIconColor),
          title: "add prayer",
        ),
        TabNavigationItem(
          page: GrowMyPrayerLifeScreen(),
          icon: Icon(AppIcons.bestill_menu_logo_lt,
              size: 18, color: AppColors.bottomNavIconColor),
          title: "grow my prayer life",
        ),
        TabNavigationItem(
          page: null,
          icon: Icon(
            AppIcons.bestill_main_menu,
            size: 18,
            color: AppColors.bottomNavIconColor,
          ),
          title: "Main Menu",
        ),
      ];
}
