import 'dart:io';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/group_prayer_card.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupPrayers extends StatefulWidget {
  final Function switchSearchMode;
  final bool isSearchMode;
  GroupPrayers(
    this.switchSearchMode,
    this.isSearchMode,
  );
  @override
  _GroupPrayersState createState() => _GroupPrayersState();
}

class _GroupPrayersState extends State<GroupPrayers> {
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
      final _userId = FirebaseAuth.instance.currentUser?.uid;

      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        try {
          final group =
              Provider.of<GroupProviderV2>(context, listen: false).currentGroup;
          await Provider.of<MiscProviderV2>(context, listen: false)
              .setPageTitle((group.name ?? '').toUpperCase());
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

  String get message {
    final filterOption = Provider.of<PrayerProviderV2>(context).filterOption;

    if (filterOption.toLowerCase() == Status.active.toLowerCase()) {
      return 'You do not have any active prayers.';
    } else if (filterOption.toLowerCase() == Status.answered.toLowerCase()) {
      return 'You do not have any answered prayers.';
    } else if (filterOption.toLowerCase() == Status.archived.toLowerCase()) {
      return 'You do not have any archived prayers.';
    } else if (filterOption.toLowerCase() == Status.snoozed.toLowerCase()) {
      return 'You do not have any snoozed prayers.';
    } else {
      return 'You do not have any active prayers.';
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<PrayerProviderV2>(context).filteredGroupPrayers;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          isGroup: true,
          showPrayerActions: true,
          isSearchMode: widget.isSearchMode,
          switchSearchMode: (bool val) => widget.switchSearchMode(val),
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
          child: Container(
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
                                          Provider.of<PrayerProviderV2>(context,
                                                  listen: false)
                                              .setCurrentPrayerId(e.id ?? '');
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
                                      child: GroupPrayerCard(
                                        prayerData: e,
                                        timeago: '',
                                      )))
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
                          Provider.of<PrayerProviderV2>(context, listen: false)
                              .setEditMode(false, true);

                          AppController appController = Get.find();
                          appController.setCurrentPage(1, true, 8);
                        } on HttpException catch (e, s) {
                          final user = Provider.of<UserProviderV2>(context,
                                  listen: false)
                              .currentUser;
                          BeStilDialog.showErrorDialog(
                              context, StringUtils.getErrorMessage(e), user, s);
                        } catch (e, s) {
                          final user = Provider.of<UserProviderV2>(context,
                                  listen: false)
                              .currentUser;
                          BeStilDialog.showErrorDialog(
                              context, StringUtils.getErrorMessage(e), user, s);
                        }
                      },
                      text: 'Add New Prayer',
                      backgroundColor: Settings.isDarkMode
                          ? AppColors.backgroundColor[1]
                          : AppColors.lightBlue3,
                      textColor: Settings.isDarkMode
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
          ),
        ),
      ),
    );
  }
}
