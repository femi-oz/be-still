import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/prayer_list.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_bar.dart';

class PrayerScreen extends StatefulWidget {
  static const routeName = 'prayer-screen';
  @override
  _PrayerScreenState createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  void _getPrayers() async {
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      await Provider.of<GroupProvider>(context, listen: false)
          .setUserGroups(_user.id);
      await Provider.of<GroupProvider>(context, listen: false)
          .setAllGroups(_user.id);

      await Provider.of<PrayerProvider>(context, listen: false)
          .setHiddenPrayers(_user.id);
      var activeList =
          Provider.of<PrayerProvider>(context, listen: false).currentPrayerType;
      var groupData =
          Provider.of<GroupProvider>(context, listen: false).currentGroup;
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayers(_user?.id, activeList, groupData?.group?.id, null);
    } on HttpException catch (e) {
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  bool _isInit = true;
  bool _hideNavBar;
  BuildContext selectedContext;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getPrayers();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _hideNavBar = false;
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // @override
  // List<Widget> _buildScreens() {
  //   return [
  //     Container(),
  //     Container(),
  //     Container(),
  //     Container(),
  //     Container(),
  //   ];
  // }
  List<Widget> _buildScreens() {
    return [
      PrayerList(),
      Container(),
      Container(),
      Container(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    var isDark = Provider.of<ThemeProvider>(context).isDarkModeEnabled;
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.menu),
        activeColor: AppColors.getAppBarColor(isDark),
        inactiveColor: AppColors.lightBlue4,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        activeColor: AppColors.getAppBarColor(isDark),
        inactiveColor: AppColors.lightBlue4,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add),
        activeColor: AppColors.getAppBarColor(isDark),
        inactiveColor: AppColors.lightBlue4,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(AppIcons.second_logo),
        activeColor: AppColors.getAppBarColor(isDark),
        inactiveColor: AppColors.lightBlue4,
      ),
    ];
  }
  // List<PersistentBottomNavBarItem> _navBarsItems() {
  //   return [
  //     PersistentBottomNavBarItem(
  //       icon: Icon(Icons.home),
  //       title: "Home",
  //       activeColor: Colors.blue,
  //       inactiveColor: Colors.grey,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(Icons.search),
  //       title: ("Search"),
  //       activeColor: Colors.teal,
  //       inactiveColor: Colors.grey,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(Icons.add),
  //       title: ("Add"),
  //       activeColor: Colors.blueAccent,
  //       inactiveColor: Colors.grey,
  //       activeColorAlternate: Colors.white,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(Icons.message),
  //       title: ("Messages"),
  //       activeColor: Colors.deepOrange,
  //       inactiveColor: Colors.grey,
  //     ),
  //     PersistentBottomNavBarItem(
  //       icon: Icon(Icons.settings),
  //       title: ("Settings"),
  //       activeColor: Colors.indigo,
  //       inactiveColor: Colors.grey,
  //     ),
  //   ];
  // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Navigation Bar Demo')),
//       drawer: Drawer(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               const Text('This is the Drawer'),
//             ],
//           ),
//         ),
//       ),
//       body: PersistentTabView(
//         context,
//         controller: _controller,
//         screens: _buildScreens(),
//         items: _navBarsItems(),
//         confineInSafeArea: true,
//         backgroundColor: Colors.white,
//         handleAndroidBackButtonPress: true,
//         resizeToAvoidBottomInset: true,
//         stateManagement: true,
//         navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
//             ? 0.0
//             : kBottomNavigationBarHeight,
//         hideNavigationBarWhenKeyboardShows: true,
//         margin: EdgeInsets.all(10.0),
//         popActionScreens: PopActionScreensType.once,
//         bottomScreenMargin: 0.0,
//         routeAndNavigatorSettings: RouteAndNavigatorSettings(
//           initialRoute: '/',
//           routes: {},
//         ),
//         onWillPop: () async {
//           await showDialog(
//             context: context,
//             useSafeArea: true,
//             builder: (context) => Container(
//               height: 50.0,
//               width: 50.0,
//               color: Colors.white,
//               child: RaisedButton(
//                 child: Text("Close"),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//           );
//           return false;
//         },
//         selectedTabScreenContext: (context) {
//           selectedContext = context;
//         },
//         hideNavigationBar: _hideNavBar,
//         decoration: NavBarDecoration(
//             colorBehindNavBar: Colors.indigo,
//             borderRadius: BorderRadius.circular(20.0)),
//         popAllScreensOnTapOfSelectedTab: true,
//         itemAnimationProperties: ItemAnimationProperties(
//           duration: Duration(milliseconds: 400),
//           curve: Curves.ease,
//         ),
//         screenTransitionAnimation: ScreenTransitionAnimation(
//           animateTabTransition: true,
//           curve: Curves.ease,
//           duration: Duration(milliseconds: 200),
//         ),
//         navBarStyle:
//             NavBarStyle.style15, // Choose the nav bar style with this property
//       ),
//     );
//   }
// }
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
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
          backgroundColor: AppColors.appBarBg(_themeProvider.isDarkModeEnabled),
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
          routeAndNavigatorSettings: RouteAndNavigatorSettings(
            initialRoute: '/',
            routes: {
              PrayerScreen.routeName: (context) => PrayerScreen(),
              AddPrayer.routeName: (context) => AddPrayer(),
              // PrayerScreen.routeName: (context) => PrayerScreen(),
            },
          ),
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
          // decoration: NavBarDecoration(
          //     colorBehindNavBar: Colors.indigo,
          //     borderRadius: BorderRadius.circular(20.0)),
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
          navBarStyle: NavBarStyle
              .style12, // Choose the nav bar style with this property
        ),
      ),
      endDrawer: CustomDrawer(),
    );
  }
}

//             child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors:
//                 AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
//           ),
//           image: DecorationImage(
//             image: AssetImage(StringUtils.getBackgroundImage(
//                 _themeProvider.isDarkModeEnabled)),
//             alignment: Alignment.bottomCenter,
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               Container(
//                 height: 60,
//                 child: PrayerMenu(),
//               ),
//               Container(
//                 height: MediaQuery.of(context).size.height * 0.842,
//                 child: SingleChildScrollView(
//                   child:
//                       Provider.of<PrayerProvider>(context).currentPrayerType ==
//                               PrayerType.findGroup
//                           ? FindAGroup()
//                           : PrayerList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//     endDrawer: CustomDrawer(),
//   );
// }
