import 'dart:ui';
import 'package:be_still/models/devotionals.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/prayer_list.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/screens/prayer_time/prayer_time_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DevotionPlans extends StatefulWidget {
  static const routeName = 'devotion-plan';

  @override
  _DevotionPlansState createState() => _DevotionPlansState();
}

class _DevotionPlansState extends State<DevotionPlans> {
  bool _isInit = true;
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle('');
        _getPrayers();
        await _getDevotionals();
      });
      setState(() => _isInit = false);
    }
    super.didChangeDependencies();
  }

  void _getPrayers() async {
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

  Future<void> _getDevotionals() async {
    await BeStilDialog.showLoading(context, '');
    try {
      await Provider.of<DevotionalProvider>(context, listen: false)
          .getDevotionals();
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showAlert(DevotionalModel dev) {
    final dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor: AppColors.backgroundColor[0],
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      AppIcons.bestill_close,
                      color: AppColors.grey4,
                    ),
                  )
                ],
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      width: double.infinity,
                      child: Text(
                        dev.title.toUpperCase(),
                        style: AppTextStyles.boldText20
                            .copyWith(color: AppColors.lightBlue4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Length: ${dev.period}',
                        style: AppTextStyles.regularText16b
                            .copyWith(color: AppColors.grey4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      width: double.infinity,
                      child: Text(
                        dev.description,
                        style: AppTextStyles.regularText16b
                            .copyWith(color: AppColors.blueTitle),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _launchURL(dev.link),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.lightBlue1,
                        AppColors.lightBlue2,
                      ],
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'see devotional'.toUpperCase(),
                        style: AppTextStyles.boldText24
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'you will leave the app'.toUpperCase(),
                        style: AppTextStyles.regularText13
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: dialog,
          );
        });
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
            switch (index) {
              case 0:
                NavigationService.instance.goHome(0);
                break;
              case 1:
                NavigationService.instance.goHome(1);
                break;
              case 4:
                Scaffold.of(context).openEndDrawer();
                break;
              case 3:
                message = 'This feature will be available soon.';
                showInfoModal(message);
                break;
              case 2:
                if (prayers.length == 0) {
                  message =
                      'You must have at least one active prayer to start prayer time.';
                  showInfoModal(message);
                } else {
                  NavigationService.instance.goHome(2);
                }

                break;
              default:
                NavigationService.instance.goHome(0);
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

  @override
  Widget build(BuildContext context) {
    final devotionalData = Provider.of<DevotionalProvider>(context).devotionals;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(StringUtils.backgroundImage),
                alignment: Alignment.bottomCenter,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundColor[0].withOpacity(0.85),
                    AppColors.backgroundColor[1].withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        TextButton.icon(
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    EdgeInsets.zero),
                          ),
                          icon: Icon(
                            AppIcons.bestill_back_arrow,
                            color: AppColors.lightBlue3,
                            size: 20,
                          ),
                          onPressed: () => NavigationService.instance.goHome(0),
                          label: Text(
                            'BACK',
                            style: AppTextStyles.boldText20.copyWith(
                              color: AppColors.lightBlue3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Devotionals & Reading Plans',
                      style: AppTextStyles.boldText24
                          .copyWith(color: AppColors.blueTitle),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 30.0,
                      left: 20,
                      bottom: 20,
                    ),
                    child: Column(
                      children: <Widget>[
                        ...devotionalData.map(
                          (dev) => GestureDetector(
                            onTap: () => _showAlert(dev),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 7.0),
                              decoration: BoxDecoration(
                                  color: AppColors.prayerCardBgColor,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                  ),
                                  border:
                                      Border.all(color: AppColors.cardBorder)),
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.prayerCardBgColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          dev.type.toUpperCase(),
                                          style: AppTextStyles.regularText14
                                              .copyWith(
                                                  color: AppColors.grey4,
                                                  fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          'LENGTH: ${dev.period}'.toUpperCase(),
                                          style: AppTextStyles.regularText13
                                              .copyWith(color: AppColors.grey4),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: Divider(
                                        color: AppColors.darkBlue,
                                        thickness: 1,
                                      ),
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          dev.title,
                                          style: AppTextStyles.regularText16b
                                              .copyWith(
                                                  color: AppColors.lightBlue4),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          _currentIndex == 3 ? null : _createBottomNavigationBar(),
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
