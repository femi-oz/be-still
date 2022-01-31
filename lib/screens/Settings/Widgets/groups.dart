import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/group_settings_model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/settings_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:be_still/widgets/custom_expansion_tile.dart' as custom;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupsSettings extends StatefulWidget {
  @override
  _GroupsSettingsState createState() => _GroupsSettingsState();
}

class _GroupsSettingsState extends State<GroupsSettings> {
  final f = new DateFormat('yyyy-MM-dd');
  late FirebaseMessaging messaging;

  _removeUserFromGroup(
      GroupUserModel user, CombineGroupUserStream group) async {
    try {
      final message = 'You have removed the user from your group';

      BeStilDialog.showLoading(context);
      await Provider.of<GroupProvider>(context, listen: false)
          .deleteFromGroup(user.userId ?? "", user.groupId ?? "");

      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      Navigator.pop(context);
      BeStilDialog.showSuccessDialog(context, message);
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
    try {
      Navigator.pop(context);
      BeStilDialog.showLoading(context, '');
      final _currentUser =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      final id = (data.groupUsers ?? [])
          .firstWhere((e) => e.userId == _currentUser.id,
              orElse: () => GroupUserModel.defaultValue())
          .id;

      var receiver = (data.groupUsers ?? [])
          .firstWhere((element) => element.role == GroupUserRole.admin);

      await Provider.of<UserProvider>(context, listen: false)
          .getUserById(receiver.userId ?? '');
      await Future.delayed(Duration(milliseconds: 500));
      final receiverData =
          Provider.of<UserProvider>(context, listen: false).selectedUser;
      var followedPrayers =
          Provider.of<GroupPrayerProvider>(context, listen: false)
              .followedPrayers
              .where((element) =>
                  element.groupId == data.group?.id &&
                  element.userId == _currentUser.id);
      if (followedPrayers.length > 0) {
        for (var followedPrayer in followedPrayers) {
          await Provider.of<GroupPrayerProvider>(context, listen: false)
              .removeFromMyList(
                  followedPrayer.id ?? '', followedPrayer.userPrayerId ?? '');
        }
      }
      await Provider.of<GroupProvider>(context, listen: false)
          .leaveGroup(id ?? "");

      await sendPushNotification(
          '${(_currentUser.firstName ?? '').capitalizeFirst} ${(_currentUser.lastName ?? '').capitalizeFirst} has left your group ${data.group?.name}',
          NotificationType.leave_group,
          _currentUser.firstName ?? '',
          _currentUser.id ?? '',
          receiver.userId ?? '',
          'Groups',
          data.group?.id ?? '',
          [receiverData.pushToken ?? '']);
      // Provider.of<GroupProvider>(context, listen: false)
      //     .setUserGroups(_currentUser.id ?? '');
      BeStilDialog.hideLoading(context);
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

  deleteGroup(CombineGroupUserStream data) async {
    try {
      BeStilDialog.showLoading(context, '');
      final notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .notifications;

      final requests =
          notifications.where((e) => e.groupId == data.group?.id).toList();

      await Provider.of<GroupProvider>(context, listen: false)
          .deleteGroup(data.group?.id ?? '', requests);
      var followedPrayers =
          Provider.of<GroupPrayerProvider>(context, listen: false)
              .followedPrayers
              .where((element) => element.groupId == data.group?.id);
      followedPrayers.forEach((element) async {
        await Provider.of<GroupPrayerProvider>(context, listen: false)
            .removeFromMyList(element.id ?? '', element.userPrayerId ?? '');
      });
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.pop(context);
      BeStilDialog.hideLoading(context);
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

  Future<void> acceptRequest(
      GroupRequestModel request, GroupModel group) async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .getUserById(request.userId ?? ''); //sender

      Future.delayed(Duration(seconds: 5), () async {
        final receiverFullName =
            '${Provider.of<UserProvider>(context, listen: false).selectedUser.firstName ?? '' + ' ' + (Provider.of<UserProvider>(context, listen: false).selectedUser.lastName ?? '')}';

        final sender =
            Provider.of<UserProvider>(context, listen: false).currentUser;

        await Provider.of<GroupProvider>(context, listen: false).acceptRequest(
            request.groupId ?? '',
            request.userId ?? '',
            request.id ?? '',
            receiverFullName);

        final receiverData =
            Provider.of<UserProvider>(context, listen: false).selectedUser;
        await Provider.of<NotificationProvider>(context, listen: false)
            .sendPushNotification(
                'Your request to join this group has been accepted',
                NotificationType.accept_request,
                sender.firstName ?? '',
                sender.id ?? '',
                request.userId ?? '',
                'Request Accepted',
                '',
                group.id ?? '',
                [receiverData.pushToken ?? '']);
        final notifications =
            Provider.of<NotificationProvider>(context, listen: false)
                .notifications
                .where((e) =>
                    e.messageType == NotificationType.request &&
                    e.prayerId == request.groupId)
                .toList();
        //notifcations where groupId= && type==request
        // for
        for (final not in notifications) {
          await Provider.of<NotificationProvider>(context, listen: false)
              .updateNotification(not.id ?? '');
        }

        // Navigator.of(context).pop();
        BeStilDialog.hideLoading(context);
      });
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

  void _showAlert(GroupUserModel user, CombineGroupUserStream group) async {
    bool userIsAdmin = false;
    UserModel userData = UserModel.defaultValue();
    try {
      final _currentUser =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      userIsAdmin =
          user.userId == _currentUser.id && user.role == GroupUserRole.admin
              ? true
              : false;

      userData = Provider.of<UserProvider>(context, listen: false).selectedUser;
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }

    setState(() {});

    AlertDialog dialog = AlertDialog(
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
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(AppIcons.bestill_close),
                  )
                ],
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        ('${userData.firstName} ${userData.lastName}')
                            .toUpperCase(),
                        style: TextStyle(
                            color: AppColors.lightBlue3,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 10.0),
                      //   child: Text(
                      //     user.email ?? '',
                      //     style: TextStyle(
                      //         color: AppColors.textFieldText,
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.w300,
                      //         height: 1.5),
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // ),
                      // Text(
                      //   'might be from Houston, TX',
                      //   style: TextStyle(
                      //       color: AppColors.textFieldText,
                      //       fontSize: 12,
                      //       fontWeight: FontWeight.w300,
                      //       height: 1.5),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                        child: Text(
                          'Has been a member since ${f.format(user.createdOn ?? DateTime.now())}',
                          style: TextStyle(
                              color: AppColors.textFieldText,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Container(
                      //   margin: const EdgeInsets.symmetric(
                      //       horizontal: 20.0, vertical: 40.0),
                      //   height: 30,
                      //   width: MediaQuery.of(context).size.width * 0.4,
                      //   decoration: BoxDecoration(
                      //     // color: sortBy == 'date'
                      //     //     ? context.toolsActiveBtn.withOpacity(0.3)
                      //     //     :
                      //     color: Colors.transparent,
                      //     border: Border.all(
                      //       color: AppColors.darkBlue,
                      //       width: 1,
                      //     ),
                      //     borderRadius: BorderRadius.circular(5),
                      //   ),
                      //   child: OutlinedButton(
                      //     style: ButtonStyle(
                      //       side: MaterialStateProperty.all<BorderSide>(
                      //           BorderSide(color: Colors.transparent)),
                      //     ),
                      //     child: Container(
                      //       child: Text(
                      //         'MESSAGE',
                      //         style: TextStyle(
                      //             color: AppColors.lightBlue3,
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w500),
                      //       ),
                      //     ),
                      //     onPressed: () {
                      //       setState(() {
                      //         // sortBy = 'date';
                      //       });
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: <Widget>[
                      //       Container(
                      //         margin: EdgeInsets.symmetric(vertical: 5),
                      //         height: 30,
                      //         width: MediaQuery.of(context).size.width * 0.4,
                      //         decoration: BoxDecoration(
                      //           color: user.role == GroupUserRole.admin
                      //               ? AppColors.activeButton.withOpacity(0.3)
                      //               : Colors.transparent,
                      //           border: Border.all(
                      //             color: AppColors.darkBlue,
                      //             width: 1,
                      //           ),
                      //           borderRadius: BorderRadius.circular(5),
                      //         ),
                      //         child: FittedBox(
                      //           child: OutlinedButton(
                      //             style: ButtonStyle(
                      //               side: MaterialStateProperty.all<BorderSide>(
                      //                   BorderSide(color: Colors.transparent)),
                      //             ),
                      //             child: Container(
                      //               child: Text(
                      //                 'ADMIN',
                      //                 style: TextStyle(
                      //                     color: AppColors.lightBlue3,
                      //                     fontSize: 20,
                      //                     fontWeight: FontWeight.w500),
                      //               ),
                      //             ),
                      //             onPressed: () {
                      //               showModalBottomSheet(
                      //                 context: context,
                      //                 barrierColor: AppColors
                      //                     .detailBackgroundColor[1]
                      //                     .withOpacity(0.5),
                      //                 backgroundColor: AppColors
                      //                     .detailBackgroundColor[1]
                      //                     .withOpacity(0.9),
                      //                 isScrollControlled: true,
                      //                 builder: (BuildContext context) {
                      //                   return GroupPrivilegeSettings(
                      //                       'admin', user);
                      //                 },
                      //               );
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //       Container(
                      //         height: 30,
                      //         margin: EdgeInsets.symmetric(vertical: 5),
                      //         width: MediaQuery.of(context).size.width * 0.4,
                      //         decoration: BoxDecoration(
                      //           color: user.role == GroupUserRole.moderator
                      //               ? AppColors.activeButton.withOpacity(0.3)
                      //               : Colors.transparent,
                      //           border: Border.all(
                      //             color: AppColors.darkBlue,
                      //             width: 1,
                      //           ),
                      //           borderRadius: BorderRadius.circular(5),
                      //         ),
                      //         child: FittedBox(
                      //           child: OutlinedButton(
                      //             style: ButtonStyle(
                      //               side: MaterialStateProperty.all<BorderSide>(
                      //                   BorderSide(color: Colors.transparent)),
                      //             ),
                      //             child: Container(
                      //               child: Text(
                      //                 'MODERATOR',
                      //                 style: TextStyle(
                      //                     color: AppColors.lightBlue3,
                      //                     fontSize: 20,
                      //                     fontWeight: FontWeight.w500),
                      //               ),
                      //             ),
                      //             onPressed: () {
                      //               showModalBottomSheet(
                      //                 context: context,
                      //                 barrierColor: AppColors
                      //                     .detailBackgroundColor[1]
                      //                     .withOpacity(0.5),
                      //                 backgroundColor: AppColors
                      //                     .detailBackgroundColor[1]
                      //                     .withOpacity(0.9),
                      //                 isScrollControlled: true,
                      //                 builder: (BuildContext context) {
                      //                   return GroupPrivilegeSettings(
                      //                       'moderator', user);
                      //                 },
                      //               );
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //       Container(
                      //         height: 30,
                      //         margin: EdgeInsets.symmetric(vertical: 5),
                      //         width: MediaQuery.of(context).size.width * 0.4,
                      //         decoration: BoxDecoration(
                      //           color: user.role == GroupUserRole.member
                      //               ? AppColors.activeButton.withOpacity(0.3)
                      //               : Colors.transparent,
                      //           border: Border.all(
                      //             color: AppColors.darkBlue,
                      //             width: 1,
                      //           ),
                      //           borderRadius: BorderRadius.circular(5),
                      //         ),
                      //         child: FittedBox(
                      //           child: OutlinedButton(
                      //             style: ButtonStyle(
                      //               side: MaterialStateProperty.all<BorderSide>(
                      //                   BorderSide(color: Colors.transparent)),
                      //             ),
                      //             child: Container(
                      //               child: Text(
                      //                 'MEMBER',
                      //                 style: TextStyle(
                      //                     color: AppColors.lightBlue3,
                      //                     fontSize: 20,
                      //                     fontWeight: FontWeight.w500),
                      //               ),
                      //             ),
                      //             onPressed: () {
                      //               showModalBottomSheet(
                      //                 context: context,
                      //                 barrierColor: AppColors
                      //                     .detailBackgroundColor[1]
                      //                     .withOpacity(0.5),
                      //                 backgroundColor: AppColors
                      //                     .detailBackgroundColor[1]
                      //                     .withOpacity(0.9),
                      //                 isScrollControlled: true,
                      //                 builder: (BuildContext context) {
                      //                   return GroupPrivilegeSettings(
                      //                       'member', user);
                      //                 },
                      //               );
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      !userIsAdmin
                          ? Container(
                              height: 30,
                              margin: EdgeInsets.only(top: 20, bottom: 0),
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                // color: sortBy == 'date'
                                //     ? context.toolsActiveBtn.withOpacity(0.3)
                                //     :
                                color: Colors.transparent,
                                border: Border.all(
                                  color: AppColors.red,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: FittedBox(
                                child: OutlinedButton(
                                  style: ButtonStyle(
                                    side: MaterialStateProperty.all<BorderSide>(
                                        BorderSide(color: Colors.transparent)),
                                  ),
                                  child: Container(
                                    child: Text(
                                      'REMOVE',
                                      style: TextStyle(
                                          color: AppColors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  onPressed: () {
                                    const message =
                                        'Are you sure you want to remove this user from your group?';
                                    const method = 'REMOVE';
                                    const title = 'Remove From Group';
                                    _openRemoveConfirmation(context, title,
                                        method, message, user, group);
                                  },
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ).marginOnly(bottom: 10),
            Flexible(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regularText14
                      .copyWith(color: AppColors.lightBlue4),
                ),
              ),
            ),
            SizedBox(height: 20),
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
                      method == 'Delete' ? deleteGroup(data) : leaveGroup(data);
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
                            method.toUpperCase(),
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
        ).marginSymmetric(vertical: 30),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  void _openRemoveConfirmation(BuildContext context, String title,
      String method, String message, user, group) {
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
                      _removeUserFromGroup(user, group);
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

  bool _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  String getUser(CombineGroupUserStream data) {
    try {
      (data.groupUsers ?? []).forEach((element) {
        Provider.of<UserProvider>(context, listen: false)
            .getUserById(element.userId ?? '');
      });
      return Provider.of<UserProvider>(context, listen: false)
              .selectedUser
              .lastName ??
          '';
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
      return '';
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    final _groups = Provider.of<GroupProvider>(context).userGroups;
    final _settingsProvider = Provider.of<SettingsProvider>(context);
    final _groupProvider = Provider.of<GroupProvider>(context);
    final _groupPreferenceSettings =
        Provider.of<SettingsProvider>(context).groupPreferenceSettings;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundColor,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dropShadow,
                    offset: Offset(0.0, 1.0),
                    blurRadius: 6.0,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: AppColors.prayerMenu,
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                'Preferences',
                style: AppTextStyles.boldText24.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            CustomToggle(
              title: 'Enable Alerts from Groups?',
              onChange: (bool value) async {
                try {
                  _settingsProvider.updateGroupPrefenceSettings(
                      _currentUser.id ?? '',
                      key: 'EnableNotificationForAllGroups',
                      value: value,
                      settingsId: _groupPreferenceSettings.id ?? '');

                  if (value) {
                    messaging = FirebaseMessaging.instance;
                    messaging.getToken().then((value) => {
                          Provider.of<NotificationProvider>(context,
                                  listen: false)
                              .enablePushNotifications(value ?? '',
                                  _currentUser.id ?? '', _currentUser)
                        });
                  } else {
                    await Provider.of<NotificationProvider>(context,
                            listen: false)
                        .disablePushNotifications(
                            _currentUser.id ?? '', _currentUser);
                  }
                } on HttpException catch (e, s) {
                  BeStilDialog.hideLoading(context);

                  final user = Provider.of<UserProvider>(context, listen: false)
                      .currentUser;
                  BeStilDialog.showErrorDialog(
                      context, StringUtils.getErrorMessage(e), user, s);
                } catch (e, s) {
                  BeStilDialog.hideLoading(context);

                  final user = Provider.of<UserProvider>(context, listen: false)
                      .currentUser;
                  BeStilDialog.showErrorDialog(
                      context, StringUtils.errorOccured, user, s);
                }
              },
              value: _groupPreferenceSettings.enableNotificationForAllGroups ??
                  false,
            ),
            Column(
              children: <Widget>[
                ..._groups.map((CombineGroupUserStream data) {
                  bool isAdmin = (data.groupUsers ?? [])
                          .firstWhere((g) => g.userId == _currentUser.id)
                          .role ==
                      GroupUserRole.admin;
                  bool isModerator = (data.groupUsers ?? [])
                          .firstWhere((g) => g.userId == _currentUser.id)
                          .role ==
                      GroupUserRole.moderator;
                  bool isMember = (data.groupUsers ?? [])
                          .firstWhere((g) => g.userId == _currentUser.id)
                          .role ==
                      GroupUserRole.member;
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: custom.ExpansionTile(
                      iconColor: AppColors.lightBlue1,
                      headerBackgroundColorStart: AppColors.prayerMenu[0],
                      headerBackgroundColorEnd: AppColors.prayerMenu[1],
                      shadowColor: AppColors.dropShadow,
                      title: Container(
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.1),
                        child: Text(
                          data.group?.name ?? '',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.boldText24
                              .copyWith(color: Colors.white70),
                        ),
                      ),
                      initiallyExpanded: true,
                      children: <Widget>[
                        custom.ExpansionTile(
                            iconColor: AppColors.lightBlue1,
                            headerBackgroundColorStart: Colors.transparent,
                            headerBackgroundColorEnd: Colors.transparent,
                            shadowColor: Colors.transparent,
                            title: Row(
                              children: <Widget>[
                                SizedBox(width: 3),
                                Text('Group Info',
                                    style: AppTextStyles.regularText11),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.lightBlue1,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            initiallyExpanded: false,
                            children: <Widget>[
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.symmetric(horizontal: 20),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: <Widget>[
                              //       Text(
                              //           'To submit prayers to this group via email:',
                              //           style: AppTextStyles.regularText13
                              //               .copyWith(
                              //                   color: AppColors.textFieldText))
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 10,
                              // ),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.symmetric(horizontal: 30),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: <Widget>[
                              //       Text(
                              //         data.group.email.toString(),
                              //         style: AppTextStyles.regularText16b
                              //             .copyWith(
                              //                 color: AppColors.lightBlue3),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 30,
                              // ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Purpose',
                                      style: AppTextStyles.regularText11
                                          .copyWith(
                                              color: AppColors.lightBlue2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        ((data.group ??
                                                            GroupModel
                                                                .defaultValue())
                                                        .description ??
                                                    '')
                                                .isEmpty
                                            ? "-"
                                            : data.group?.description ?? '',
                                        style: AppTextStyles.regularText14
                                            .copyWith(
                                                color: AppColors.textFieldText),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('Church',
                                        style: AppTextStyles.regularText11
                                            .copyWith(
                                                color: AppColors.lightBlue2))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      ((data.group ?? GroupModel.defaultValue())
                                                      .description ??
                                                  '')
                                              .isEmpty
                                          ? "-"
                                          : data.group?.description ?? '',
                                      style: AppTextStyles.regularText16b
                                          .copyWith(
                                              color: AppColors.textFieldText),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Based in',
                                      style: AppTextStyles.regularText11
                                          .copyWith(
                                              color: AppColors.lightBlue2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        data.group?.location ?? '',
                                        style: AppTextStyles.regularText16b
                                            .copyWith(
                                                color: AppColors.textFieldText),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                isMember || isModerator ? 'I am a' : 'I am an',
                                style: AppTextStyles.regularText14
                                    .copyWith(color: AppColors.textFieldText),
                              ),
                              Text(
                                isAdmin
                                    ? 'ADMIN'
                                    : isModerator
                                        ? 'MODERATOR'
                                        : 'MEMBER',
                                style: AppTextStyles.boldText24
                                    .copyWith(color: AppColors.lightBlue1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 25),
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'My Notifications',
                                    style: AppTextStyles.regularText11
                                        .copyWith(color: AppColors.lightBlue1),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.darkBlue,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            if (isAdmin || isModerator)
                              CustomToggle(
                                title: 'Require admin approval to join group?',
                                onChange: (value) {
                                  if (!value) {
                                    final activeRequests =
                                        (data.groupRequests ?? [])
                                            .where((e) => e.status == '0')
                                            .toList();
                                    for (final req in activeRequests) {
                                      acceptRequest(
                                          req,
                                          data.group ??
                                              GroupModel.defaultValue());
                                    }
                                    // add each to group
                                    // send notification that they joined
                                  }
                                  _groupProvider.updateGroupSettings(
                                      _currentUser.id ?? '',
                                      key: SettingsKey.requireAdminApproval,
                                      value: value,
                                      settingsId: data.groupSettings?.id ?? '');
                                },
                                value:
                                    data.groupSettings?.requireAdminApproval ??
                                        false,
                              ),
                            SizedBox(height: 15),
                            CustomToggle(
                              disabled: false,
                              title:
                                  'Enable alerts for New Prayers for this group?',
                              onChange: (value) => _groupProvider
                                  .updateGroupSettings(_currentUser.id ?? '',
                                      key: 'EnableNotificationFormNewPrayers',
                                      value: value,
                                      settingsId: data.groupSettings?.id ?? ''),
                              value: (data.groupSettings ??
                                          GroupSettings.defaultValue())
                                      .enableNotificationFormNewPrayers ??
                                  false,
                            ),
                            CustomToggle(
                              disabled: false,
                              title:
                                  'Enable alerts for Prayer Updates for this group?',
                              onChange: (value) => _groupProvider
                                  .updateGroupSettings(_currentUser.id ?? '',
                                      key: 'EnableNotificationForUpdates',
                                      value: value,
                                      settingsId: data.groupSettings?.id ?? ''),
                              value: (data.groupSettings ??
                                          GroupSettings.defaultValue())
                                      .enableNotificationForUpdates ??
                                  false,
                            ),
                            // if (isMember)
                            //   CustomToggle(
                            //     disabled: true,
                            //     title:
                            //         'Notify me when new members joins this group',
                            //     onChange: (value) => _groupProvider
                            //         .updateGroupSettings(_currentUser.id ?? '',
                            //             key: 'NotifyWhenNewMemberJoins',
                            //             value: value,
                            //             settingsId:
                            //                 data.groupSettings?.id ?? ''),
                            //     value: (data.groupSettings ??
                            //                 GroupSettings.defaultValue())
                            //             .notifyWhenNewMemberJoins ??
                            //         false,
                            //   ),
                            // if (isAdmin || isModerator)
                            //   CustomToggle(
                            //     disabled: true,
                            //     title: 'Notify me of membership requests',
                            //     onChange: (value) => _groupProvider
                            //         .updateGroupSettings(_currentUser.id ?? '',
                            //             key: 'NotifyOfMembershipRequest',
                            //             value: value,
                            //             settingsId:
                            //                 data.groupSettings?.id ?? ''),
                            //     value: (data.groupSettings ??
                            //                 GroupSettings.defaultValue())
                            //             .notifyOfMembershipRequest ??
                            //         false,
                            //   ),
                            // if (isAdmin || isModerator)
                            //   CustomToggle(
                            //     disabled: true,
                            //     title: 'Notify me of flagged prayers',
                            //     onChange: (value) => _groupProvider
                            //         .updateGroupSettings(_currentUser.id ?? '',
                            //             key: 'NotifyMeofFlaggedPrayers',
                            //             value: value,
                            //             settingsId:
                            //                 data.groupSettings?.id ?? ''),
                            //     value: (data.groupSettings ??
                            //                 GroupSettings.defaultValue())
                            //             .notifyMeofFlaggedPrayers ??
                            //         false,
                            //   ),
                          ],
                        ),
                        // (isAdmin || isModerator)
                        //     ? Column(
                        //         children: [
                        //           Padding(
                        //             padding: const EdgeInsets.symmetric(
                        //                 horizontal: 20.0, vertical: 10.0),
                        //             child: Row(
                        //               children: <Widget>[
                        //                 Text('Invite',
                        //                     style: AppTextStyles.regularText11),
                        //                 SizedBox(width: 10),
                        //                 Expanded(
                        //                   child: Divider(
                        //                     color: AppColors.darkBlue,
                        //                     thickness: 1,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //           Column(
                        //             children: [
                        //               Container(
                        //                 padding: const EdgeInsets.symmetric(
                        //                     horizontal: 20.0),
                        //                 child: GestureDetector(
                        //                   onTap: () => setState(
                        //                       () => _inviteMode = true),
                        //                   child: Text(
                        //                     'Send an invite to join group',
                        //                     style: AppTextStyles.regularText16b
                        //                         .copyWith(
                        //                             color:
                        //                                 AppColors.lightBlue3),
                        //                   ),
                        //                 ),
                        //               ),
                        //               _inviteMode
                        //                   ? Padding(
                        //                       padding:
                        //                           const EdgeInsets.symmetric(
                        //                               vertical: 15.0,
                        //                               horizontal: 20.0),
                        //                       child: Column(
                        //                         children: [
                        //                           CustomInput(
                        //                             textkey: GlobalKey<
                        //                                 FormFieldState>(),
                        //                             label: 'Email Address',
                        //                             controller:
                        //                                 _emailController,
                        //                             isEmail: true,
                        //                             keyboardType: TextInputType
                        //                                 .emailAddress,
                        //                           ),
                        //                           Row(
                        //                             mainAxisAlignment:
                        //                                 MainAxisAlignment.end,
                        //                             children: [
                        //                               TextButton(
                        //                                   style: ButtonStyle(
                        //                                       textStyle: MaterialStateProperty.all<TextStyle>(
                        //                                           AppTextStyles
                        //                                               .boldText16
                        //                                               .copyWith(
                        //                                                   color: Colors
                        //                                                       .white)),
                        //                                       backgroundColor:
                        //                                           MaterialStateProperty.all<Color>(
                        //                                               Colors.grey[
                        //                                                   700])),
                        //                                   onPressed: () => setState(
                        //                                       () => _inviteMode = false),
                        //                                   child: Text('Cancel', style: AppTextStyles.regularText14)),
                        //                               SizedBox(width: 15),
                        //                               TextButton(
                        //                                   style: ButtonStyle(
                        //                                     textStyle: MaterialStateProperty.all<
                        //                                             TextStyle>(
                        //                                         AppTextStyles
                        //                                             .boldText16
                        //                                             .copyWith(
                        //                                                 color: Colors
                        //                                                     .white)),
                        //                                     backgroundColor:
                        //                                         MaterialStateProperty.all<
                        //                                                 Color>(
                        //                                             AppColors
                        //                                                 .dimBlue),
                        //                                   ),
                        //                                   onPressed: () =>
                        //                                       _sendInvite(
                        //                                           data.group
                        //                                               .name,
                        //                                           data.group
                        //                                               .id),
                        //                                   child: Text(
                        //                                     'Send Invite',
                        //                                     style: AppTextStyles
                        //                                         .regularText14,
                        //                                   )),
                        //                             ],
                        //                           )
                        //                         ],
                        //                       ),
                        //                     )
                        //                   : Container()
                        //             ],
                        //           )
                        //         ],
                        //       )
                        //     : Container(),
                        (isAdmin || isModerator)
                            ? custom.ExpansionTile(
                                iconColor: AppColors.lightBlue4,
                                headerBackgroundColorStart: Colors.transparent,
                                headerBackgroundColorEnd: Colors.transparent,
                                shadowColor: Colors.transparent,
                                title: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          'Members | ${(data.groupUsers ?? []).length}',
                                          style: AppTextStyles.regularText11),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Divider(
                                            color: AppColors.lightBlue1,
                                            thickness: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                initiallyExpanded: false,
                                // onExpansionChanged: (bool isExpanded) {
                                // },
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Column(
                                      children: <Widget>[
                                        ...?data.groupUsers?.map(
                                          (user) {
                                            return GestureDetector(
                                              onTap: () async {
                                                try {
                                                  await Provider.of<
                                                              UserProvider>(
                                                          context,
                                                          listen: false)
                                                      .getUserById(
                                                          user.userId ?? '');
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 15),
                                                      () {
                                                    _showAlert(user, data);
                                                  });
                                                } on HttpException catch (e, s) {
                                                  BeStilDialog.hideLoading(
                                                      context);

                                                  final user =
                                                      Provider.of<UserProvider>(
                                                              context,
                                                              listen: false)
                                                          .currentUser;
                                                  BeStilDialog.showErrorDialog(
                                                      context,
                                                      StringUtils
                                                          .getErrorMessage(e),
                                                      user,
                                                      s);
                                                } catch (e, s) {
                                                  BeStilDialog.hideLoading(
                                                      context);

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
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 7.0),
                                                decoration: BoxDecoration(
                                                  color: AppColors.cardBorder,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    topLeft:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                                child: Container(
                                                  margin: EdgeInsetsDirectional
                                                      .only(
                                                          start: 1,
                                                          bottom: 1,
                                                          top: 1),
                                                  padding: EdgeInsets.all(20),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .prayerCardBgColor,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(9),
                                                      topLeft:
                                                          Radius.circular(9),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                          child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              user.fullName
                                                                      ?.sentenceCase() ??
                                                                  '',
                                                              style: AppTextStyles
                                                                  .boldText14
                                                                  .copyWith(
                                                                      color: AppColors
                                                                          .lightBlue4)),
                                                          Text(
                                                            user.role ==
                                                                    GroupUserRole
                                                                        .admin
                                                                ? 'Admin'
                                                                : user.role ==
                                                                        GroupUserRole
                                                                            .moderator
                                                                    ? 'Moderator'
                                                                    : 'Member',
                                                            style: AppTextStyles
                                                                .regularText14
                                                                .copyWith(
                                                                    color: AppColors
                                                                        .lightBlue1),
                                                          ),
                                                        ],
                                                      )),
                                                      Icon(Icons.more_vert,
                                                              color: AppColors
                                                                  .lightBlue4)
                                                          .marginOnly(
                                                              left: 10,
                                                              right: 5)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(height: 40),
                        !isAdmin
                            ? GestureDetector(
                                onTap: () {
                                  const message =
                                      'Are you sure you want to leave this group?';
                                  const method = 'LEAVE';
                                  const title = 'Leave Group';
                                  _openDeleteConfirmation(
                                      context, message, method, title, data);
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: AppColors.red,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Container(
                                    child: Text(
                                      'LEAVE GROUP',
                                      style: AppTextStyles.boldText20
                                          .copyWith(color: AppColors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(height: 20),
                        isAdmin
                            ? GestureDetector(
                                onTap: () async {
                                  const message =
                                      'Are you sure? \n\nAll members of this group will be removed, '
                                      'and this group and all the prayers in it will be permanently erased.';
                                  const method = 'Delete';
                                  const title = 'Delete Group';
                                  _openDeleteConfirmation(
                                      context, message, method, title, data);
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: AppColors.red,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Container(
                                    child: Text(
                                      'DELETE',
                                      style: AppTextStyles.boldText20
                                          .copyWith(color: AppColors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(height: 100)
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
