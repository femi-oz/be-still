import 'dart:io';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupTools extends StatefulWidget {
  final GroupDataModel group;
  // final setCurrentIndex;
  GroupTools(
    this.group,
    // this.setCurrentIndex,
  );

  @override
  _GroupToolsState createState() => _GroupToolsState();
}

class _GroupToolsState extends State<GroupTools> {
  Future<void> onEditTap(GroupDataModel groupData) async {
    try {
      AppController appController = Get.find();
      Provider.of<GroupProviderV2>(context, listen: false).setEditMode(true);
      await Provider.of<GroupProviderV2>(context, listen: false)
          .setCurrentGroupById(groupData.id ?? '');
      appController.setCurrentPage(12, true, 3);
      Navigator.pop(context);
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

  leaveGroup(GroupDataModel group) async {
    BeStilDialog.showLoading(context);
    try {
      final _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final _user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;

      await Provider.of<GroupProviderV2>(context, listen: false)
          .leaveGroup(group.id ?? '');

      final userName =
          '${(_user.firstName ?? '').capitalizeFirst} ${(_user.lastName ?? '').capitalizeFirst}';

      final admin = (group.users ?? []).firstWhere(
          (element) => element.role == GroupUserRole.admin,
          orElse: () => GroupUserDataModel());

      final adminData =
          await Provider.of<UserProviderV2>(context, listen: false)
              .getUserDataById(admin.userId ?? '');

      await sendPushNotification(
          '$userName has left this group',
          NotificationType.leave_group,
          userName,
          _userId,
          adminData.id ?? '',
          'A member has left your group',
          group.id ?? '', []);

      BeStilDialog.hideLoading(context);
      AppController appController = Get.find();
      appController.setCurrentPage(3, true, 3);

      Navigator.pop(context);
      Navigator.pop(context);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  Future<void> sendPushNotification(
      String message,
      String messageType,
      String sender,
      String senderId,
      String receiverId,
      String title,
      String entityId,
      List<String> tokens) async {
    try {
      await Provider.of<NotificationProviderV2>(context, listen: false)
          .sendPushNotification(message, messageType, sender, tokens,
              receiverId: receiverId, groupId: entityId);
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

  void _openDeleteConfirmation(BuildContext context, String message,
      String method, String title, GroupDataModel data) {
    final dialog = AlertDialog(
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
              margin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue1,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            ),
            Flexible(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regularText16b
                      .copyWith(color: AppColors.lightBlue4),
                ),
              ),
            ),
            SizedBox(
              height: 20,
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
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * .24,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.5),
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
                            'CANCEL',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      leaveGroup(data);
                    },
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * .24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
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
                            method,
                            style: TextStyle(
                              color: AppColors.white,
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
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    final currentGroupUser = (widget.group.users ?? []).firstWhere(
        (element) => element.userId == FirebaseAuth.instance.currentUser?.uid);
    return Container(
        padding: EdgeInsets.only(left: 40),
        height: double.infinity,
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
          SizedBox(height: 80),
          Row(
            children: [
              TextButton.icon(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.zero),
                ),
                icon: Icon(
                  AppIcons.bestill_back_arrow,
                  color: AppColors.lightBlue4,
                ),
                onPressed: () => Navigator.pop(context),
                label: Text(
                  'BACK',
                  style: AppTextStyles.boldText20.copyWith(
                    color: AppColors.prayerPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                currentGroupUser.role == GroupUserRole.admin
                    ? LongButton(
                        icon: Icons.edit,
                        onPress: () => onEditTap(widget.group),
                        text: "Edit Group",
                        backgroundColor:
                            AppColors.groupActionBgColor.withOpacity(0.9),
                        textColor: AppColors.addPrayerTextColor,
                        onPressMore: () => null,
                      )
                    : Container(),
                SizedBox(height: 10),
                LongButton(
                  icon: Icons.add,
                  onPress: () async {
                    try {
                      Provider.of<PrayerProviderV2>(context, listen: false)
                          .setEditMode(false, true);
                      await Provider.of<GroupProviderV2>(context, listen: false)
                          .setCurrentGroupById(widget.group.id ?? '');
                      AppController appController = Get.find();
                      appController.setCurrentPage(1, true, 3);
                      Navigator.pop(context);
                    } on HttpException catch (e, s) {
                      final user =
                          Provider.of<UserProviderV2>(context, listen: false)
                              .currentUser;
                      BeStilDialog.showErrorDialog(
                          context, StringUtils.getErrorMessage(e), user, s);
                    } catch (e, s) {
                      final user =
                          Provider.of<UserProviderV2>(context, listen: false)
                              .currentUser;
                      BeStilDialog.showErrorDialog(
                          context, StringUtils.getErrorMessage(e), user, s);
                    }
                  },
                  text: "Add a Prayer",
                  backgroundColor:
                      AppColors.groupActionBgColor.withOpacity(0.9),
                  textColor: AppColors.addPrayerTextColor,
                  onPressMore: () => null,
                ),
                SizedBox(height: 10),
                LongButton(
                  icon: Icons.more_vert,
                  onPress: () {
                    AppController appController = Get.find();
                    appController.setCurrentPage(4, true, 3);
                    appController.settingsTab = 4;
                    Navigator.pop(context);
                  },
                  text: "Manage Settings",
                  backgroundColor:
                      AppColors.groupActionBgColor.withOpacity(0.9),
                  textColor: AppColors.addPrayerTextColor,
                  onPressMore: () => null,
                ),
                SizedBox(height: 10),
                currentGroupUser.role != GroupUserRole.admin
                    ? LongButton(
                        icon: Icons.exit_to_app,
                        onPress: () {
                          const message =
                              'Are you sure you want to leave this group?';
                          const method = 'LEAVE';
                          const title = 'Leave Group';
                          _openDeleteConfirmation(
                              context, message, method, title, widget.group);
                        },
                        text: "Leave Group",
                        backgroundColor:
                            AppColors.groupActionBgColor.withOpacity(0.9),
                        textColor: AppColors.addPrayerTextColor,
                        onPressMore: () => null,
                      )
                    : Container(),
                SizedBox(height: 60),
              ],
            ),
          )
        ]));
  }
}
