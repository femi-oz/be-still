import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/settings_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:be_still/widgets//custom_expansion_tile.dart' as custom;
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'group_privilege.dart';

class GroupsSettings extends StatefulWidget {
  @override
  _GroupsSettingsState createState() => _GroupsSettingsState();
}

class _GroupsSettingsState extends State<GroupsSettings> {
  final f = new DateFormat('yyyy-MM-dd');
  FirebaseMessaging messaging;

  _removeUserFromGroup(
      GroupUserModel user, CombineGroupUserStream group) async {
    var userData =
        Provider.of<UserProvider>(context, listen: false).selectedUser;
    final message = 'You have removed the user from your group';
    final _currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    final userName =
        ('${_currentUser.firstName}  ${_currentUser.lastName}').capitalizeFirst;
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<GroupProvider>(context, listen: false)
          .deleteFromGroup(user.userId, user.groupId);
      sendPushNotification(
          '$userName has removed you from ${group.group.name}',
          NotificationType.remove_from_group,
          userName,
          _currentUser.id,
          user.userId,
          'Remove from group',
          group.group.id);

      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      Navigator.pop(context);
      BeStilDialog.showSuccessDialog(context, message);
    } on HttpException catch (_) {
    } catch (e) {}
  }

  leaveGroup(CombineGroupUserStream data) async {
    final _currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;

    var receiver = data.groupUsers
        .firstWhere((element) => element.role == GroupUserRole.admin);
    final id = data.groupUsers
        .firstWhere((e) => e.userId == _currentUser.id, orElse: () => null)
        .id;
    if (id != null) {
      BeStilDialog.showLoading(context, '');
      await Provider.of<GroupProvider>(context, listen: false).leaveGroup(id);
      sendPushNotification(
          '${_currentUser.firstName} has left your group ${data.group.name}',
          NotificationType.leave_group,
          _currentUser.firstName,
          _currentUser.id,
          receiver.userId,
          'Groups',
          data.group.id);
      Navigator.pop(context);
      BeStilDialog.hideLoading(context);
    }
  }

  deleteGroup(CombineGroupUserStream data) async {
    BeStilDialog.showLoading(context, '');
    Provider.of<GroupProvider>(context, listen: false)
        .deleteGroup(data.group.id);
    await Future.delayed(Duration(milliseconds: 300));
    Navigator.pop(context);
    BeStilDialog.hideLoading(context);
  }

  sendPushNotification(message, messageType, sender, senderId, receiverId,
      title, entityId) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .addPushNotification(message, messageType, sender, senderId, receiverId,
            title, entityId);
  }

  void _showAlert(GroupUserModel user, CombineGroupUserStream group) async {
    bool userIsAdmin;
    UserModel userData;

    setState(() {
      final _currentUser =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      userIsAdmin =
          user.userId == _currentUser.id && user.role == GroupUserRole.admin
              ? true
              : false;

      userData = Provider.of<UserProvider>(context, listen: false).selectedUser;
    });

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
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          user.email ?? '',
                          style: TextStyle(
                              color: AppColors.textFieldText,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              height: 1.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                          'Has been a member since ${f.format(user.createdOn)}',
                          style: TextStyle(
                              color: AppColors.textFieldText,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              height: 1.5),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                color: user.role == GroupUserRole.admin
                                    ? AppColors.activeButton.withOpacity(0.3)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: AppColors.darkBlue,
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
                                      'ADMIN',
                                      style: TextStyle(
                                          color: AppColors.lightBlue3,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      barrierColor: AppColors
                                          .detailBackgroundColor[1]
                                          .withOpacity(0.5),
                                      backgroundColor: AppColors
                                          .detailBackgroundColor[1]
                                          .withOpacity(0.9),
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return GroupPrivilegeSettings(
                                            'admin', user);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              height: 30,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                color: user.role == GroupUserRole.moderator
                                    ? AppColors.activeButton.withOpacity(0.3)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: AppColors.darkBlue,
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
                                      'MODERATOR',
                                      style: TextStyle(
                                          color: AppColors.lightBlue3,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      barrierColor: AppColors
                                          .detailBackgroundColor[1]
                                          .withOpacity(0.5),
                                      backgroundColor: AppColors
                                          .detailBackgroundColor[1]
                                          .withOpacity(0.9),
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return GroupPrivilegeSettings(
                                            'moderator', user);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              height: 30,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                color: user.role == GroupUserRole.member
                                    ? AppColors.activeButton.withOpacity(0.3)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: AppColors.darkBlue,
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
                                      'MEMBER',
                                      style: TextStyle(
                                          color: AppColors.lightBlue3,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      barrierColor: AppColors
                                          .detailBackgroundColor[1]
                                          .withOpacity(0.5),
                                      backgroundColor: AppColors
                                          .detailBackgroundColor[1]
                                          .withOpacity(0.9),
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return GroupPrivilegeSettings(
                                            'member', user);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      !userIsAdmin
                          ? Container(
                              height: 30,
                              margin: EdgeInsets.only(top: 40, bottom: 0),
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
                                    const method = 'Remove';
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
                      width: MediaQuery.of(context).size.width * .28,
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
                      width: MediaQuery.of(context).size.width * .28,
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
                      width: MediaQuery.of(context).size.width * .28,
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
                      width: MediaQuery.of(context).size.width * .28,
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
    data.groupUsers.forEach((element) {
      Provider.of<UserProvider>(context, listen: false)
          .getUserById(element.userId);
    });
    return Provider.of<UserProvider>(context, listen: false)
        .selectedUser
        .lastName;
  }

  void _sendInvite(String groupName, String groupId) async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showLoading(context);
      await Provider.of<GroupProvider>(context, listen: false).inviteMember(
          groupName,
          groupId,
          _emailController.text,
          '${_user.firstName} ${_user.lastName}',
          _user.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      _emailController.text = '';
    } catch (e) {
      // BeStilDialog.showErrorDialog(context, e.message.toString());
    }
  }

  TextEditingController _emailController = new TextEditingController();
  bool _inviteMode = false;
  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    final _groups = Provider.of<GroupProvider>(context).userGroups;
    final _settingsProvider = Provider.of<SettingsProvider>(context);
    final _groupSettings = Provider.of<SettingsProvider>(context).groupSettings;
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
              title: 'Enable notifications from Groups?',
              onChange: (value) async {
                _settingsProvider.updateGroupPrefenceSettings(_currentUser.id,
                    key: 'EnableNotificationForAllGroups',
                    value: value,
                    settingsId: _groupPreferenceSettings.id);

                if (value) {
                  messaging = FirebaseMessaging.instance;
                  messaging.getToken().then((value) => {
                        Provider.of<NotificationProvider>(context,
                                listen: false)
                            .enablePushNotifications(value, _currentUser.id)
                      });
                } else {
                  await Provider.of<NotificationProvider>(context,
                          listen: false)
                      .disablePushNotifications(_currentUser.id);
                }
              },
              value: _groupPreferenceSettings?.enableNotificationForAllGroups,
            ),
            Column(
              children: <Widget>[
                ..._groups.map((CombineGroupUserStream data) {
                  bool isAdmin = data.groupUsers
                          .firstWhere((g) => g.userId == _currentUser.id)
                          .role ==
                      GroupUserRole.admin;
                  bool isModerator = data.groupUsers
                          .firstWhere((g) => g.userId == _currentUser.id)
                          .role ==
                      GroupUserRole.moderator;
                  bool isMember = data.groupUsers
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
                          data.group.name.capitalizeFirst,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.boldText24
                              .copyWith(color: Colors.white70),
                        ),
                      ),
                      initiallyExpanded: false,
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
                                        data.group.description.isEmpty
                                            ? "N/A"
                                            : data.group.description,
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
                                    Text('Associated Church',
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
                                      data.group.organization.isEmpty
                                          ? "N/A"
                                          : data.group.organization,
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
                                        data.group.location,
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
                            CustomToggle(
                              title:
                                  'Enable notifications for New Prayers for this group?',
                              onChange: (value) => _settingsProvider
                                  .updateGroupSettings(_currentUser.id,
                                      key: 'EnableNotificationFormNewPrayers',
                                      value: value,
                                      settingsId: _groupSettings.id),
                              value: _groupSettings
                                  ?.enableNotificationFormNewPrayers,
                            ),
                            CustomToggle(
                              title:
                                  'Enable notifications for Prayer Updates for this group?',
                              onChange: (value) => _settingsProvider
                                  .updateGroupSettings(_currentUser.id,
                                      key: 'EnableNotificationForUpdates',
                                      value: value,
                                      settingsId: _groupSettings.id),
                              value:
                                  _groupSettings?.enableNotificationForUpdates,
                            ),
                            if (isMember)
                              CustomToggle(
                                title:
                                    'Notify me when new members joins this group',
                                onChange: (value) => _settingsProvider
                                    .updateGroupSettings(_currentUser.id,
                                        key: 'NotifyWhenNewMemberJoins',
                                        value: value,
                                        settingsId: _groupSettings.id),
                                value: _groupSettings?.notifyWhenNewMemberJoins,
                              ),
                            if (isAdmin || isModerator)
                              CustomToggle(
                                title: 'Notify me of membership requests',
                                onChange: (value) => _settingsProvider
                                    .updateGroupSettings(_currentUser.id,
                                        key: 'NotifyOfMembershipRequest',
                                        value: value,
                                        settingsId: _groupSettings.id),
                                value:
                                    _groupSettings?.notifyOfMembershipRequest,
                              ),
                            if (isAdmin || isModerator)
                              CustomToggle(
                                title: 'Notify me of flagged prayers',
                                onChange: (value) => _settingsProvider
                                    .updateGroupSettings(_currentUser.id,
                                        key: 'NotifyMeofFlaggedPrayers',
                                        value: value,
                                        settingsId: _groupSettings.id),
                                value: _groupSettings?.notifyMeofFlaggedPrayers,
                              ),
                          ],
                        ),
                        (isAdmin || isModerator)
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    child: Row(
                                      children: <Widget>[
                                        Text('Invite',
                                            style: AppTextStyles.regularText11),
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
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: GestureDetector(
                                          onTap: () => setState(
                                              () => _inviteMode = true),
                                          child: Text(
                                            'Send an invite to join group',
                                            style: AppTextStyles.regularText16b
                                                .copyWith(
                                                    color:
                                                        AppColors.lightBlue3),
                                          ),
                                        ),
                                      ),
                                      _inviteMode
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15.0,
                                                      horizontal: 20.0),
                                              child: Column(
                                                children: [
                                                  CustomInput(
                                                    textkey: GlobalKey<
                                                        FormFieldState>(),
                                                    label: 'Email Address',
                                                    controller:
                                                        _emailController,
                                                    isEmail: true,
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                          style: ButtonStyle(
                                                              textStyle: MaterialStateProperty.all<TextStyle>(
                                                                  AppTextStyles
                                                                      .boldText16
                                                                      .copyWith(
                                                                          color: Colors
                                                                              .white)),
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<Color>(
                                                                      Colors.grey[
                                                                          700])),
                                                          onPressed: () => setState(
                                                              () => _inviteMode = false),
                                                          child: Text('Cancel', style: AppTextStyles.regularText14)),
                                                      SizedBox(width: 15),
                                                      TextButton(
                                                          style: ButtonStyle(
                                                            textStyle: MaterialStateProperty.all<
                                                                    TextStyle>(
                                                                AppTextStyles
                                                                    .boldText16
                                                                    .copyWith(
                                                                        color: Colors
                                                                            .white)),
                                                            backgroundColor:
                                                                MaterialStateProperty.all<
                                                                        Color>(
                                                                    AppColors
                                                                        .dimBlue),
                                                          ),
                                                          onPressed: () =>
                                                              _sendInvite(
                                                                  data.group
                                                                      .name,
                                                                  data.group
                                                                      .id),
                                                          child: Text(
                                                            'Send Invite',
                                                            style: AppTextStyles
                                                                .regularText14,
                                                          )),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container()
                                    ],
                                  )
                                ],
                              )
                            : Container(),
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
                                    children: <Widget>[
                                      Text(
                                          'Members | ${data.groupUsers.length}',
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
                                ),
                                initiallyExpanded: false,
                                // onExpansionChanged: (bool isExpanded) {
                                // },
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Column(
                                      children: <Widget>[
                                        ...data.groupUsers.map(
                                          (user) {
                                            return GestureDetector(
                                              onTap: () async {
                                                await Provider.of<UserProvider>(
                                                        context,
                                                        listen: false)
                                                    .getUserById(user.userId);
                                                Future.delayed(
                                                    Duration(milliseconds: 15),
                                                    () {
                                                  _showAlert(user, data);
                                                });
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
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(user.fullName ?? '',
                                                          style: AppTextStyles
                                                              .boldText14
                                                              .copyWith(
                                                                  color: AppColors
                                                                      .lightBlue4)),
                                                      Text(
                                                        user.role ==
                                                                GroupUserRole
                                                                    .admin
                                                            ? 'ADMIN'
                                                            : user.role ==
                                                                    GroupUserRole
                                                                        .moderator
                                                                ? 'MODERATOR'
                                                                : 'MEMBER',
                                                        style: AppTextStyles
                                                            .regularText14
                                                            .copyWith(
                                                                color: AppColors
                                                                    .lightBlue1),
                                                      ),
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
                                      'LEAVE',
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
                                      'Are you sure you want to delete this group';
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
