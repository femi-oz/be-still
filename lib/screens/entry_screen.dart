import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/screens/grow_my_prayer_life/grow_my_prayer_life_screen.dart';
import 'package:be_still/screens/prayer/prayer_list.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class EntryScreen extends StatefulWidget {
  static const routeName = '/entry';
  final int screenNumber;

  EntryScreen({this.screenNumber = 0});
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  int _currentIndex = 0;

  static final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    _currentIndex = widget.screenNumber ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _currentIndex == 2 ? null : CustomAppBar(formKey: _formKey),
      body: Container(
          height: double.infinity,
          child: TabNavigationItem.items[_currentIndex].page),
      bottomNavigationBar: _createBottomNavigationBar(),
      endDrawer: CustomDrawer(),
    );
  }

  Widget _createBottomNavigationBar() {
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
            return;
          }
          setState(() => _currentIndex = index);
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
            AppIcons.bestill_my_list,
            size: 16,
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
      ];
}
