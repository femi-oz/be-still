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
  // BuildContext bcontext;
  var _key = GlobalKey<State>();

  void _getPrayers() async {
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      // BeStilDialog.showLoading(
      //   context,
      //   _key,
      // );
      await Provider.of<GroupProvider>(context, listen: false)
          .setGroups(_user.id);

      await Provider.of<PrayerProvider>(context, listen: false)
          .setHiddenPrayers(_user.id);
      var activeList =
          Provider.of<PrayerProvider>(context, listen: false).currentPrayerType;
      var groupData =
          Provider.of<GroupProvider>(context, listen: false).currentGroup;
      // await Provider.of<GroupProvider>(context, listen: false)
      //     .setGroupUsers(group?.id);
      // var users =
      //     Provider.of<GroupProvider>(context, listen: false).currentGroupUsers;
      // var isGroupAdmin = users
      //         .firstWhere((user) => user?.userId == _user?.id,
      //             orElse: () => null)
      //         ?.isAdmin ??
      //     false;
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayers(_user?.id, activeList, groupData?.group?.id, null);
      // await Future.delayed(Duration(milliseconds: 300));
      // BeStilDialog.hideLoading(_key);
    } on HttpException catch (e) {
      // await Future.delayed(Duration(milliseconds: 300));
      // BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      // await Future.delayed(Duration(milliseconds: 300));
      // BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  bool _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getPrayers();
      _isInit = false;
    } // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    // setState(() => this.bcontext = context);

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
                child: PrayerMenu(
                    // onTextchanged: _searchPrayer,
                    // clearSearchField: _clearSearchField,
                    // searchController: _searchController,
                    // setCurrentList: _setPrayers,
                    // activeList: activeList,
                    // group: group,
                    ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.855,
                // child: StreamBuilder(
                //   stream:
                //       Provider.of<PrayerProvider>(context).filterPrayersStream,
                //   builder: (BuildContext context,
                //       AsyncSnapshot<List<PrayerModel>> snapshot) {
                //     switch (snapshot.connectionState) {
                //       case ConnectionState.waiting:
                //         return Column(
                //           children: [
                //             Expanded(
                //               child: SpinKitDoubleBounce(
                //                 color: AppColors.lightBlue1,
                //                 size: 50.0,
                //               ),
                //             ),
                //           ],
                //         );
                //       default:
                //         if (snapshot.hasError)
                //           return Column(
                //             children: [
                //               Expanded(
                //                 child: SpinKitDoubleBounce(
                //                   color: AppColors.lightBlue1,
                //                   size: 50.0,
                //                 ),
                //               ),
                //             ],
                //           );
                //         else {
                child: SingleChildScrollView(
                  child:
                      Provider.of<PrayerProvider>(context).currentPrayerType ==
                              PrayerActiveScreen.findGroup
                          ? FindAGroup()
                          : PrayerList(
                              // group: group,
                              // activeList: activeList,
                              // prayers: Provider.of<PrayerProvider>(context)
                              //     .filteredPrayers,
                              ),
                ),
                // }
                //       }
                //     },
                //   ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: CustomDrawer(),
    );
  }
}
