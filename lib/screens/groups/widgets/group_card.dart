import 'dart:io';
import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/request_status.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupCard extends StatefulWidget {
  final GroupDataModel groupData;

  GroupCard(this.groupData) : super();

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _requestToJoinGroup(GroupDataModel groupData, String userId,
      String userName, UserDataModel admin) async {
    try {
      BeStilDialog.showLoading(context);
      List<String> tokens = [];
      final devices = admin.devices ?? <DeviceModel>[];
      tokens = devices.map((e) => e.token ?? '').toList();
      String adminDataId = (groupData.users ?? <GroupUserDataModel>[])
              .firstWhere((element) => element.role == GroupUserRole.admin)
              .userId ??
          '';
      final _user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      await Provider.of<GroupProviderV2>(context, listen: false)
          .requestToJoinGroup(
              groupData.id ?? '',
              '$userName has requested to join your group',
              adminDataId,
              tokens,
              _user.groups ?? []);

      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      AppController appController = Get.find();
      appController.setCurrentPage(3, true, 11);
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

  Future<void> _joinGroup(GroupDataModel groupData, String userId,
      String userName, UserDataModel admin) async {
    BeStilDialog.showLoading(context);
    try {
      List<String> tokens = [];
      final devices = admin.devices ?? <DeviceModel>[];
      tokens = devices.map((e) => e.token ?? '').toList();

      await Provider.of<GroupProviderV2>(context, listen: false).autoJoinGroup(
        groupData,
        '$userName has joined your group',
      );

      await Provider.of<NotificationProviderV2>(context, listen: false)
          .sendPushNotification(
              '$userName has requested to join your group',
              NotificationType.request,
              groupData.name?.sentenceCase() ?? '',
              tokens,
              prayerId: '',
              groupId: groupData.id);

      Navigator.of(context).pop();
      AppController appController = Get.find();
      appController.setCurrentPage(3, true, 11);
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

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  bool isPressed = false;
  void _showAlert() async {
    if (isPressed) return;
    setState(() {
      isPressed = true;
    });
    final admin = (widget.groupData.users ?? [])
        .firstWhere((e) => e.role == GroupUserRole.admin);
    await Provider.of<UserProviderV2>(context, listen: false)
        .getUserDataById(admin.userId ?? '');
    UserDataModel adminData =
        Provider.of<UserProviderV2>(context, listen: false).selectedUser;

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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    icon: Icon(
                      AppIcons.bestill_close,
                      color: AppColors.grey4,
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      ((widget.groupData).name ?? '').toUpperCase(),
                      style: AppTextStyles.boldText20,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.0),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Admin: ',
                              style: AppTextStyles.regularText15,
                            ),
                            Flexible(
                              child: Text(
                                '${adminData.firstName} ${adminData.lastName}',
                                softWrap: true,
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Based in: ',
                              style: AppTextStyles.regularText15,
                            ),
                            Flexible(
                              child: Text(
                                '${this.widget.groupData.location}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Church: ',
                              style: AppTextStyles.regularText15,
                            ),
                            Expanded(
                              child: Text(
                                ((this.widget.groupData).organization ?? '')
                                        .isEmpty
                                    ? '-'
                                    : '${this.widget.groupData.organization}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       'Type: ',
                        //       style: AppTextStyles.regularText15,
                        //     ),
                        //     Text(
                        //       '${this.widget.groupData.group.status} Group',
                        //       style: AppTextStyles.regularText15.copyWith(
                        //         color: AppColors.textFieldText,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Column(
                      children: [
                        Text(
                          (this.widget.groupData.users ?? []).length > 1 ||
                                  (this.widget.groupData.users ?? []).length ==
                                      0
                              ? '${(this.widget.groupData.users ?? []).length} current members'
                              : '${(this.widget.groupData.users ?? []).length} current member',
                          style: AppTextStyles.regularText15.copyWith(
                            color: AppColors.textFieldText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5.0),
                        // Text(
                        //   '2 contacts',
                        //   style: AppTextStyles.regularText15.copyWith(
                        //     color: AppColors.textFieldText,
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                      ],
                    ),
                    SizedBox(height: 30.0),
                    Text(
                      ((this.widget.groupData).purpose ?? '').isEmpty
                          ? 'N/A'
                          : this.widget.groupData.purpose ?? '',
                      style: AppTextStyles.regularText15.copyWith(
                        color: AppColors.textFieldText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.0),
                    isRequestSent ||
                            !((widget.groupData).requireAdminApproval ?? false)
                        ? Container()
                        : Text(
                            'Would you like to request to join?',
                            style: AppTextStyles.regularText15.copyWith(
                              color: AppColors.textFieldText,
                            ),
                            textAlign: TextAlign.left,
                          ),
                    isRequestSent ? Container() : SizedBox(height: 20.0),
                    isRequestSent
                        ? Container(
                            child: Text(
                              StringUtils.joinRequestSent,
                              style: AppTextStyles.regularText15.copyWith(
                                color: AppColors.textFieldText,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          )
                        : Container(
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
                                style: ButtonStyle(
                                  side: MaterialStateProperty.all<BorderSide>(
                                      BorderSide(color: Colors.transparent)),
                                ),
                                child: Container(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        !((widget.groupData)
                                                    .requireAdminApproval ??
                                                false)
                                            ? 'JOIN'
                                            : 'REQUEST',
                                        style: AppTextStyles.boldText20,
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  if (!((widget.groupData)
                                          .requireAdminApproval ??
                                      false)) {
                                    _joinGroup(
                                      this.widget.groupData,
                                      FirebaseAuth.instance.currentUser?.uid ??
                                          '',
                                      '${(Provider.of<UserProviderV2>(context, listen: false).currentUser.firstName?.capitalizeFirst ?? '') + ' ' + (Provider.of<UserProviderV2>(context, listen: false).currentUser.lastName?.capitalizeFirst ?? '')}',
                                      adminData,
                                    );
                                  } else {
                                    _requestToJoinGroup(
                                      this.widget.groupData,
                                      Provider.of<UserProviderV2>(context,
                                                  listen: false)
                                              .currentUser
                                              .id ??
                                          '',
                                      '${(Provider.of<UserProviderV2>(context, listen: false).currentUser.firstName?.capitalizeFirst ?? '') + ' ' + (Provider.of<UserProviderV2>(context, listen: false).currentUser.lastName?.capitalizeFirst ?? '')}',
                                      adminData,
                                    );
                                  }
                                }),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
    setState(() {
      isPressed = false;
    });
  }

  bool get isRequestSent {
    return (widget.groupData.requests ?? []).any((element) =>
        element.userId == FirebaseAuth.instance.currentUser?.uid &&
        element.status == RequestStatus.pending);
  }

  @override
  Widget build(BuildContext context) {
    var currentUser =
        Provider.of<UserProviderV2>(context, listen: false).currentUser;
    return GestureDetector(
      onTap: (widget.groupData.users ?? [])
              .map((e) => e.userId)
              .contains(currentUser.id)
          ? null
          : _showAlert,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 7.0),
        decoration: BoxDecoration(
          color: Settings.isDarkMode
              ? AppColors.darkBlue.withOpacity((widget.groupData.users ?? [])
                      .map((e) => e.userId)
                      .contains(currentUser.id)
                  ? 0.5
                  : 1)
              : AppColors.lightBlue4.withOpacity((widget.groupData.users ?? [])
                      .map((e) => e.userId)
                      .contains(currentUser.id)
                  ? 0.5
                  : 1),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        child: Container(
          margin: EdgeInsetsDirectional.only(start: 1, bottom: 1, top: 1),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.prayerCardBgColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(9),
              topLeft: Radius.circular(9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      (this.widget.groupData).name ?? ''.toUpperCase(),
                      style: TextStyle(
                          color: AppColors.lightBlue3.withOpacity(
                              (widget.groupData.users ?? [])
                                      .map((e) => e.userId)
                                      .contains(currentUser.id)
                                  ? 0.5
                                  : 1),
                          fontSize: 12),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      '${this.widget.groupData.location}'.toUpperCase(),
                      style: TextStyle(
                          color: AppColors.lightBlue4.withOpacity(
                              (widget.groupData.users ?? [])
                                      .map((e) => e.userId)
                                      .contains(currentUser.id)
                                  ? 0.5
                                  : 1),
                          fontSize: 10),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
