import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/prayer_list.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_bar.dart';

class PrayerScreen extends StatefulWidget {
  static const routeName = '/prayer-screen';
  @override
  _PrayerScreenState createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  static final _formKey = new GlobalKey<FormState>();
  bool _hideNavBar;
  BuildContext selectedContext;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _hideNavBar = false;
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Widget> _buildScreens() {
    return [
      PrayerList(),
      GroupScreen(),
      AddPrayer(
        isEdit: false,
        isGroup: false,
        showCancel: false,
      ),
      Container(),
    ];
  }

  void _searchPrayer(String value) async {
    await Provider.of<PrayerProvider>(context, listen: false)
        .searchPrayers(value);
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    var isDark = Provider.of<ThemeProvider>(context).isDarkModeEnabled;
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.menu),
        activeColor: AppColors.appBarColor,
        inactiveColor: isDark ? AppColors.lightBlue4 : AppColors.offWhite4,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        activeColor: AppColors.appBarColor,
        inactiveColor: isDark ? AppColors.lightBlue4 : AppColors.offWhite4,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add),
        activeColor: AppColors.appBarColor,
        inactiveColor: isDark ? AppColors.lightBlue4 : AppColors.offWhite4,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(AppIcons.second_logo),
        activeColor: AppColors.appBarColor,
        inactiveColor: isDark ? AppColors.lightBlue4 : AppColors.offWhite4,
      ),
    ];
  }

  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        formKey: _formKey,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
          image: DecorationImage(
            image: AssetImage(StringUtils.getBackgroundImage(
                _themeProvider.isDarkModeEnabled)),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          decoration: NavBarDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: AppColors.appBarBackground,
            ),
          ),
          // backgroundColor: AppColors.appBarBg(_themeProvider.isDarkModeEnabled),
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
              ? 0.0
              : kBottomNavigationBarHeight,
          hideNavigationBarWhenKeyboardShows: true,
          // margin: EdgeInsets.all(10.0),
          popActionScreens: PopActionScreensType.once,
          bottomScreenMargin: 0.0,
          // routeAndNavigatorSettings: RouteAndNavigatorSettings(
          //   initialRoute: '/',
          //   routes: {
          //     PrayerScreen.routeName: (context) => PrayerScreen(),
          //     AddPrayer.routeName: (context) => AddPrayer(),
          //     // PrayerScreen.routeName: (context) => PrayerScreen(),
          //   },
          // ),
          onWillPop: () async {
            await showDialog(
              context: context,
              useSafeArea: true,
              builder: (context) => Container(
                height: 50.0,
                width: 50.0,
                color: Colors.white,
                child: RaisedButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            );
            return false;
          },
          selectedTabScreenContext: (context) {
            selectedContext = context;
          },
          hideNavigationBar: _hideNavBar,
          popAllScreensOnTapOfSelectedTab: true,
          itemAnimationProperties: ItemAnimationProperties(
            duration: Duration(milliseconds: 400),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimation(
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style12,
        ),
      ),
      endDrawer: CustomDrawer(),
    );
  }
}
