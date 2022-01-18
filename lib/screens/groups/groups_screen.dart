import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
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
    // return (Navigator.of(context).pushNamedAndRemoveUntil(
    //         EntryScreen.routeName, (Route<dynamic> route) => false)) ??
    //     false;
    return false;
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle('GROUPS');
      } catch (e, s) {
        final user =
            Provider.of<UserProvider>(context, listen: false).currentUser;
        BeStilDialog.showErrorDialog(
            context, StringUtils.errorOccured, user, s);
      }
    });
    super.initState();
  }

  bool _isInit = true;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
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
          .setGroupPrayers(data.group?.id ?? '');
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<GroupProvider>(context).userGroups;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          showPrayerActions: false,
          isSearchMode: false,
          showOnlyTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
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
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.only(left: 50),
                      child: LongButton(
                        onPress: () {
                          try {
                            Provider.of<MiscProvider>(context, listen: false)
                                .setPageTitle('FIND A GROUP');
                            appCOntroller.setCurrentPage(11, true);
                          } catch (e, s) {
                            final user = Provider.of<UserProvider>(context,
                                    listen: false)
                                .currentUser;
                            BeStilDialog.showErrorDialog(
                                context, StringUtils.errorOccured, user, s);
                          }
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
                          try {
                            await Provider.of<MiscProvider>(context,
                                    listen: false)
                                .setPageTitle('CREATE A GROUP');
                            Provider.of<GroupProvider>(context, listen: false)
                                .setEditMode(false);
                            appCOntroller.setCurrentPage(12, true);
                          } catch (e, s) {
                            final user = Provider.of<UserProvider>(context,
                                    listen: false)
                                .currentUser;
                            BeStilDialog.showErrorDialog(
                                context, StringUtils.errorOccured, user, s);
                          }
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
                              'You are currently not in any group',
                              style: AppTextStyles.demiboldText34,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.only(left: 50),
                            child: Column(
                              children: <Widget>[
                                ...data.map((e) {
                                  final _currentUser =
                                      Provider.of<UserProvider>(context)
                                          .currentUser;

                                  bool isAdmin = (e.groupUsers ?? [])
                                      .where(
                                          (e) => e.role == GroupUserRole.admin)
                                      .map((e) => e.userId)
                                      .contains(_currentUser.id);
                                  return Column(
                                    children: [
                                      LongButton(
                                        onPress: () async {
                                          try {
                                            await Provider.of<
                                                        GroupPrayerProvider>(
                                                    context,
                                                    listen: false)
                                                .setFollowedPrayerByUserId(
                                                    _currentUser.id ?? '');
                                            _getPrayers(e);
                                            appCOntroller.setCurrentPage(
                                                8, true);
                                          } on HttpException catch (e, s) {
                                            final user =
                                                Provider.of<UserProvider>(
                                                        context,
                                                        listen: false)
                                                    .currentUser;
                                            BeStilDialog.showErrorDialog(
                                                context,
                                                StringUtils.getErrorMessage(e),
                                                user,
                                                s);
                                          } catch (e, s) {
                                            final user =
                                                Provider.of<UserProvider>(
                                                        context,
                                                        listen: false)
                                                    .currentUser;
                                            BeStilDialog.showErrorDialog(
                                                context,
                                                StringUtils.errorOccured,
                                                user,
                                                s);
                                          }
                                        },
                                        text: e.group?.name ?? '',
                                        backgroundColor:
                                            AppColors.groupCardBgColor,
                                        textColor: AppColors.lightBlue3,
                                        hasIcon: false,
                                        hasMore: true,
                                        child: isAdmin
                                            ? Text(
                                                "Admin",
                                                style: TextStyle(
                                                    color: AppColors.lightBlue3,
                                                    fontSize: 12),
                                                textAlign: TextAlign.center,
                                              )
                                            : SizedBox.shrink(),
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
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                    SizedBox(height: 80),
                  ],
                ).marginOnly(bottom: 150),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
