import 'dart:async';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/notifications/widgets/notification_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_expansion_tile.dart' as custom;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  static const routeName = 'notifications';

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final SlidableController slidableController = SlidableController();
  final refreshKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void dispose() async {
    super.dispose();
  }

  Future getNotifications(String? userId) async {
    try {
      BeStilDialog.showLoading(context, '');

      await Provider.of<NotificationProvider>(context, listen: false)
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

  void _showAlert(String groupId, String message, String senderId,
      String notificationId, String receiverId, String? groupName) {
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
                  'GROUP REQUEST',
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
                            onTap: () => denyRequest(
                                groupId, notificationId, receiverId),
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
                                groupId, senderId, notificationId, receiverId),
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

  Future deleteNotification(String id) async {
    try {
      await Provider.of<NotificationProvider>(context, listen: false)
          .updateNotification(id);
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

  gotoGroup(PushNotificationModel? notification) async {
    BeStilDialog.showLoading(context);

    try {
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<GroupProvider>(context, listen: false)
          .setCurrentGroupById(notification?.groupId ?? '', userId ?? '');
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .setGroupPrayers(notification?.groupId ?? '');
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

  gotoPrayer(PushNotificationModel notification) async {
    BeStilDialog.showLoading(context);
    try {
      var userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      if ((notification.groupId ?? '').isNotEmpty)
        await Provider.of<GroupProvider>(context, listen: false)
            .setCurrentGroupById(notification.groupId ?? '', userId ?? '');
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .setGroupPrayers(notification.groupId ?? '');
      Provider.of<GroupPrayerProvider>(context, listen: false)
          .setCurrentPrayerId(notification.prayerId ?? '');
      await deleteNotification(notification.id ?? '');

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

  Future<void> denyRequest(
      String groupId, String notificationId, String receiverId) async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .getUserById(receiverId); //requestor
      UserModel requestor =
          Provider.of<UserProvider>(context, listen: false).selectedUser;
      final admin =
          Provider.of<UserProvider>(context, listen: false).currentUser; //admin
      final groupData = await Provider.of<GroupProvider>(context, listen: false)
          .getGroupFuture(groupId, admin.id ?? ''); //group
      final groupRequest = (groupData.groupRequests ?? [])
          .firstWhere((e) => e.userId == requestor.id);
      await Provider.of<GroupProvider>(context, listen: false)
          .denyRequest(groupId, groupRequest.id ?? '');
      deleteNotification(notificationId);
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

  Future<void> acceptRequest(String groupId, String senderId,
      String notificationId, String receiverId) async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .getUserById(receiverId); //requestor
      final requestor =
          Provider.of<UserProvider>(context, listen: false).selectedUser;
      final admin =
          Provider.of<UserProvider>(context, listen: false).currentUser; //admin
      final groupData = await Provider.of<GroupProvider>(context, listen: false)
          .getGroupFuture(groupId, admin.id ?? ''); //group
      final groupRequest = (groupData.groupRequests ?? [])
          .firstWhere((e) => e.userId == requestor.id);
      await Provider.of<GroupProvider>(context, listen: false).acceptRequest(
          groupId,
          senderId,
          groupRequest.id ?? '',
          (requestor.firstName ?? '') + ' ' + (requestor.lastName ?? ''));
      await deleteNotification(notificationId);

      await Provider.of<NotificationProvider>(context, listen: false)
          .sendPushNotification(
              'Your request to join this group has been accepted.',
              NotificationType.accept_request,
              '${(groupData.group?.name?.sentenceCase() ?? '')}',
              admin.id ?? '',
              receiverId,
              'Request Accepted',
              '',
              groupData.group?.id ?? '',
              [requestor.pushToken ?? '']);
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
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
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
            onRefresh: () => getNotifications(user.id ?? ''),
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
    final allGroups = Provider.of<GroupProvider>(context).allGroups;
    final groupName = (allGroups
                .firstWhere(
                  (element) => element.group?.id == id,
                  orElse: () => CombineGroupUserStream.defaultValue(),
                )
                .group ??
            GroupModel.defaultValue())
        .name;
    return groupName;
  }

  Widget _buildRequestPanel(List<PushNotificationModel> requests) {
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
          ...requests.map((PushNotificationModel notification) {
            final userId = Provider.of<UserProvider>(context).currentUser.id;

            return Column(
              children: [
                SizedBox(height: 10),
                GestureDetector(
                  onLongPressEnd: null,
                  onTap: () => _showAlert(
                      notification.groupId ?? '',
                      notification.message ?? '',
                      notification.createdBy ?? '',
                      notification.id ?? '',
                      notification.createdBy ?? '',
                      groupName(
                          notification.groupId ?? '')), // todo: pass group name
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            (groupName(notification.groupId ??
                                                        '') ??
                                                    '')
                                                .sentenceCase(),
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
                                                  notification.createdOn ??
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

  Widget _buildUserLeftPanel(List<PushNotificationModel> leftGroup) {
    final userId = Provider.of<UserProvider>(context).currentUser.id;
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
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(
                                                  (groupName(notification
                                                                  .groupId ??
                                                              '') ??
                                                          '')
                                                      .sentenceCase(),
                                                  style: AppTextStyles
                                                      .regularText15b
                                                      .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    DateFormat('MM.dd.yyyy')
                                                        .format(notification
                                                                .createdOn ??
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

  Widget _buildUserJoinPanel(List<PushNotificationModel> joinGroup) {
    final userId = Provider.of<UserProvider>(context).currentUser.id;
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
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(
                                                  (groupName(notification
                                                                  .groupId ??
                                                              '') ??
                                                          '')
                                                      .sentenceCase(),
                                                  style: AppTextStyles
                                                      .regularText15b
                                                      .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    DateFormat('MM.dd.yyyy')
                                                        .format(notification
                                                                .createdOn ??
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

  Widget _buildRequestAcceptedPanel(
      List<PushNotificationModel> requestAccepted) {
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
              ...requestAccepted.map((PushNotificationModel notification) {
                final userId =
                    Provider.of<UserProvider>(context).currentUser.id;
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
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              notification.sender != ''
                                                  ? Expanded(
                                                      child: Text(
                                                        notification.sender
                                                                ?.sentenceCase() ??
                                                            '',
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
                                                                .createdOn ??
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
      List<PushNotificationModel> inappropriateContent) {
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
              ...inappropriateContent.map((PushNotificationModel notification) {
                final userId =
                    Provider.of<UserProvider>(context).currentUser.id;
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
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            notification.sender != ''
                                                ? Expanded(
                                                    child: Text(
                                                        notification.sender ??
                                                            '',
                                                        style: AppTextStyles
                                                            .regularText15b
                                                            .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4,
                                                        ),
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
                                                              .createdOn ??
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

  Widget _buildNewPrayersPanel(List<PushNotificationModel> newPrayers) {
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
              ...newPrayers.map((PushNotificationModel notification) {
                final userId =
                    Provider.of<UserProvider>(context).currentUser.id;
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
                                              notification.sender != ''
                                                  ? Expanded(
                                                      child: Text(
                                                        (groupName(notification
                                                                        .groupId ??
                                                                    '') ??
                                                                '')
                                                            .sentenceCase(),
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
                                                                .createdOn ??
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
                                        '${notification.sender} added a new prayer to the group.',
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

  Widget _buildEditedPrayersPanel(List<PushNotificationModel> editedPrayers) {
    final userId = Provider.of<UserProvider>(context).currentUser.id;
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
                                              notification.sender != ''
                                                  ? Expanded(
                                                      child: Text(
                                                        notification.sender ??
                                                            '',
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
                                                              '')
                                                          .sentenceCase(),
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
                                                                .createdOn ??
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

  Widget _buildArchivedPrayersPanel(
      List<PushNotificationModel> archivedPrayers) {
    final userId = Provider.of<UserProvider>(context).currentUser.id;
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
                                              notification.sender != ''
                                                  ? Expanded(
                                                      child: Text(
                                                        notification.sender ??
                                                            '',
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
                                                              '')
                                                          .sentenceCase(),
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
                                                                .createdOn ??
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

  Widget _buildAnsweredPrayersPanel(
      List<PushNotificationModel> answeredPrayers) {
    final userId = Provider.of<UserProvider>(context).currentUser.id;
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
                                              notification.sender != ''
                                                  ? Expanded(
                                                      child: Text(
                                                        notification.sender ??
                                                            '',
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
                                                              '')
                                                          .sentenceCase(),
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
                                                                .createdOn ??
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

  Widget _buildPrayerUpdatesPanel(List<PushNotificationModel> prayerUpdates) {
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
              ...prayerUpdates.map((PushNotificationModel notification) {
                final userId =
                    Provider.of<UserProvider>(context).currentUser.id;
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
                                              notification.sender != ''
                                                  ? Expanded(
                                                      child: Text(
                                                        notification.sender ??
                                                            '',
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
                                                              '')
                                                          .sentenceCase(),
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
                                                                .createdOn ??
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

  Widget _buildPanel() {
    final requests = Provider.of<NotificationProvider>(context).requests;
    final newPrayers = Provider.of<NotificationProvider>(context).newPrayers;
    final requestAccepted =
        Provider.of<NotificationProvider>(context).requestAccepted;
    final editedPrayers =
        Provider.of<NotificationProvider>(context).editedPrayers;
    final archivedPrayers =
        Provider.of<NotificationProvider>(context).archivedPrayers;
    final answeredPrayers =
        Provider.of<NotificationProvider>(context).answeredPrayers;
    final inappropriateContent =
        Provider.of<NotificationProvider>(context).inappropriateContent;
    final prayerUpdates =
        Provider.of<NotificationProvider>(context).prayerUpdates;
    final leftGroup = Provider.of<NotificationProvider>(context).leftGroup;
    final joinGroup = Provider.of<NotificationProvider>(context).joinGroup;
    final data = Provider.of<NotificationProvider>(context).notifications;

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
          newPrayers.length > 0
              ? _buildNewPrayersPanel(newPrayers)
              : Container(),
          // remove.length > 0 ? _buildRemoveUserPanel(remove) : Container(),
          requestAccepted.length > 0
              ? _buildRequestAcceptedPanel(requestAccepted)
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
          prayerUpdates.length > 0
              ? _buildPrayerUpdatesPanel(prayerUpdates)
              : Container(),
          leftGroup.length > 0 ? _buildUserLeftPanel(leftGroup) : Container(),
          joinGroup.length > 0 ? _buildUserJoinPanel(joinGroup) : Container()
        ],
      ),
    );
  }
}
