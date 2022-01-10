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
import 'package:be_still/screens/notifications/widgets/notification_bar.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_expansion_tile.dart' as custom;
import 'package:flutter/cupertino.dart';
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
  BuildContext bcontext;
  final SlidableController slidableController = SlidableController();

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _setCurrentIndex(int index, bool animate) async {
  //   await Provider.of<MiscProvider>(context, listen: false)
  //       .setCurrentPage(index);
  //   Navigator.of(context).push(MaterialPageRoute(builder: (_) {
  //     return EntryScreen();
  //   }));
  // }

  void _getNotifications() async {
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<NotificationProvider>(context, listen: false)
          .setUserNotifications(_user?.id);
      // await Provider.of<GroupProvider>(context, listen: false)
      //     .setUserGroups(_user.id);
    } on HttpException catch (_) {
    } catch (e) {}
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // getUserGroupsData();
      _getNotifications();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  // getUserGroupsData() async {
  //   final userId = Provider.of<UserProvider>(context).currentUser.id;
  //   await Provider.of<GroupProvider>(context, listen: false)
  //       .setUserGroups(userId);
  // }

  void _showAlert(String groupId, String message, String senderId,
      String notificationId, String receiverId, GroupModel group) {
    _getNotifications();
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
                    Text(message.capitalizeFirst,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regularText16b.copyWith(
                            color: AppColors.lightBlue4,
                            fontWeight: FontWeight.w500)),
                    Text(group.name,
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
    await Provider.of<NotificationProvider>(context, listen: false)
        .updateNotification(id);
  }

  //fittedBox fix: BoxFit.cont

  gotoPrayer(PushNotificationModel notification) async {
    BeStilDialog.showLoading(context);
    var userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    if (notification.groupId.isNotEmpty)
      await Provider.of<GroupProvider>(context, listen: false)
          .setCurrentGroupById(notification.groupId, userId);
    await Provider.of<GroupPrayerProvider>(context, listen: false)
        .setPrayerFuture(notification.prayerId)
        .then((value) async {
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .setPrayerFuture(notification.prayerId);
      AppCOntroller appCOntroller = Get.find();
      appCOntroller.setCurrentPage(9, true);
      await deleteNotification(notification.id);
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
    });
  }

  Future<void> denyRequest(
      String groupId, String notificationId, String receiverId) async {
    try {
      BeStilDialog.showLoading(context);
      final requestor = await Provider.of<UserProvider>(context, listen: false)
          .getUserById(receiverId); //requestor
      final admin =
          Provider.of<UserProvider>(context, listen: false).currentUser; //admin
      final groupData = await Provider.of<GroupProvider>(context, listen: false)
          .getGroupFuture(groupId, admin.id); //group
      final groupRequest =
          groupData.groupRequests.firstWhere((e) => e.userId == requestor.id);
      await Provider.of<GroupProvider>(context, listen: false)
          .denyRequest(groupId, groupRequest.id);

      deleteNotification(notificationId);
      Navigator.of(context).pop();
      BeStilDialog.hideLoading(context);
    } catch (e) {
      print(e.toString());
      BeStilDialog.hideLoading(context);
    }
  }

  Future<void> acceptRequest(String groupId, String senderId,
      String notificationId, String receiverId) async {
    BeStilDialog.showLoading(context);
    try {
      final requestor = await Provider.of<UserProvider>(context, listen: false)
          .getUserById(receiverId); //requestor
      final admin =
          Provider.of<UserProvider>(context, listen: false).currentUser; //admin
      final groupData = await Provider.of<GroupProvider>(context, listen: false)
          .getGroupFuture(groupId, admin.id); //group
      final groupRequest =
          groupData.groupRequests.firstWhere((e) => e.userId == requestor.id);
      await Provider.of<GroupProvider>(context, listen: false).acceptRequest(
          groupId,
          senderId,
          groupRequest.id,
          requestor.firstName + ' ' + requestor.lastName);
      await deleteNotification(notificationId);
      await Provider.of<NotificationProvider>(context, listen: false)
          .sendPushNotification(
              'Your request to join this group has been accepted.',
              NotificationType.accept_request,
              admin.firstName,
              admin.id,
              receiverId,
              'Request Accepted',
              '',
              groupData.group.id,
              [requestor.pushToken]);
      Navigator.of(context).pop();
      BeStilDialog.hideLoading(context);
    } catch (e) {
      BeStilDialog.hideLoading(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() => this.bcontext = context);
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
            ),
          ),
          child: SingleChildScrollView(
            child: _buildPanel(),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestPanel(requests) {
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
            return FutureBuilder<CombineGroupUserStream>(
                future: Provider.of<GroupProvider>(context)
                    .getGroupFuture(notification.groupId, userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.hasError)
                    return SizedBox.shrink();
                  else
                    return Column(
                      children: [
                        SizedBox(height: 10),
                        GestureDetector(
                          onLongPressEnd: null,
                          onTap: () => _showAlert(
                              notification.groupId,
                              notification.message,
                              notification.createdBy,
                              notification.id,
                              notification.createdBy,
                              snapshot.data.group),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                notification.sender != ''
                                                    ? Text(
                                                        snapshot.data.group.name
                                                            .toUpperCase(),
                                                        style: AppTextStyles
                                                            .regularText15b
                                                            .copyWith(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .lightBlue4,
                                                        ),
                                                      )
                                                    : Container(),
                                                if (notification
                                                    .groupId.isEmpty)
                                                  Text(
                                                    DateFormat('MM.dd.yyyy')
                                                        .format(notification
                                                            .createdOn),
                                                    style: AppTextStyles
                                                        .regularText15b
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .lightBlue4),
                                                  )
                                                else
                                                  FutureBuilder<
                                                          CombineGroupUserStream>(
                                                      future: Provider.of<
                                                                  GroupProvider>(
                                                              context)
                                                          .getGroupFuture(
                                                              notification
                                                                  .groupId,
                                                              userId),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (!snapshot.hasData)
                                                          return SizedBox
                                                              .shrink();
                                                        return Row(
                                                          children: <Widget>[
                                                            // Text(
                                                            //   snapshot.data
                                                            //       .group.name,
                                                            //   style: AppTextStyles
                                                            //       .regularText15b
                                                            //       .copyWith(
                                                            //     fontSize: 14,
                                                            //     color: AppColors
                                                            //         .red,
                                                            //   ),
                                                            // ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 10,
                                                              ),
                                                              child: Text(
                                                                '|',
                                                                style: TextStyle(
                                                                    color: AppColors
                                                                        .cardBorder),
                                                              ),
                                                            ),
                                                            Text(
                                                              DateFormat(
                                                                      'MM.dd.yyyy')
                                                                  .format(notification
                                                                      .createdOn),
                                                              style: AppTextStyles
                                                                  .regularText15b
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      color: AppColors
                                                                          .lightBlue4),
                                                            ),
                                                          ],
                                                        );
                                                      })
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
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: Text(
                                          notification.message.capitalizeFirst
                                              .substring(0,
                                                  notification.message.length),
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
                        SizedBox(height: 10),
                      ],
                    );
                });
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNewPrayersPanel(newPrayers) {
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
                return FutureBuilder<CombineGroupUserStream>(
                    future: Provider.of<GroupProvider>(context)
                        .getGroupFuture(notification.groupId, userId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.hasError)
                        return SizedBox.shrink();
                      else
                        return Column(
                          children: [
                            SizedBox(height: 10),
                            Dismissible(
                              key: Key(notification.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                deleteNotification(notification.id);
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
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      notification.sender != ''
                                                          ? Text(
                                                              notification
                                                                  .sender,
                                                              style: AppTextStyles
                                                                  .regularText15b
                                                                  .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .lightBlue4,
                                                              ),
                                                            )
                                                          : Container(),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            snapshot.data.group
                                                                .name,
                                                            style: AppTextStyles
                                                                .regularText15b
                                                                .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .lightBlue4,
                                                            ),
                                                          ),
                                                        ],
                                                      )
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              child: Text(
                                                notification.message.length > 99
                                                    ? notification.message
                                                        .substring(0, 100)
                                                    : notification.message,
                                                style: AppTextStyles
                                                    .regularText16b
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
                    });
              }).toList(),
            ]));
  }

  Widget _buildRemoveUserPanel(remove) {
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
                NotificationType.remove_from_group,
                textAlign: TextAlign.center,
                style: AppTextStyles.boldText24.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            initiallyExpanded: true,
            children: <Widget>[
              ...remove
                  .map((PushNotificationModel notification) => Column(
                        children: [
                          SizedBox(height: 10),
                          Dismissible(
                            key: Key(notification.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              deleteNotification(notification.id);
                            },
                            child: GestureDetector(
                              onLongPressEnd: null,
                              onTap: () {
                                deleteNotification(notification.id);
                                Navigator.pop(context);
                                AppCOntroller appCOntroller = Get.find();
                                appCOntroller.setCurrentPage(3, true);
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    notification.sender != ''
                                                        ? Text(
                                                            notification.sender,
                                                            style: AppTextStyles
                                                                .regularText15b
                                                                .copyWith(
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .lightBlue4,
                                                            ),
                                                          )
                                                        : Container(),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          '',
                                                          style: AppTextStyles
                                                              .regularText15b
                                                              .copyWith(
                                                            fontSize: 14,
                                                            color:
                                                                AppColors.red,
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 10,
                                                          ),
                                                          child: Text(
                                                            '|',
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .cardBorder),
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                                  'MM.dd.yyyy')
                                                              .format(notification
                                                                  .createdOn),
                                                          style: AppTextStyles
                                                              .regularText15b
                                                              .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .prayerMenuColor,
                                                          ),
                                                        ),
                                                      ],
                                                    )
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            child: Text(
                                              notification.message.length > 99
                                                  ? notification.message
                                                      .substring(0, 100)
                                                  : notification.message,
                                              style: AppTextStyles
                                                  .regularText16b
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
                      ))
                  .toList(),
            ]));
  }

  Widget _buildUserLeftPanel(leftGroup) {
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
              ...leftGroup
                  .map((notification) => Column(
                        children: [
                          SizedBox(height: 10),
                          Dismissible(
                            key: Key(notification.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              deleteNotification(notification.id);
                            },
                            child: GestureDetector(
                              onLongPressEnd: null,
                              onTap: () async {
                                deleteNotification(notification.id);
                                Navigator.pop(context);
                                AppCOntroller appCOntroller = Get.find();
                                appCOntroller.setCurrentPage(3, true);
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    notification.sender != ''
                                                        ? Text(
                                                            notification.sender,
                                                            style: AppTextStyles
                                                                .regularText15b
                                                                .copyWith(
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .lightBlue4,
                                                            ),
                                                          )
                                                        : Container(),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          '',
                                                          style: AppTextStyles
                                                              .regularText15b
                                                              .copyWith(
                                                            fontSize: 14,
                                                            color:
                                                                AppColors.red,
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 10,
                                                          ),
                                                          child: Text(
                                                            '|',
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .cardBorder),
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                                  'MM.dd.yyyy')
                                                              .format(notification
                                                                  .createdOn),
                                                          style: AppTextStyles
                                                              .regularText15b
                                                              .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .prayerMenuColor,
                                                          ),
                                                        ),
                                                      ],
                                                    )
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            child: Text(
                                              notification.message.length > 99
                                                  ? notification.message
                                                      .substring(0, 100)
                                                  : notification.message,
                                              style: AppTextStyles
                                                  .regularText16b
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
                      ))
                  .toList(),
            ]));
  }

  Widget _buildRequestAcceptedPanel(requestAccepted) {
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
                return FutureBuilder<CombineGroupUserStream>(
                    future: Provider.of<GroupProvider>(context)
                        .getGroupFuture(notification.groupId, userId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.hasError)
                        return SizedBox.shrink();
                      else
                        return Column(
                          children: [
                            SizedBox(height: 10),
                            Dismissible(
                              key: Key(notification.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                deleteNotification(notification.id);
                              },
                              child: GestureDetector(
                                onLongPressEnd: null,
                                onTap: () {
                                  deleteNotification(notification.id);
                                  // service get group by id
                                  // go to 8
                                  Navigator.pop(context);
                                  AppCOntroller appCOntroller = Get.find();
                                  appCOntroller.setCurrentPage(3, true);
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
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      notification.sender != ''
                                                          ? Text(
                                                              snapshot.data
                                                                  .group.name,
                                                              style: AppTextStyles
                                                                  .regularText15b
                                                                  .copyWith(
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .lightBlue4,
                                                              ),
                                                            )
                                                          : Container(),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            '',
                                                            style: AppTextStyles
                                                                .regularText15b
                                                                .copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  AppColors.red,
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 10,
                                                            ),
                                                            child: Text(
                                                              '|',
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .cardBorder),
                                                            ),
                                                          ),
                                                          Text(
                                                            DateFormat(
                                                                    'MM.dd.yyyy')
                                                                .format(notification
                                                                    .createdOn),
                                                            style: AppTextStyles
                                                                .regularText15b
                                                                .copyWith(
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .prayerMenuColor,
                                                            ),
                                                          ),
                                                        ],
                                                      )
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              child: Text(
                                                notification.message.length > 99
                                                    ? notification.message
                                                        .substring(0, 100)
                                                    : notification.message,
                                                style: AppTextStyles
                                                    .regularText16b
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
                    });
              }).toList(),
            ]));
  }

  Widget _buildRequestDeniedPanel(requestDenied) {
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
              ...requestDenied
                  .map((notification) => Column(
                        children: [
                          SizedBox(height: 10),
                          Dismissible(
                            key: Key(notification.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              deleteNotification(notification.id);
                            },
                            child: GestureDetector(
                              onLongPressEnd: null,
                              onTap: () {
                                deleteNotification(notification.id);
                                Navigator.pop(context);
                                AppCOntroller appCOntroller = Get.find();
                                appCOntroller.setCurrentPage(3, true);
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    notification.sender != ''
                                                        ? Text(
                                                            notification.sender,
                                                            style: AppTextStyles
                                                                .regularText15b
                                                                .copyWith(
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .lightBlue4,
                                                            ),
                                                          )
                                                        : Container(),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          '',
                                                          style: AppTextStyles
                                                              .regularText15b
                                                              .copyWith(
                                                            fontSize: 14,
                                                            color:
                                                                AppColors.red,
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 10,
                                                          ),
                                                          child: Text(
                                                            '|',
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .cardBorder),
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                                  'MM.dd.yyyy')
                                                              .format(notification
                                                                  .createdOn),
                                                          style: AppTextStyles
                                                              .regularText15b
                                                              .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .prayerMenuColor,
                                                          ),
                                                        ),
                                                      ],
                                                    )
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            child: Text(
                                              notification.message.length > 99
                                                  ? notification.message
                                                      .substring(0, 100)
                                                  : notification.message,
                                              style: AppTextStyles
                                                  .regularText16b
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
                      ))
                  .toList(),
            ]));
  }

  Widget _buildInapproriateContentPanel(inappropriateContent) {
    // var groupName = Provider.of<GroupProvider>(context,listen: false).setCurrentGroupById()
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
                return Column(
                  children: [
                    SizedBox(height: 10),
                    Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        deleteNotification(notification.id);
                      },
                      child: GestureDetector(
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
                                                  ? Text(
                                                      notification.sender,
                                                      style: AppTextStyles
                                                          .regularText15b
                                                          .copyWith(
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .lightBlue4,
                                                      ),
                                                    )
                                                  : Container(),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    '',
                                                    style: AppTextStyles
                                                        .regularText15b
                                                        .copyWith(
                                                      fontSize: 14,
                                                      color: AppColors.red,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                    child: Text(
                                                      '|',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .cardBorder),
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat('MM.dd.yyyy')
                                                        .format(notification
                                                            .createdOn),
                                                    style: AppTextStyles
                                                        .regularText15b
                                                        .copyWith(
                                                      fontSize: 14,
                                                      color: AppColors
                                                          .prayerMenuColor,
                                                    ),
                                                  ),
                                                ],
                                              )
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
                                        notification.message.length > 99
                                            ? notification.message
                                                .substring(0, 100)
                                            : notification.message,
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

  Widget _buildPrayerUpdatesPanel(prayerUpdates) {
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
                return FutureBuilder<CombineGroupUserStream>(
                    future: Provider.of<GroupProvider>(context)
                        .getGroupFuture(notification.groupId, userId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.hasError)
                        return SizedBox.shrink();
                      else
                        return Column(
                          children: [
                            SizedBox(height: 10),
                            Dismissible(
                              key: Key(notification.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                deleteNotification(notification.id);
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
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      notification.sender != ''
                                                          ? Text(
                                                              notification
                                                                  .sender,
                                                              style: AppTextStyles
                                                                  .regularText15b
                                                                  .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .lightBlue4,
                                                              ),
                                                            )
                                                          : Container(),
                                                      Row(
                                                        children: <Widget>[
                                                          Text(
                                                            snapshot.data.group
                                                                .name,
                                                            style: AppTextStyles
                                                                .regularText15b
                                                                .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .lightBlue4,
                                                            ),
                                                          ),
                                                        ],
                                                      )
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              child: Text(
                                                notification.message.length > 99
                                                    ? notification.message
                                                        .substring(0, 100)
                                                    : notification.message,
                                                style: AppTextStyles
                                                    .regularText16b
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
                    });
              }).toList(),
            ]));
  }

  Widget _buildPanel() {
    final data = Provider.of<NotificationProvider>(context).notifications;

    data.sort((a, b) => b.createdOn.compareTo(a.createdOn));
    final requests =
        data.where((e) => e.messageType == NotificationType.request).toList();

    final newPrayers =
        data.where((e) => e.messageType == NotificationType.prayer).toList();
    final remove = data
        .where((e) => e.messageType == NotificationType.remove_from_group)
        .toList();
    final requestAccepted = data
        .where((e) => e.messageType == NotificationType.accept_request)
        .toList();
    final requestDenied = data
        .where((e) => e.messageType == NotificationType.deny_request)
        .toList();

    final inappropriateContent = data
        .where((e) => e.messageType == NotificationType.inappropriate_content)
        .toList();
    final prayerUpdates = data
        .where((e) => e.messageType == NotificationType.prayer_updates)
        .toList();
    final leftGroup = data
        .where((e) => e.messageType == NotificationType.leave_group)
        .toList();

    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(height: 40),
          data.length == 0
              ? Container(
                  padding: EdgeInsets.only(right: 20, left: 20),
                  child: Text(
                    'You do not have any notifications',
                    style: AppTextStyles.demiboldText34,
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(),
          requests.length > 0 ? _buildRequestPanel(requests) : Container(),
          newPrayers.length > 0
              ? _buildNewPrayersPanel(newPrayers)
              : Container(),
          remove.length > 0 ? _buildRemoveUserPanel(remove) : Container(),
          requestAccepted.length > 0
              ? _buildRequestAcceptedPanel(requestAccepted)
              : Container(),
          requestDenied.length > 0
              ? _buildRequestDeniedPanel(requestDenied)
              : Container(),
          inappropriateContent.length > 0
              ? _buildInapproriateContentPanel(inappropriateContent)
              : Container(),
          prayerUpdates.length > 0
              ? _buildPrayerUpdatesPanel(prayerUpdates)
              : Container(),
          leftGroup.length > 0 ? _buildUserLeftPanel(leftGroup) : Container()
        ],
      ),
    );
  }
}
