import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/groups/widgets/group_tools.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatefulWidget {
  static const routeName = 'group-screen';
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  AppCOntroller appCOntroller = Get.find();
  Future<bool> _onWillPop() async {
    return (Navigator.of(context).pushNamedAndRemoveUntil(
            EntryScreen.routeName, (Route<dynamic> route) => false)) ??
        false;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<MiscProvider>(context, listen: false)
          .setPageTitle('MY GROUPS');
      // appCOntroller.setCurrentPage(4, true);
    });
    super.initState();
  }

  bool _isInit = true;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      // await Provider.of<GroupProvider>(context, listen: false)
      //     .setAllGroups(_user.id);
      await Provider.of<GroupProvider>(context, listen: false)
          .setUserGroups(_user.id);
      setState(() {});

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _getPrayers(CombineGroupUserStream data) async {
    try {
      await Provider.of<GroupProvider>(context, listen: false)
          .setCurrentGroup(data);
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .setGroupPrayers(data.group.id);
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

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<GroupProvider>(context, listen: false).userGroups;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(showPrayerActions: false),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundColor,
            ),
            image: DecorationImage(
              image: AssetImage(StringUtils.backgroundImage),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20 + MediaQuery.of(context).padding.top),
                Container(
                  padding: EdgeInsets.only(left: 50),
                  child: LongButton(
                    onPress: () {
                      Provider.of<MiscProvider>(context, listen: false)
                          .setPageTitle('FIND A GROUP');
                      appCOntroller.setCurrentPage(11, true);
                    },
                    text: 'FIND A GROUP',
                    backgroundColor:
                        AppColors.groupActionBgColor.withOpacity(0.9),
                    textColor: AppColors.addprayerTextColor,
                    hasIcon: false,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.only(left: 50),
                  child: LongButton(
                    onPress: () async {
                      await Provider.of<MiscProvider>(context, listen: false)
                          .setPageTitle('CREATE A GROUP');
                      // await Provider.of<MiscProvider>(context, listen: false)
                      //     .setIsEdit(false);
                      appCOntroller.setCurrentPage(12, true);
                    },
                    text: 'CREATE A GROUP',
                    backgroundColor:
                        AppColors.groupActionBgColor.withOpacity(0.9),
                    textColor: AppColors.addprayerTextColor,
                    hasIcon: false,
                  ),
                ),
                SizedBox(height: 30),
                data.length == 0
                    ? Container(
                        padding: EdgeInsets.only(right: 20, left: 20),
                        child: Text(
                          'You are currently not in any groups',
                          style: AppTextStyles.demiboldText34,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(left: 50),
                        child: Column(
                          children: <Widget>[
                            ...data
                                .map(
                                  (e) => Column(
                                    children: [
                                      LongButton(
                                        onPress: () async {
                                          _getPrayers(e);
                                          appCOntroller.setCurrentPage(8, true);
                                        },
                                        text: e.group.name,
                                        backgroundColor:
                                            AppColors.groupCardBgColor,
                                        textColor: AppColors.lightBlue3,
                                        hasIcon: false,
                                        hasMore: true,
                                        onPressMore: () => showModalBottomSheet(
                                          context: context,
                                          barrierColor:
                                              Provider.of<ThemeProvider>(
                                                          context,
                                                          listen: false)
                                                      .isDarkModeEnabled
                                                  ? AppColors.backgroundColor[0]
                                                      .withOpacity(0.8)
                                                  : Color(0xFF021D3C)
                                                      .withOpacity(0.7),
                                          backgroundColor:
                                              Provider.of<ThemeProvider>(
                                                          context,
                                                          listen: false)
                                                      .isDarkModeEnabled
                                                  ? AppColors.backgroundColor[0]
                                                      .withOpacity(0.8)
                                                  : Color(0xFF021D3C)
                                                      .withOpacity(0.7),
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return GroupTools(e);
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
