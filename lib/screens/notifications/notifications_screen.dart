import 'dart:async';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/models/v2/notification.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/notifications/widgets/notification_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_expansion_tile.dart' as custom;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  static const routeName = 'notifications';

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // final SlidableController slidableController = SlidableController();
  final refreshKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void dispose() async {
    super.dispose();
  }

  Future getNotifications(String? userId) async {
    try {
      BeStilDialog.showLoading(context, '');

      await Provider.of<NotificationProviderV2>(context, listen: false)
          .setUserNotifications(userId ?? '');
      BeStilDialog.hideLoading(context);
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

  void _showAlert(
      String groupId,
      String message,
      String senderId,
      String receiverId,
      String? groupName,
      String type,
      String? notificationId) {
    FocusScope.of(context).unfocus();
    AlertDialog dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor: AppColors.prayerCardBgColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: AppColors.lightBlue3,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 5.0),
                child: Text(
                  type == NotificationType.adminRequest
                      ? 'ADMIN REQUEST'
                      : 'GROUP REQUEST',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.lightBlue1,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regularText16b.copyWith(
                            color: AppColors.lightBlue4,
                            fontWeight: FontWeight.w500)),
                    Text((groupName ?? '').sentenceCase(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regularText16b.copyWith(
                            color: AppColors.lightBlue4,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 20.0),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => denyRequest(groupId, receiverId,
                                senderId, type, notificationId ?? ''),
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * .25,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.grey.withOpacity(0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'DENY',
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
                          GestureDetector(
                            onTap: () => acceptRequest(
                                groupId, senderId, receiverId, type),
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * .25,
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
                                    'APPROVE',
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
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 30,
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          // width: MediaQuery.of(context).size.width * .25,
                          decoration: BoxDecoration(
                            // color: Colors.blue,
                            borderRadius: BorderRadius.circular(5),
                            color: AppColors.grey.withOpacity(0.5),
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
                      ).marginOnly(top: 20),
                    ),
                  ],
                ),
              ),
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

  Future deleteNotification(String id, {String? prayerId}) async {
    try {
      await Provider.of<NotificationProviderV2>(context, listen: false)
          .cancelNotification(id, prayerId: prayerId);
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

  Future deleteInappropriateNotification(
      String senderId, String prayerId) async {
    try {
      await Provider.of<NotificationProviderV2>(context, listen: false)
          .deleteInappropriateNotification(senderId, prayerId);
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

  gotoGroup(NotificationModel? notification) async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<GroupProviderV2>(context, listen: false)
          .setCurrentGroupById(notification?.groupId ?? '');
      // await Provider.of<PrayerProviderV2>(context, listen: false)
      //     .setGroupPrayers(notification?.groupId ?? '');
      deleteNotification(notification?.id ?? '');
      BeStilDialog.hideLoading(context);

      // service get group by id
      // go to 8
      AppController appController = Get.find();
      appController.setCurrentPage(8, true, 14);
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

  String getSenderName(String userId) {
    if (userId.isNotEmpty) {
      final user = Provider.of<UserProviderV2>(context, listen: false)
          .allUsers
          .firstWhere((u) => u.id == userId, orElse: () => UserDataModel());
      final senderName = (user.firstName ?? '') + ' ' + (user.lastName ?? '');
      return senderName;
    } else {
      return '';
    }
  }

  gotoPrayer(NotificationModel notification, {String? prayerId}) async {
    BeStilDialog.showLoading(context);
    try {
      if ((notification.groupId ?? '').isNotEmpty)
        await Provider.of<GroupProviderV2>(context, listen: false)
            .setCurrentGroupById(notification.groupId ?? '');
      // await Provider.of<PrayerProviderV2>(context, listen: false)
      //     .setGroupPrayers(notification.groupId ?? '');
      Provider.of<PrayerProviderV2>(context, listen: false)
          .setCurrentPrayerId(notification.prayerId ?? '');
      if (notification.type == NotificationType.inappropriate_content) {
        deleteInappropriateNotification(
            notification.senderId ?? '', notification.prayerId ?? '');
      } else if (notification.type == NotificationType.inappropriate_content) {
        final _prayerUpdates =
            Provider.of<NotificationProviderV2>(context, listen: false)
                .prayerUpdates;
        _prayerUpdates
            .where((element) => element.prayerId == notification.prayerId)
            .forEach((element) {
          deleteNotification(element.id ?? '', prayerId: prayerId);
        });
      } else {
        await deleteNotification(notification.id ?? '', prayerId: prayerId);
      }

      BeStilDialog.hideLoading(context);
      AppController appController = Get.find();
      appController.setCurrentPage(9, true, 14);
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

  Future<void> denyRequest(String groupId, String receiverId, String senderId,
      String type, String notificationId) async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<UserProviderV2>(context, listen: false)
          .getUserDataById(receiverId); //requestor
      await Provider.of<GroupProviderV2>(context, listen: false)
          .setCurrentGroupById(groupId);

      final groupData = Provider.of<GroupProviderV2>(context, listen: false)
          .currentGroup; //group
      final groupRequest =
          (groupData.requests ?? []).firstWhere((e) => e.userId == receiverId);
      if (type == NotificationType.adminRequest) {
        await Provider.of<GroupProviderV2>(context, listen: false)
            .declineAdminRequest(groupData, receiverId, notificationId);
      } else {
        await Provider.of<GroupProviderV2>(context, listen: false)
            .denyRequest(groupData, groupRequest, senderId);
      }

      BeStilDialog.hideLoading(context);
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

  Future<void> acceptRequest(
      String groupId, String senderId, String receiverId, String type) async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<GroupProviderV2>(context, listen: false)
          .setCurrentGroupById(groupId);
      final groupData = Provider.of<GroupProviderV2>(context, listen: false)
          .currentGroup; //group

      final currentAdmin = (groupData.users ?? []).firstWhere(
          (element) => element.role == GroupUserRole.admin,
          orElse: () => GroupUserDataModel());
      final prospectiveAdmin = (groupData.users ?? []).firstWhere(
          (element) => element.userId == receiverId,
          orElse: () => GroupUserDataModel());
      final groupRequest =
          (groupData.requests ?? []).firstWhere((e) => e.userId == receiverId);
      if (type == NotificationType.adminRequest) {
        final currentUser =
            Provider.of<UserProviderV2>(context, listen: false).currentUser;
        final senderName = '${currentUser.firstName} ${currentUser.lastName}';
        final message1 = 'You are now the admin of ${groupData.name}';
        final message2 = 'You are now a moderator of ${groupData.name}';
        await Provider.of<GroupProviderV2>(context, listen: false)
            .promoteToAdmin(currentAdmin, prospectiveAdmin,
                GroupUserRole.moderator, groupId);
        await Provider.of<NotificationProviderV2>(context, listen: false)
            .sendPushNotification(
                message1, NotificationType.accept_request, senderName, [],
                receiverId: receiverId, groupId: groupData.id);
        await Provider.of<NotificationProviderV2>(context, listen: false)
            .sendPushNotification(
                message2, NotificationType.accept_request, senderName, [],
                receiverId: senderId, groupId: groupData.id);
      } else {
        await Provider.of<GroupProviderV2>(context, listen: false)
            .acceptRequest(groupData, groupRequest, senderId);
      }

      // deleteNotification(notificationId);

      BeStilDialog.hideLoading(context);
      Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return SafeArea(
      child: Scaffold(
        appBar: NotificationBar(),
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
              fit: BoxFit.cover,
            ),
          ),
          child: RefreshIndicator(
            key: refreshKey,
            onRefresh: () => getNotifications(userId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildPanel(),
            ),
          ),
        ),
      ),
    );
  }

  String? groupName(String id) {
    final allGroups =
        Provider.of<GroupProviderV2>(context, listen: false).allGroups;
    final groupName = (allGroups.firstWhere(
      (element) => element.id == id,
      orElse: () => GroupDataModel(),
    )).name;
    return groupName;
  }

  GroupDataModel groupData(String groupId) {
    final allGroups =
        Provider.of<GroupProviderV2>(context, listen: false).allGroups;
    final groupData = (allGroups.firstWhere(
      (element) => element.id == groupId,
      orElse: () => GroupDataModel(),
    ));
    return groupData;
  }

  Widget _buildRequestPanel(List<NotificationModel> requests) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: custom.ExpansionTile(
        iconColor: AppColors.lightBlue4,
        headerBackgroundColorStart: AppColors.prayerMenu[0],
        headerBackgroundColorEnd: AppColors.prayerMenu[1],
        shadowColor: AppColors.dropShadow,
        title: Container(
          margin:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
          child: Text(
            NotificationType.request,
            textAlign: TextAlign.center,
            style: AppTextStyles.boldText24.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        initiallyExpanded: true,
        children: <Widget>[
          ...requests.map((NotificationModel notification) {
            return Column(
              children: [
                SizedBox(height: 10),
                GestureDetector(
                  onLongPressEnd: null,
                  onTap: () => _showAlert(
                      notification.groupId ?? '',
                      notification.message ?? '',
                      notification.createdBy ?? '',
                      notification.createdBy ?? '',
                      groupName(notification.groupId ?? ''),
                      NotificationType.request,
                      notification.id),
                  child: Container(
                    margin: EdgeInsets.only(left: 20.0),
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsetsDirectional.only(
                          start: 1, bottom: 1, top: 1),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.prayerCardBgColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(9),
                          topLeft: Radius.circular(9),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                              (groupName(notification.groupId ??
                                                      '') ??
                                                  ''),
                                              style: AppTextStyles
                                                  .regularText15b
                                                  .copyWith(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.lightBlue4,
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                        ),
                                        SizedBox(width: 20),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              DateFormat('MM.dd.yyyy').format(
                                                  notification.createdDate ??
                                                      DateTime.now()),
                                              style: AppTextStyles
                                                  .regularText15b
                                                  .copyWith(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.lightBlue4),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: AppColors.divider,
                            thickness: 0.5,
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Text(
                                  (notification.message ??
                                          ''.capitalizeFirst ??
                                          '')
                                      .substring(0,
                                          (notification.message ?? '').length),
                                  style: AppTextStyles.regularText16b.copyWith(
                                    color: AppColors.lightBlue4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAdminRequestPanel(List<NotificationModel> adminRequest) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: custom.ExpansionTile(
        iconColor: AppColors.lightBlue4,
        headerBackgroundColorStart: AppColors.prayerMenu[0],
        headerBackgroundColorEnd: AppColors.prayerMenu[1],
        shadowColor: AppColors.dropShadow,
        title: Container(
          margin:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
          child: Text(
            NotificationType.request,
            textAlign: TextAlign.center,
            style: AppTextStyles.boldText24.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        initiallyExpanded: true,
        children: <Widget>[
          ...adminRequest.map((NotificationModel notification) {
            return Column(
              children: [
                SizedBox(height: 10),
                GestureDetector(
                  onLongPressEnd: null,
                  onTap: () => _showAlert(
                      notification.groupId ?? '',
                      notification.message ?? '',
                      notification.createdBy ?? '',
                      notification.createdBy ?? '',
                      groupName(notification.groupId ?? ''),
                      NotificationType.adminRequest,
                      notification.id),
                  child: Container(
                    margin: EdgeInsets.only(left: 20.0),
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsetsDirectional.only(
                          start: 1, bottom: 1, top: 1),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.prayerCardBgColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(9),
                          topLeft: Radius.circular(9),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                              (groupName(notification.groupId ??
                                                      '') ??
                                                  ''),
                                              style: AppTextStyles
                                                  .regularText15b
                                                  .copyWith(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.lightBlue4,
                                                      overflow: TextOverflow
                                                          .ellipsis)),
                                        ),
                                        SizedBox(width: 20),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              DateFormat('MM.dd.yyyy').format(
                                                  notification.createdDate ??
                                                      DateTime.now()),
                                              style: AppTextStyles
                                                  .regularText15b
                                                  .copyWith(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.lightBlue4),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: AppColors.divider,
                            thickness: 0.5,
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Text(
                                  (notification.message ??
                                          ''.capitalizeFirst ??
                                          '')
                                      .substring(0,
                                          (notification.message ?? '').length),
                                  style: AppTextStyles.regularText16b.copyWith(
                                    color: AppColors.lightBlue4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildUserLeftPanel(List<NotificationModel> leftGroup) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: custom.ExpansionTile(
            iconColor: AppColors.lightBlue4,
            headerBackgroundColorStart: AppColors.prayerMenu[0],
            headerBackgroundColorEnd: AppColors.prayerMenu[1],
            shadowColor: AppColors.dropShadow,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                NotificationType.leave_group,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...leftGroup.map((notification) {
                return Column(
                  children: [
                    SizedBox(height: 10),
                    Dismissible(
                      key: Key(notification.id ?? ''),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        deleteNotification(notification.id ?? '');
                      },
                      child: GestureDetector(
                        onLongPressEnd: null,
                        onTap: () async {
                          deleteNotification(notification.id ?? '');
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0),
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsetsDirectional.only(
                                start: 1, bottom: 1, top: 1),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.prayerCardBgColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(9),
                                topLeft: Radius.circular(9),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        (groupName(
                                                notification.groupId ?? '') ??
                                            ''),
                                        style: AppTextStyles.regularText15b
                                            .copyWith(
                                                fontSize: 14,
                                                color: AppColors.lightBlue4,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          DateFormat('MM.dd.yyyy').format(
                                              notification.createdDate ??
                                                  DateTime.now()),
                                          style: AppTextStyles.regularText15b
                                              .copyWith(
                                                  fontSize: 14,
                                                  color: AppColors.lightBlue4),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: AppColors.divider,
                                  thickness: 0.5,
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Text(
                                        (notification.message ?? '').length > 99
                                            ? (notification.message ?? '')
                                                .substring(0, 100)
                                            : notification.message ?? '',
                                        style: AppTextStyles.regularText16b
                                            .copyWith(
                                          color: AppColors.lightBlue4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ]));
  }

  Widget _buildUserJoinPanel(List<NotificationModel> joinGroup) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: custom.ExpansionTile(
            iconColor: AppColors.lightBlue4,
            headerBackgroundColorStart: AppColors.prayerMenu[0],
            headerBackgroundColorEnd: AppColors.prayerMenu[1],
            shadowColor: AppColors.dropShadow,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                NotificationType.join_group,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...joinGroup.map((notification) {
                return Column(
                  children: [
                    SizedBox(height: 10),
                    Dismissible(
                      key: Key(notification.id ?? ''),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        deleteNotification(notification.id ?? '');
                      },
                      child: GestureDetector(
                        onLongPressEnd: null,
                        onTap: () async {
                          deleteNotification(notification.id ?? '');
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0),
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsetsDirectional.only(
                                start: 1, bottom: 1, top: 1),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.prayerCardBgColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(9),
                                topLeft: Radius.circular(9),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        (groupName(
                                                notification.groupId ?? '') ??
                                            ''),
                                        style: AppTextStyles.regularText15b
                                            .copyWith(
                                                fontSize: 14,
                                                color: AppColors.lightBlue4,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          DateFormat('MM.dd.yyyy').format(
                                              notification.createdDate ??
                                                  DateTime.now()),
                                          style: AppTextStyles.regularText15b
                                              .copyWith(
                                                  fontSize: 14,
                                                  color: AppColors.lightBlue4),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: AppColors.divider,
                                  thickness: 0.5,
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Text(
                                        (notification.message ?? '').length > 99
                                            ? (notification.message ?? '')
                                                .substring(0, 100)
                                            : notification.message ?? '',
                                        style: AppTextStyles.regularText16b
                                            .copyWith(
                                          color: AppColors.lightBlue4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ]));
  }

  Widget _buildRequestAcceptedPanel(List<NotificationModel> requestAccepted) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: custom.ExpansionTile(
            iconColor: AppColors.lightBlue4,
            headerBackgroundColorStart: AppColors.prayerMenu[0],
            headerBackgroundColorEnd: AppColors.prayerMenu[1],
            shadowColor: AppColors.dropShadow,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                NotificationType.accept_request,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...requestAccepted.map((NotificationModel notification) {
                return Column(
                  children: [
                    SizedBox(height: 10),
                    Dismissible(
                      key: Key(notification.id ?? ''),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        deleteNotification(notification.id ?? '');
                      },
                      child: GestureDetector(
                        onLongPressEnd: null,
                        onTap: () => gotoGroup(notification),
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0),
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsetsDirectional.only(
                                start: 1, bottom: 1, top: 1),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.prayerCardBgColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(9),
                                topLeft: Radius.circular(9),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    groupName(notification.groupId ?? '') != ''
                                        ? Expanded(
                                            child: Text(
                                                groupName(
                                                        notification.groupId ??
                                                            '') ??
                                                    '',
                                                style: AppTextStyles
                                                    .regularText15b
                                                    .copyWith(
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .lightBlue4,
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                          )
                                        : SizedBox(),
                                    SizedBox(width: 20),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          DateFormat('MM.dd.yyyy').format(
                                              notification.createdDate ??
                                                  DateTime.now()),
                                          style: AppTextStyles.regularText15b
                                              .copyWith(
                                                  fontSize: 14,
                                                  color: AppColors.lightBlue4),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: AppColors.divider,
                                  thickness: 0.5,
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Text(
                                        (notification.message ?? '').length > 99
                                            ? (notification.message ?? '')
                                                .substring(0, 100)
                                            : notification.message ?? '',
                                        style: AppTextStyles.regularText16b
                                            .copyWith(
                                          color: AppColors.lightBlue4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ]));
  }

  Widget _buildRequestDeniedPanel(List<NotificationModel> requestDenied) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: custom.ExpansionTile(
            iconColor: AppColors.lightBlue4,
            headerBackgroundColorStart: AppColors.prayerMenu[0],
            headerBackgroundColorEnd: AppColors.prayerMenu[1],
            shadowColor: AppColors.dropShadow,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                NotificationType.deny_request,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...requestDenied.map((NotificationModel notification) {
                return Column(
                  children: [
                    SizedBox(height: 10),
                    Dismissible(
                      key: Key(notification.id ?? ''),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        deleteNotification(notification.id ?? '');
                      },
                      child: GestureDetector(
                        onLongPressEnd: null,
                        onTap: () => deleteNotification(notification.id ?? ''),
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0),
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsetsDirectional.only(
                                start: 1, bottom: 1, top: 1),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.prayerCardBgColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(9),
                                topLeft: Radius.circular(9),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              groupName(notification.groupId ??
                                                          '') !=
                                                      ''
                                                  ? Expanded(
                                                      child: Text(
                                                        groupName(notification
                                                                    .groupId ??
                                                                '') ??
                                                            ''.sentenceCase(),
                                                        style: AppTextStyles
                                                            .regularText15b
                                                            .copyWith(
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .lightBlue4,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              SizedBox(width: 20),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    DateFormat('MM.dd.yyyy')
                                                        .format(notification
                                                                .createdDate ??
                                                            DateTime.now()),
                                                    style: AppTextStyles
                                                        .regularText15b
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .lightBlue4),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: AppColors.divider,
                                  thickness: 0.5,
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Text(
                                        (notification.message ?? '').length > 99
                                            ? (notification.message ?? '')
                                                .substring(0, 100)
                                            : notification.message ?? '',
                                        style: AppTextStyles.regularText16b
                                            .copyWith(
                                          color: AppColors.lightBlue4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ]));
  }

  Widget _buildInapproriateContentPanel(
      List<NotificationModel> inappropriateContent) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: custom.ExpansionTile(
            iconColor: AppColors.lightBlue4,
            headerBackgroundColorStart: AppColors.prayerMenu[0],
            headerBackgroundColorEnd: AppColors.prayerMenu[1],
            shadowColor: AppColors.dropShadow,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                NotificationType.inappropriate_content,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...inappropriateContent.map((NotificationModel notification) {
                return Column(
                  children: [
                    SizedBox(height: 10),
                    GestureDetector(
                      onLongPressEnd: null,
                      onTap: () {
                        gotoPrayer(notification);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsetsDirectional.only(
                              start: 1, bottom: 1, top: 1),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.prayerCardBgColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(9),
                              topLeft: Radius.circular(9),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            groupName(notification.groupId ??
                                                        '') !=
                                                    ''
                                                ? Expanded(
                                                    child: Text(
                                                        groupName(notification
                                                                    .groupId ??
                                                                '') ??
                                                            '',
                                                        style: AppTextStyles
                                                            .regularText15b
                                                            .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4,
                                                        ),
                                                        textAlign:
                                                            TextAlign.end,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  )
                                                : SizedBox.shrink(),
                                            SizedBox(width: 20),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  DateFormat('MM.dd.yyyy')
                                                      .format(notification
                                                              .createdDate ??
                                                          DateTime.now()),
                                                  style: AppTextStyles
                                                      .regularText15b
                                                      .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: AppColors.divider,
                                thickness: 0.5,
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: Text(
                                      (notification.message ?? '').length > 99
                                          ? (notification.message ?? '')
                                              .substring(0, 100)
                                          : notification.message ?? '',
                                      style:
                                          AppTextStyles.regularText16b.copyWith(
                                        color: AppColors.lightBlue4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ]));
  }

  Widget _buildNewPrayersPanel(List<NotificationModel> newPrayers) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: custom.ExpansionTile(
            iconColor: AppColors.lightBlue4,
            headerBackgroundColorStart: AppColors.prayerMenu[0],
            headerBackgroundColorEnd: AppColors.prayerMenu[1],
            shadowColor: AppColors.dropShadow,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                NotificationType.prayer,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...newPrayers.map((NotificationModel notification) {
                return Column(
                  children: [
                    SizedBox(height: 10),
                    Dismissible(
                      key: Key(notification.id ?? ''),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        deleteNotification(notification.id ?? '');
                      },
                      child: GestureDetector(
                        onLongPressEnd: null,
                        onTap: () async {
                          gotoPrayer(notification);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0),
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsetsDirectional.only(
                                start: 1, bottom: 1, top: 1),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.prayerCardBgColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(9),
                                topLeft: Radius.circular(9),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              getSenderName(notification
                                                              .senderId ??
                                                          '') !=
                                                      ''
                                                  ? Expanded(
                                                      child: Text(
                                                        (groupName(notification
                                                                    .groupId ??
                                                                '') ??
                                                            ''),
                                                        style: AppTextStyles
                                                            .regularText15b
                                                            .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                              SizedBox(width: 20),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    DateFormat('MM.dd.yyyy')
                                                        .format(notification
                                                                .createdDate ??
                                                            DateTime.now()),
                                                    style: AppTextStyles
                                                        .regularText15b
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .lightBlue4),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: AppColors.divider,
                                  thickness: 0.5,
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Text(
                                        '${getSenderName(notification.senderId ?? '')} added a new prayer to the group.',
                                        style: AppTextStyles.regularText16b
                                            .copyWith(
                                          color: AppColors.lightBlue4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ]));
  }

  Widget _buildEditedPrayersPanel(List<NotificationModel> editedPrayers) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: custom.ExpansionTile(
            iconColor: AppColors.lightBlue4,
            headerBackgroundColorStart: AppColors.prayerMenu[0],
            headerBackgroundColorEnd: AppColors.prayerMenu[1],
            shadowColor: AppColors.dropShadow,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                NotificationType.edited_prayers,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...editedPrayers.map((notification) {
                return Column(
                  children: [
                    SizedBox(height: 10),
                    Dismissible(
                      key: Key(notification.id ?? ''),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        deleteNotification(notification.id ?? '');
                      },
                      child: GestureDetector(
                        onLongPressEnd: null,
                        onTap: () async {
                          gotoPrayer(notification);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0),
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsetsDirectional.only(
                                start: 1, bottom: 1, top: 1),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.prayerCardBgColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(9),
                                topLeft: Radius.circular(9),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              getSenderName(notification
                                                              .senderId ??
                                                          '') !=
                                                      ''
                                                  ? Expanded(
                                                      child: Text(
                                                        getSenderName(
                                                            notification
                                                                    .senderId ??
                                                                ''),
                                                        style: AppTextStyles
                                                            .regularText15b
                                                            .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                              SizedBox(width: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    child: Text(
                                                            (groupName(notification
                                                                        .groupId ??
                                                                    '') ??
                                                                ''),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .lightBlue4),
                                                            textAlign:
                                                                TextAlign.end)
                                                        .marginOnly(right: 2),
                                                  ),
                                                  Text(
                                                    '|',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .lightBlue4),
                                                  ).marginOnly(right: 5),
                                                  Text(
                                                    DateFormat('MM.dd.yyyy')
                                                        .format(notification
                                                                .createdDate ??
                                                            DateTime.now()),
                                                    style: AppTextStyles
                                                        .regularText15b
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .lightBlue4),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: AppColors.divider,
                                  thickness: 0.5,
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Text(
                                        (notification.message ?? '').length > 99
                                            ? (notification.message ?? '')
                                                .substring(0, 100)
                                            : notification.message ?? '',
                                        style: AppTextStyles.regularText16b
                                            .copyWith(
                                          color: AppColors.lightBlue4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ]));
  }

  Widget _buildArchivedPrayersPanel(List<NotificationModel> archivedPrayers) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: custom.ExpansionTile(
            iconColor: AppColors.lightBlue4,
            headerBackgroundColorStart: AppColors.prayerMenu[0],
            headerBackgroundColorEnd: AppColors.prayerMenu[1],
            shadowColor: AppColors.dropShadow,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                NotificationType.archived_prayers,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...archivedPrayers.map((notification) {
                return Column(
                  children: [
                    SizedBox(height: 10),
                    Dismissible(
                      key: Key(notification.id ?? ''),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        deleteNotification(notification.id ?? '');
                      },
                      child: GestureDetector(
                        onLongPressEnd: null,
                        onTap: () async {
                          gotoPrayer(notification);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0),
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsetsDirectional.only(
                                start: 1, bottom: 1, top: 1),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.prayerCardBgColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(9),
                                topLeft: Radius.circular(9),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              getSenderName(notification
                                                              .senderId ??
                                                          '') !=
                                                      ''
                                                  ? Expanded(
                                                      child: Text(
                                                        getSenderName(
                                                            notification
                                                                    .senderId ??
                                                                ''),
                                                        style: AppTextStyles
                                                            .regularText15b
                                                            .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                              SizedBox(width: 20),
                                              Row(
                                                children: <Widget>[
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    child: Text(
                                                      (groupName(notification
                                                                  .groupId ??
                                                              '') ??
                                                          ''),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .lightBlue4),
                                                    ).marginOnly(right: 2),
                                                  ),
                                                  Text(
                                                    '|',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .lightBlue4),
                                                  ).marginOnly(right: 5),
                                                  Text(
                                                    DateFormat('MM.dd.yyyy')
                                                        .format(notification
                                                                .createdDate ??
                                                            DateTime.now()),
                                                    style: AppTextStyles
                                                        .regularText15b
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .lightBlue4),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: AppColors.divider,
                                  thickness: 0.5,
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Text(
                                        (notification.message ?? '').length > 99
                                            ? (notification.message ?? '')
                                                .substring(0, 100)
                                            : notification.message ?? '',
                                        style: AppTextStyles.regularText16b
                                            .copyWith(
                                          color: AppColors.lightBlue4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ]));
  }

  Widget _buildAnsweredPrayersPanel(List<NotificationModel> answeredPrayers) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: custom.ExpansionTile(
            iconColor: AppColors.lightBlue4,
            headerBackgroundColorStart: AppColors.prayerMenu[0],
            headerBackgroundColorEnd: AppColors.prayerMenu[1],
            shadowColor: AppColors.dropShadow,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                NotificationType.answered_prayers,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...answeredPrayers.map((notification) {
                return Column(children: [
                  SizedBox(height: 10),
                  Dismissible(
                      key: Key(notification.id ?? ''),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        deleteNotification(notification.id ?? '');
                      },
                      child: GestureDetector(
                          onLongPressEnd: null,
                          onTap: () async {
                            gotoPrayer(notification);
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: 20.0),
                              decoration: BoxDecoration(
                                color: AppColors.cardBorder,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                              ),
                              child: Container(
                                  margin: EdgeInsetsDirectional.only(
                                      start: 1, bottom: 1, top: 1),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.prayerCardBgColor,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(9),
                                      topLeft: Radius.circular(9),
                                    ),
                                  ),
                                  child: Column(children: <Widget>[
                                    Row(children: <Widget>[
                                      Expanded(
                                          child: Column(children: <Widget>[
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              getSenderName(notification
                                                              .senderId ??
                                                          '') !=
                                                      ''
                                                  ? Expanded(
                                                      child: Text(
                                                        getSenderName(
                                                            notification
                                                                    .senderId ??
                                                                ''),
                                                        style: AppTextStyles
                                                            .regularText15b
                                                            .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                              SizedBox(width: 20),
                                              Row(children: <Widget>[
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Text(
                                                    (groupName(notification
                                                                .groupId ??
                                                            '') ??
                                                        ''),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .lightBlue4),
                                                  ).marginOnly(right: 2),
                                                ),
                                                Text(
                                                  '|',
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.lightBlue4),
                                                ).marginOnly(right: 5),
                                                Text(
                                                    DateFormat('MM.dd.yyyy')
                                                        .format(notification
                                                                .createdDate ??
                                                            DateTime.now()),
                                                    style: AppTextStyles
                                                        .regularText15b
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .lightBlue4))
                                              ])
                                            ])
                                      ]))
                                    ]),
                                    Divider(
                                        color: AppColors.divider,
                                        thickness: 0.5),
                                    Row(children: <Widget>[
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: Text(
                                              (notification.message ?? '')
                                                          .length >
                                                      99
                                                  ? (notification.message ?? '')
                                                      .substring(0, 100)
                                                  : notification.message ?? '',
                                              style: AppTextStyles
                                                  .regularText16b
                                                  .copyWith(
                                                      color: AppColors
                                                          .lightBlue4)))
                                    ])
                                  ]))))),
                  SizedBox(height: 10)
                ]);
              }).toList(),
            ]));
  }

  Widget _buildPrayerUpdatesPanel(List<NotificationModel> prayerUpdates) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: custom.ExpansionTile(
            iconColor: AppColors.lightBlue4,
            headerBackgroundColorStart: AppColors.prayerMenu[0],
            headerBackgroundColorEnd: AppColors.prayerMenu[1],
            shadowColor: AppColors.dropShadow,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                NotificationType.prayer_updates,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...prayerUpdates.map((NotificationModel notification) {
                return Column(children: [
                  SizedBox(height: 10),
                  Dismissible(
                      key: Key(notification.id ?? ''),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        deleteNotification(notification.id ?? '',
                            prayerId: notification.prayerId);
                      },
                      child: GestureDetector(
                          onLongPressEnd: null,
                          onTap: () async {
                            gotoPrayer(notification,
                                prayerId: notification.prayerId);
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: 20.0),
                              decoration: BoxDecoration(
                                color: AppColors.cardBorder,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                              ),
                              child: Container(
                                  margin: EdgeInsetsDirectional.only(
                                      start: 1, bottom: 1, top: 1),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.prayerCardBgColor,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(9),
                                      topLeft: Radius.circular(9),
                                    ),
                                  ),
                                  child: Column(children: <Widget>[
                                    Row(children: <Widget>[
                                      Expanded(
                                          child: Column(children: <Widget>[
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              getSenderName(notification
                                                              .senderId ??
                                                          '') !=
                                                      ''
                                                  ? Expanded(
                                                      child: Text(
                                                        getSenderName(
                                                            notification
                                                                    .senderId ??
                                                                ''),
                                                        style: AppTextStyles
                                                            .regularText15b
                                                            .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                              SizedBox(width: 20),
                                              Row(children: <Widget>[
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Text(
                                                          (groupName(
                                                                  notification
                                                                          .groupId ??
                                                                      '') ??
                                                              ''),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .lightBlue4),
                                                          textAlign:
                                                              TextAlign.end)
                                                      .marginOnly(right: 2),
                                                ),
                                                Text(
                                                  '|',
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.lightBlue4),
                                                ).marginOnly(right: 5),
                                                Text(
                                                    DateFormat('MM.dd.yyyy')
                                                        .format(notification
                                                                .createdDate ??
                                                            DateTime.now()),
                                                    style: AppTextStyles
                                                        .regularText15b
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .lightBlue4))
                                              ])
                                            ])
                                      ]))
                                    ]),
                                    Divider(
                                        color: AppColors.divider,
                                        thickness: 0.5),
                                    Row(children: <Widget>[
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: Text(
                                              (notification.message ?? '')
                                                          .length >
                                                      99
                                                  ? (notification.message ?? '')
                                                      .substring(0, 100)
                                                  : notification.message ?? '',
                                              style: AppTextStyles
                                                  .regularText16b
                                                  .copyWith(
                                                      color: AppColors
                                                          .lightBlue4)))
                                    ])
                                  ]))))),
                  SizedBox(height: 10)
                ]);
              }).toList(),
            ]));
  }

  Widget _buildPanel() {
    final requests = Provider.of<NotificationProviderV2>(context).requests;
    final adminRequests =
        Provider.of<NotificationProviderV2>(context).adminRequests;
    final newPrayers = Provider.of<NotificationProviderV2>(context).newPrayers;
    final requestAccepted =
        Provider.of<NotificationProviderV2>(context).requestAccepted;
    final requestDenied =
        Provider.of<NotificationProviderV2>(context).requestDenied;
    final editedPrayers =
        Provider.of<NotificationProviderV2>(context).editedPrayers;
    final archivedPrayers =
        Provider.of<NotificationProviderV2>(context).archivedPrayers;
    final answeredPrayers =
        Provider.of<NotificationProviderV2>(context).answeredPrayers;
    final inappropriateContent =
        Provider.of<NotificationProviderV2>(context).inappropriateContent;
    final _prayerUpdates =
        Provider.of<NotificationProviderV2>(context).prayerUpdates;

    final leftGroup = Provider.of<NotificationProviderV2>(context).leftGroup;
    final joinGroup = Provider.of<NotificationProviderV2>(context).joinGroup;
    final data = Provider.of<NotificationProviderV2>(context).notifications;

    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(height: 40),
          data.length == 0
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 60),
                  child: Opacity(
                    opacity: 0.3,
                    child: Text(
                      'You do not have any alerts',
                      style: AppTextStyles.demiboldText34,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Container(),

          requests.length > 0 ? _buildRequestPanel(requests) : Container(),
          adminRequests.length > 0
              ? _buildAdminRequestPanel(adminRequests)
              : Container(),
          newPrayers.length > 0
              ? _buildNewPrayersPanel(newPrayers)
              : Container(),
          // remove.length > 0 ? _buildRemoveUserPanel(remove) : Container(),
          requestAccepted.length > 0
              ? _buildRequestAcceptedPanel(requestAccepted)
              : Container(),
          requestDenied.length > 0
              ? _buildRequestDeniedPanel(requestDenied)
              : Container(),
          editedPrayers.length > 0
              ? _buildEditedPrayersPanel(editedPrayers)
              : Container(),
          archivedPrayers.length > 0
              ? _buildArchivedPrayersPanel(archivedPrayers)
              : Container(),
          answeredPrayers.length > 0
              ? _buildAnsweredPrayersPanel(answeredPrayers)
              : Container(),
          inappropriateContent.length > 0
              ? _buildInapproriateContentPanel(inappropriateContent)
              : Container(),
          _prayerUpdates.length > 0
              ? _buildPrayerUpdatesPanel(_prayerUpdates)
              : Container(),
          leftGroup.length > 0 ? _buildUserLeftPanel(leftGroup) : Container(),
          joinGroup.length > 0 ? _buildUserJoinPanel(joinGroup) : Container()
        ],
      ),
    );
  }
}
