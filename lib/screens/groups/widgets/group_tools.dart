import 'dart:io';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupTools extends StatefulWidget {
  final CombineGroupUserStream groupData;
  // final setCurrentIndex;
  GroupTools(
    this.groupData,
    // this.setCurrentIndex,
  );

  @override
  _GroupToolsState createState() => _GroupToolsState();
}

class _GroupToolsState extends State<GroupTools> {
  Future<void> onEditTap(CombineGroupUserStream groupData) async {
    try {
      AppController appController = Get.find();
      appController.setCurrentPage(12, true, 3);
      Provider.of<GroupProvider>(context, listen: false).setEditMode(true);
      await Provider.of<GroupProvider>(context, listen: false)
          .setCurrentGroup(groupData);
      Navigator.pop(context);
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

  leaveGroup(CombineGroupUserStream data) async {
    BeStilDialog.showLoading(context);
    try {
      final _currentUser =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      final id = (data.groupUsers ?? [])
          .firstWhere((e) => e.userId == _currentUser.id,
              orElse: () => GroupUserModel.defaultValue())
          .id;

      if ((id ?? '').isNotEmpty) {
        var admin = (data.groupUsers ?? []).firstWhere(
            (element) => element.role == GroupUserRole.admin,
            orElse: () => GroupUserModel.defaultValue());

        var followedPrayers =
            Provider.of<GroupPrayerProvider>(context, listen: false)
                .followedPrayers
                .where((element) =>
                    element.groupId == data.group?.id &&
                    element.userId == _currentUser.id);
        followedPrayers.forEach((element) async {
          await Provider.of<GroupPrayerProvider>(context, listen: false)
              .removeFromMyList(element.id ?? '', element.userPrayerId ?? '');
        });
        await Provider.of<GroupProvider>(context, listen: false)
            .leaveGroup(id ?? '');

        final userName =
            '${(_currentUser.firstName ?? '').capitalizeFirst} ${(_currentUser.lastName ?? '').capitalizeFirst}';
        if (admin.id != '') {
          await Provider.of<UserProvider>(context, listen: false)
              .getUserById(admin.userId ?? '');
          // await Future.delayed(Duration(milliseconds: 500));
          final adminData =
              Provider.of<UserProvider>(context, listen: false).selectedUser;
          await sendPushNotification(
              '$userName has left this group',
              NotificationType.leave_group,
              userName,
              _currentUser.id ?? '',
              adminData.id ?? '',
              'A member has left your group',
              data.group?.id ?? '',
              [adminData.pushToken ?? '']);
        }

        BeStilDialog.hideLoading(context);
        AppController appController = Get.find();
        appController.setCurrentPage(3, true, 3);
        // await Provider.of<GroupProvider>(context, listen: false)
        //     .setUserGroups(_currentUser.id ?? '');
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  sendPushNotification(
      String message,
      String messageType,
      String sender,
      String senderId,
      String receiverId,
      String title,
      String entityId,
      List<String> tokens) async {
    try {
      await Provider.of<NotificationProvider>(context, listen: false)
          .sendPushNotification(message, messageType, sender, senderId,
              receiverId, title, '', entityId, tokens);
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

  void _openDeleteConfirmation(BuildContext context, String message,
      String method, String title, CombineGroupUserStream data) {
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
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

    var currentGroupUser = (widget.groupData.groupUsers ?? [])
        .firstWhere((element) => element.userId == _user.id);
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
                        onPress: () => onEditTap(widget.groupData),
                        text: "Edit Group",
                        backgroundColor:
                            AppColors.groupActionBgColor.withOpacity(0.9),
                        textColor: AppColors.addprayerTextColor,
                        onPressMore: () => null,
                      )
                    : Container(),

                SizedBox(height: 10),
                LongButton(
                  icon: Icons.add,
                  onPress: () async {
                    try {
                      Provider.of<PrayerProvider>(context, listen: false)
                          .setEditMode(false, true);
                      await Provider.of<GroupProvider>(context, listen: false)
                          .setCurrentGroupById(
                              widget.groupData.group?.id ?? '', _user.id ?? '');
                      AppController appController = Get.find();
                      appController.setCurrentPage(1, true, 3);
                      Navigator.pop(context);
                    } on HttpException catch (e, s) {
                      BeStilDialog.showErrorDialog(
                          context, StringUtils.getErrorMessage(e), _user, s);
                    } catch (e, s) {
                      BeStilDialog.showErrorDialog(
                          context, StringUtils.errorOccured, _user, s);
                    }
                  },
                  text: "Add a Prayer",
                  backgroundColor:
                      AppColors.groupActionBgColor.withOpacity(0.9),
                  textColor: AppColors.addprayerTextColor,
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
                  textColor: AppColors.addprayerTextColor,
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
                          _openDeleteConfirmation(context, message, method,
                              title, widget.groupData);
                        },
                        text: "Leave Group",
                        backgroundColor:
                            AppColors.groupActionBgColor.withOpacity(0.9),
                        textColor: AppColors.addprayerTextColor,
                        onPressMore: () => null,
                      )
                    : Container(),
                // SizedBox(height: 10),
                // LongButton(
                //   icon: Icons.share,
                //   onPress: null,
                //   text: "Invite - Email",
                //   backgroundColor: Settings.isDarkMode
                //       ? AppColors.backgroundColor[0]
                //       : Colors.white,
                //   textColor: AppColors.lightBlue3,
                //   onPressMore: () => null,
                // ),
                // SizedBox(height: 10),
                // LongButton(
                //   icon: Icons.share,
                //   onPress: null,
                //   text: "Invite - Text",
                //   backgroundColor: Settings.isDarkMode
                //       ? AppColors.backgroundColor[0]
                //       : Colors.white,
                //   textColor: AppColors.lightBlue3,
                //   onPressMore: () => null,
                // ),
                // SizedBox(height: 10),
                // LongButton(
                //   icon: Icons.share,
                //   onPress: null,
                //   text: "Invite - QR Code",
                //   backgroundColor: Settings.isDarkMode
                //       ? AppColors.backgroundColor[0]
                //       : Colors.white,
                //   textColor: AppColors.lightBlue3,
                //   onPressMore: () => null,
                // ),
                SizedBox(height: 60),
              ],
            ),
          )
        ]));
  }
}
