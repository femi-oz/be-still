import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupCard extends StatefulWidget {
  final CombineGroupUserStream groupData;

  GroupCard(this.groupData) : super();

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  void initState() {
    super.initState();
  }

  _requestToJoinGroup(CombineGroupUserStream groupData, String userId,
      String status, String userName, String adminId) async {
    const title = 'Group Request';
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<GroupProvider>(context, listen: false)
          .joinRequest(groupData.group.id, userId, status, userName);
      await Provider.of<NotificationProvider>(context, listen: false)
          .addPushNotification(
              '$userName has requested to join your group',
              NotificationType.request,
              userName,
              userId,
              adminId,
              title,
              groupData.group.id);
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      AppCOntroller appCOntroller = Get.find();
      appCOntroller.setCurrentPage(3, true);
    } catch (e) {
      BeStilDialog.hideLoading(context);
    }
  }

  Future<void> _joinGroup(String groupId) async {
    BeStilDialog.showLoading(context);
    try {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<GroupProvider>(context, listen: false).autoJoinGroup(
          groupId, user.id, user.firstName + ' ' + user.lastName);
      Navigator.of(context).pop();
      AppCOntroller appCOntroller = Get.find();
      appCOntroller.setCurrentPage(3, true);
      BeStilDialog.hideLoading(context);
    } catch (e) {
      BeStilDialog.hideLoading(context);
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

  void _showAlert() async {
    final admin = widget.groupData.groupUsers
        .firstWhere((e) => e.role == GroupUserRole.admin);
    await Provider.of<UserProvider>(context, listen: false)
        .getUserById(admin.userId);
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      final adminData =
          Provider.of<UserProvider>(context, listen: false).selectedUser;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      icon: Icon(AppIcons.bestill_close),
                    )
                  ],
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        this.widget.groupData.group.name.toUpperCase(),
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
                                  '${this.widget.groupData.group.location}',
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
                              Text(
                                this.widget.groupData.group.organization.isEmpty
                                    ? 'N/A'
                                    : '${this.widget.groupData.group.organization}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
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
                            this.widget.groupData.groupUsers.length > 1 ||
                                    this.widget.groupData.groupUsers.length == 0
                                ? '${this.widget.groupData.groupUsers.length} current members'
                                : '${this.widget.groupData.groupUsers.length} current member',
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
                        this.widget.groupData.group.description.isEmpty
                            ? 'N/A'
                            : this.widget.groupData.group.description,
                        style: AppTextStyles.regularText15.copyWith(
                          color: AppColors.textFieldText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.0),
                      isRequestSent()
                          ? Container()
                          : Text(
                              'Would you like to request to join?',
                              style: AppTextStyles.regularText15.copyWith(
                                color: AppColors.textFieldText,
                              ),
                              textAlign: TextAlign.left,
                            ),
                      isRequestSent() ? Container() : SizedBox(height: 20.0),
                      isRequestSent()
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
                                          !widget.groupData.groupSettings
                                                  .requireAdminApproval
                                              ? 'JOIN'
                                              : 'REQUEST',
                                          style: AppTextStyles.boldText20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    if (!widget.groupData.groupSettings
                                        .requireAdminApproval) {
                                      _joinGroup(widget.groupData.group.id);
                                    } else {
                                      _requestToJoinGroup(
                                        this.widget.groupData,
                                        Provider.of<UserProvider>(context,
                                                listen: false)
                                            .currentUser
                                            .id,
                                        StringUtils.joinRequestStatusPending,
                                        '${Provider.of<UserProvider>(context, listen: false).currentUser.firstName + ' ' + Provider.of<UserProvider>(context, listen: false).currentUser.lastName}',
                                        adminData.id,
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

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return dialog;
          });
    });
  }

  bool isRequestSent() {
    var currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    var requestPending = widget.groupData.groupRequests.where((element) =>
        element.status == StringUtils.joinRequestStatusPending &&
        element.userId == currentUser.id);
    if (requestPending.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showAlert,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 7.0),
        decoration: BoxDecoration(
          color:
              Settings.isDarkMode ? AppColors.darkBlue : AppColors.lightBlue4,
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      this.widget.groupData.group.name.toUpperCase(),
                      style:
                          TextStyle(color: AppColors.lightBlue3, fontSize: 12),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${this.widget.groupData.group.location}'.toUpperCase(),
                    style: TextStyle(color: AppColors.lightBlue4, fontSize: 10),
                    textAlign: TextAlign.left,
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
