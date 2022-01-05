import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinGroup {
  void showAlert(BuildContext context, CombineGroupUserStream group) {
    final admin =
        group.groupUsers.firstWhere((e) => e.role == GroupUserRole.admin);
    Provider.of<UserProvider>(context, listen: false).getUserById(admin.userId);
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
                        group.group.name.toUpperCase(),
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
                              Text(
                                '${group.group.location}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                textAlign: TextAlign.center,
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
                                '${group.group.organization}',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Type: ',
                                style: AppTextStyles.regularText15,
                              ),
                              Text(
                                '${group.group.status} Group',
                                style: AppTextStyles.regularText15.copyWith(
                                  color: AppColors.textFieldText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),
                      Column(
                        children: [
                          Text(
                            group.groupUsers.length > 1 ||
                                    group.groupUsers.length == 0
                                ? '${group.groupUsers.length} current members'
                                : '${group.groupUsers.length} current member',
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
                        group.group.description,
                        style: AppTextStyles.regularText15.copyWith(
                          color: AppColors.textFieldText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.0),
                      Text(
                        'Would you like to request to join?',
                        style: AppTextStyles.regularText15.copyWith(
                          color: AppColors.textFieldText,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: AppColors.cardBorder,
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
                                    'REQUEST',
                                    style: AppTextStyles.boldText20,
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              _requestToJoinGroup(
                                  group,
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .currentUser
                                      .id,
                                  // StringUtils.joinRequestStatusPending,
                                  '${Provider.of<UserProvider>(context, listen: false).currentUser.firstName + ' ' + Provider.of<UserProvider>(context, listen: false).currentUser.lastName}',
                                  adminData.id,
                                  context);
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

  _requestToJoinGroup(
      CombineGroupUserStream groupData,
      String userId,
      // String status,
      String userName,
      String adminId,
      BuildContext context) async {
    const title = 'Group Request';
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<GroupProvider>(context, listen: false)
          .joinRequest(groupData.group.id, userId, userName);
      await Provider.of<UserProvider>(context, listen: false)
          .getUserById(adminId);
      final receiverData =
          Provider.of<UserProvider>(context, listen: false).selectedUser;
      await Provider.of<NotificationProvider>(context, listen: false)
          .sendPushNotification(
              '$userName has requested to join your group',
              NotificationType.request,
              userName,
              userId,
              adminId,
              title,
              '',
              groupData.group.id,
              [receiverData.pushToken]);
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
    } catch (e) {
      BeStilDialog.hideLoading(context);
    }
  }
}
