import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/Widgets/find_a_group.dart';
import 'package:be_still/screens/prayer/widgets/prayer_list.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bar.dart';
import 'Widgets/prayer_menu.dart';

class PrayerScreen extends StatefulWidget {
  static const routeName = 'prayer-screen';
  @override
  _PrayerScreenState createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  var _key = GlobalKey<State>();

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
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getPrayers();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 60,
                child: PrayerMenu(),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.842,
                child: SingleChildScrollView(
                  child:
                      Provider.of<PrayerProvider>(context).currentPrayerType ==
                              PrayerActiveScreen.findGroup
                          ? FindAGroup()
                          : PrayerList(),
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: CustomDrawer(),
    );
  }
}
