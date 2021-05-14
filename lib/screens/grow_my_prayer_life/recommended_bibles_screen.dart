import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/prayer_list.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/groups/groups_screen.dart';
import 'package:be_still/screens/prayer_time/prayer_time_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_expansion_tile.dart' as custom;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommenededBibles extends StatefulWidget {
  static const routeName = 'recommended-bible';

  @override
  _RecommenededBiblesState createState() => _RecommenededBiblesState();
}

class _RecommenededBiblesState extends State<RecommenededBibles> {
  bool _isInit = true;
  final _scrollController = new ScrollController();
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle('');
        _getBibles();
        _getPrayers();
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

  Future<void> _getBibles() async {
    await BeStilDialog.showLoading(context, '');
    try {
      await Provider.of<DevotionalProvider>(context, listen: false).getBibles();
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Future<void> _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          controller: _scrollController,
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
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Recommended Bibles',
                      style: AppTextStyles.boldText24
                          .copyWith(color: AppColors.blueTitle),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Text(
                            'Prayer is a conversation with God. The primary way God speaks to us is through his written Word, the Bible. ',
                            style: AppTextStyles.regularText16b
                                .copyWith(color: AppColors.prayerTextColor),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Text(
                            'The first step in growing your prayer life is to learn God’s voice through reading his Word. Selecting the correct translation of the Bible is important to understanding what God is saying to you.',
                            style: AppTextStyles.regularText16b
                                .copyWith(color: AppColors.prayerTextColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildPanel(),
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
            for (final tabItem
                in getItems(Provider.of<MiscProvider>(context, listen: false)))
              BottomNavigationBarItem(icon: tabItem.icon, label: tabItem.title)
          ],
        ),
      );
    });
  }

  Widget _buildPanel() {
    final bibleData = Provider.of<DevotionalProvider>(context).bibles;
    return Theme(
      data: ThemeData().copyWith(cardColor: Colors.transparent),
      child: Container(
        padding: EdgeInsets.only(top: 35, bottom: 200),
        child: Column(
          children: <Widget>[
            for (int i = 0; i < bibleData.length; i++)
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: custom.ExpansionTile(
                  iconColor: AppColors.lightBlue4,
                  headerBackgroundColorStart: AppColors.prayerMenu[0],
                  headerBackgroundColorEnd: AppColors.prayerMenu[1],
                  shadowColor: AppColors.dropShadow,
                  title: Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1),
                    child: Text(
                      bibleData[i].shortName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.boldText20.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  initiallyExpanded: true,
                  scrollController: _scrollController,
                  children: <Widget>[
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[
                          Text(
                            bibleData[i].name,
                            style: AppTextStyles.regularText16b
                                .copyWith(color: AppColors.prayerTextColor),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 20.0),
                            child: Text(
                              'Recommended For ${bibleData[i].recommendedFor}',
                              style: AppTextStyles.regularText16b
                                  .copyWith(color: AppColors.prayerTextColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          OutlinedButton(
                            style: ButtonStyle(
                              side: MaterialStateProperty.all<BorderSide>(
                                  BorderSide(color: AppColors.lightBlue4)),
                            ),
                            onPressed: () => _launchURL(bibleData[i].link),
                            child: Text(
                              'READ NOW',
                              style: AppTextStyles.boldText18
                                  .copyWith(color: AppColors.lightBlue4),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
}

List<TabNavigationItem> getItems(miscProvider) => [
      TabNavigationItem(
        page: Container(
          child: Center(child: Text('tetetette')),
        ),
        icon: Icon(
          AppIcons.list,
          size: 16,
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
        icon: Icon(
          AppIcons.bestill_add,
          key: Settings.isAppInit ? miscProvider.keyButton2 : null,
          size: 16,
          color: AppColors.bottomNavIconColor,
        ),
        title: "Add",
      ),
      TabNavigationItem(
        page: PrayerTime(),
        icon: Icon(
          AppIcons.bestill_menu_logo_lt,
          key: Settings.isAppInit ? miscProvider.keyButton3 : null,
          size: 16,
          color: AppColors.bottomNavIconColor,
        ),
        title: "Pray",
      ),
      TabNavigationItem(
        page: GroupScreen(),
        icon: Icon(
          AppIcons.groups,
          size: 16,
          color: AppColors.bottomNavIconColor,
        ),
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
