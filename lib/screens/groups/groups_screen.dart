import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/theme_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/groups/widgets/group_tools.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatefulWidget {
  static const routeName = 'group-screen';
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  AppController appController = Get.find();

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      try {
        Provider.of<PrayerProviderV2>(context, listen: false)
            .setGroupPrayerFilterOptions(Status.active);
        Provider.of<PrayerProviderV2>(context, listen: false)
            .filterGroupPrayers();
        await Provider.of<MiscProviderV2>(context, listen: false)
            .setPageTitle('GROUPS');
        final userId = FirebaseAuth.instance.currentUser?.uid;
        await Provider.of<MiscProviderV2>(context, listen: false)
            .setSearchMode(false);
        await Provider.of<MiscProviderV2>(context, listen: false)
            .setSearchQuery('');
        await Provider.of<PrayerProviderV2>(context, listen: false)
            .searchGroupPrayers('', userId ?? '');
      } catch (e, s) {
        final user =
            Provider.of<UserProviderV2>(context, listen: false).currentUser;
        BeStilDialog.showErrorDialog(
            context, StringUtils.getErrorMessage(e), user, s);
      }
    });
    super.initState();
  }

  Future<void> _getGroupDetails(GroupDataModel group) async {
    try {
      await Provider.of<GroupProviderV2>(context, listen: false)
          .setCurrentGroupById(group.id ?? '');
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .setGroupPrayers(group.id ?? '');
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<GroupProviderV2>(context).userGroups;
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
                fit: BoxFit.cover,
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
                        onPress: () async {
                          try {
                            Provider.of<MiscProviderV2>(context, listen: false)
                                .setPageTitle('FIND A GROUP');

                            await Provider.of<GroupProviderV2>(context,
                                    listen: false)
                                .searchAllGroups('');

                            appController.setCurrentPage(11, true, 3);
                          } catch (e, s) {
                            final user = Provider.of<UserProviderV2>(context,
                                    listen: false)
                                .currentUser;
                            BeStilDialog.showErrorDialog(context,
                                StringUtils.getErrorMessage(e), user, s);
                          }
                        },
                        text: 'FIND A GROUP',
                        backgroundColor:
                            AppColors.groupActionBgColor.withOpacity(0.9),
                        textColor: AppColors.addPrayerTextColor,
                        hasIcon: false,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.only(left: 50),
                      child: LongButton(
                        onPress: () async {
                          try {
                            await Provider.of<MiscProviderV2>(context,
                                    listen: false)
                                .setPageTitle('CREATE A GROUP');
                            Provider.of<GroupProviderV2>(context, listen: false)
                                .setEditMode(false);
                            appController.setCurrentPage(12, true, 3);
                          } catch (e, s) {
                            final user = Provider.of<UserProviderV2>(context,
                                    listen: false)
                                .currentUser;
                            BeStilDialog.showErrorDialog(context,
                                StringUtils.getErrorMessage(e), user, s);
                          }
                        },
                        text: 'CREATE A GROUP',
                        backgroundColor:
                            AppColors.groupActionBgColor.withOpacity(0.9),
                        textColor: AppColors.addPrayerTextColor,
                        hasIcon: false,
                      ),
                    ),
                    SizedBox(height: 30),
                    data.length == 0
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 80, vertical: 60),
                            child: Opacity(
                              opacity: 0.3,
                              child: Text(
                                'You are currently not in any group',
                                style: AppTextStyles.demiboldText34,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.only(left: 50),
                            child: Column(
                              children: <Widget>[
                                ...data.map((e) {
                                  final _userId =
                                      FirebaseAuth.instance.currentUser?.uid;

                                  bool isAdmin = (e.users ?? [])
                                      .where(
                                          (e) => e.role == GroupUserRole.admin)
                                      .map((e) => e.userId)
                                      .contains(_userId);
                                  return Column(
                                    children: [
                                      LongButton(
                                        onPress: () async {
                                          try {
                                            await _getGroupDetails(e);
                                            appController.setCurrentPage(
                                                8, true, 3);
                                          } on HttpException catch (e, s) {
                                            final user =
                                                Provider.of<UserProviderV2>(
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
                                                Provider.of<UserProviderV2>(
                                                        context,
                                                        listen: false)
                                                    .currentUser;
                                            BeStilDialog.showErrorDialog(
                                                context,
                                                StringUtils.getErrorMessage(e),
                                                user,
                                                s);
                                          }
                                        },
                                        text: e.name ?? '',
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
                                            : null,
                                        onPressMore: () => showModalBottomSheet(
                                          context: context,
                                          barrierColor:
                                              Provider.of<ThemeProviderV2>(
                                                          context,
                                                          listen: false)
                                                      .isDarkModeEnabled
                                                  ? AppColors.backgroundColor[0]
                                                      .withOpacity(0.8)
                                                  : Color(0xFF021D3C)
                                                      .withOpacity(0.7),
                                          backgroundColor:
                                              Provider.of<ThemeProviderV2>(
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
