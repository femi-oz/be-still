import 'dart:io';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/theme_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/group_prayer_card.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupPrayers extends StatefulWidget {
  final GlobalKey<State<StatefulWidget>> keyButton;

  final Function switchSearchMode;
  final bool isSearchMode;
  GroupPrayers(this.switchSearchMode, this.isSearchMode, this.keyButton);
  @override
  _GroupPrayersState createState() => _GroupPrayersState();
}

class _GroupPrayersState extends State<GroupPrayers> {
  bool userIsMember = true;

  Future<bool> _onWillPop() async {
    // return (Navigator.of(context).pushNamedAndRemoveUntil(
    //         EntryScreen.routeName, (Route<dynamic> route) => false)) ??
    //     false;
    return false;
  }

  bool _isInit = true;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final group =
              Provider.of<GroupProviderV2>(context, listen: false).currentGroup;
          Provider.of<PrayerProviderV2>(context, listen: false)
              .setGroupPrayers();
          await Provider.of<MiscProviderV2>(context, listen: false)
              .setPageTitle((group.name ?? '').toUpperCase());
          AppController appController = Get.find();
          if (appController.previousPage != 9) {
            await Provider.of<MiscProviderV2>(context, listen: false)
                .setSearchMode(false);
            await Provider.of<MiscProviderV2>(context, listen: false)
                .setSearchQuery('');
            await Provider.of<PrayerProviderV2>(context, listen: false)
                .searchGroupPrayers(
                    '', FirebaseAuth.instance.currentUser?.uid ?? '');
          }
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
      });

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    // if (!Settings.hasCreatedGroupPrayer)
    //   Future.delayed(Duration(milliseconds: 300), () {
    //     TutorialTargetGroup().showTutorial(context, widget.keyButton);
    //   });
  }

  onDispose() {}

  String get message {
    final filterOption =
        Provider.of<PrayerProviderV2>(context).groupFilterOption;
    if (filterOption.toLowerCase() == Status.active.toLowerCase()) {
      return 'You do not have any active prayers.';
    } else if (filterOption.toLowerCase() == Status.answered.toLowerCase()) {
      return 'You do not have any answered prayers.';
    } else if (filterOption.toLowerCase() == Status.archived.toLowerCase()) {
      return 'You do not have any archived prayers.';
    } else if (filterOption.toLowerCase() == Status.snoozed.toLowerCase()) {
      return 'You do not have any snoozed prayers.';
    } else {
      return 'You do not have any prayers.';
    }
  }

  Widget accessDeniedContainer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 60),
      child: Column(
        children: [
          Opacity(
            opacity: 0.3,
            child: Text(
              'You are no longer a member of this group.',
              style: AppTextStyles.demiboldText34,
              textAlign: TextAlign.center,
            ),
          ).marginOnly(bottom: 50),
          Container(
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: AppColors.lightBlue4,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: OutlinedButton(
              onPressed: () {
                AppController appController = Get.find();
                appController.setCurrentPage(3, true, 8);
              },
              style: ButtonStyle(
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(color: Colors.transparent)),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  'Go to groups',
                  style: TextStyle(
                    color: AppColors.lightBlue4,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ).paddingSymmetric(horizontal: 10, vertical: 5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  isUserMember() async {
    final group =
        Provider.of<GroupProviderV2>(context, listen: false).currentGroup;
    userIsMember = await Provider.of<GroupProviderV2>(context, listen: false)
        .userIsGroupMember(group.id);
  }

  @override
  Widget build(BuildContext context) {
    isUserMember();
    final data = Provider.of<PrayerProviderV2>(context).filteredGroupPrayers;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          isGroup: true,
          showPrayerActions: true,
          isSearchMode: widget.isSearchMode,
          switchSearchMode: (bool val) => widget.switchSearchMode(val),
          searchGlobalKey: widget.keyButton,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height * 1,
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
          child: userIsMember
              ? Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        data.length == 0
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 60, vertical: 60),
                                child: Opacity(
                                  opacity: 0.3,
                                  child: Text(
                                    message,
                                    style: AppTextStyles.demiboldText34,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.only(left: 20),
                                child: Column(
                                  children: <Widget>[
                                    ...data
                                        .map((e) => GestureDetector(
                                            onTap: () async {
                                              try {
                                                Provider.of<PrayerProviderV2>(
                                                        context,
                                                        listen: false)
                                                    .setCurrentPrayerId(
                                                        e.id ?? '');
                                                AppController appController =
                                                    Get.find();
                                                appController.setCurrentPage(
                                                    9, true, 8);
                                              } on HttpException catch (e, s) {
                                                final user =
                                                    Provider.of<UserProviderV2>(
                                                            context,
                                                            listen: false)
                                                        .currentUser;
                                                BeStilDialog.showErrorDialog(
                                                    context,
                                                    StringUtils.getErrorMessage(
                                                        e),
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
                                                    StringUtils.getErrorMessage(
                                                        e),
                                                    user,
                                                    s);
                                              }
                                            },
                                            child: GroupPrayerCard(
                                                prayerData: e, timeago: '')))
                                        .toList(),
                                  ],
                                ),
                              ),
                        // currentPrayerType == Status.archived ||
                        //         currentPrayerType == Status.answered
                        //     ? Container()
                        //     :
                        // groupUser.role == GroupUserRole.admin
                        //     ?
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: LongButton(
                            onPress: () {
                              try {
                                Provider.of<PrayerProviderV2>(context,
                                        listen: false)
                                    .setEditMode(false, true);

                                AppController appController = Get.find();
                                appController.setCurrentPage(1, true, 8);
                              } on HttpException catch (e, s) {
                                final user = Provider.of<UserProviderV2>(
                                        context,
                                        listen: false)
                                    .currentUser;
                                BeStilDialog.showErrorDialog(context,
                                    StringUtils.getErrorMessage(e), user, s);
                              } catch (e, s) {
                                final user = Provider.of<UserProviderV2>(
                                        context,
                                        listen: false)
                                    .currentUser;
                                BeStilDialog.showErrorDialog(context,
                                    StringUtils.getErrorMessage(e), user, s);
                              }
                            },
                            text: 'Add New Prayer',
                            backgroundColor:
                                Provider.of<ThemeProviderV2>(context)
                                        .isDarkModeEnabled
                                    ? AppColors.backgroundColor[1]
                                    : AppColors.lightBlue3,
                            textColor: Provider.of<ThemeProviderV2>(context)
                                    .isDarkModeEnabled
                                ? AppColors.lightBlue3
                                : Colors.white,
                            icon: AppIcons.bestill_add,
                          ),
                        ),
                        // : Container(),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                )
              : accessDeniedContainer(),
        ),
      ),
    );
  }
}
