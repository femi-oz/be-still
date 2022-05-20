import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> _changeMemberRole(GroupDataModel group, String userId) async {
    try {
      bool isCurrentUser =
          userId == FirebaseAuth.instance.currentUser?.uid ? true : false;

      final groupUserData =
          (group.users ?? []).firstWhere((element) => element.userId == userId);
      final newRole = groupUserData.role == GroupUserRole.moderator
          ? GroupUserRole.member
          : GroupUserRole.moderator;

      final message =
          isCurrentUser ? 'You are now a $newRole' : 'User is now a $newRole';

      BeStilDialog.showLoading(context);
      await Provider.of<GroupProviderV2>(context, listen: false)
          .editUserRole(groupUserData, newRole, group.id ?? '');
      BeStilDialog.hideLoading(context);
      if (!isCurrentUser) {
        Navigator.pop(context);
      }
      BeStilDialog.showSuccessDialog(context, message);
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

  Future<void> _removeUserFromGroup(String userId, String groupId) async {
    try {
      final message = 'You have removed the user from your group';

      BeStilDialog.showLoading(context);
      await Provider.of<GroupProviderV2>(context, listen: false)
          .removeGroupUser(userId, groupId);
      // await Provider.of<GroupProviderV2>(context, listen: false).setAllGroups();

      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      Navigator.pop(context);
      BeStilDialog.showSuccessDialog(context, message);
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

  _leaveGroup(GroupDataModel group) async {
    Navigator.pop(context);

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

      await _sendPushNotification(
        '$userName has left this group',
        NotificationType.leave_group,
        userName,
        _userId,
        [],
        adminData.id ?? '',
        groupId: group.id ?? '',
      );

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

  Future<void> _deleteGroup(GroupDataModel group) async {
    try {
      Navigator.pop(context);
      BeStilDialog.showLoading(context, '');
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      final notifications =
          Provider.of<NotificationProviderV2>(context, listen: false)
              .notifications
              .where((e) => e.groupId == group.id)
              .toList();

      await Provider.of<GroupProviderV2>(context, listen: false)
          .deleteGroup(group.id ?? '', notifications);
      await Provider.of<GroupProviderV2>(context, listen: false)
          .setUserGroups(user.groups ?? []);
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

  Future<void> _sendPushNotification(String message, String messageType,
      String sender, String title, List<String> tokens, String receiverId,
      {String? groupId, String? prayerId}) async {
    try {
      await Provider.of<NotificationProviderV2>(context, listen: false)
          .sendPushNotification(message, messageType, sender, tokens,
              groupId: groupId, prayerId: prayerId, receiverId: receiverId);
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

  void _showMemberAlert(
      String userId, GroupDataModel group, String role) async {
    bool currentUserIsAdmin = false;
    bool currentUserIsModerator = false;
    bool userIsAdmin = false;
    bool userIsModerator = false;
    bool showRemoveControl = false;
    bool showDemoteControl = false;
    UserDataModel user =
        await Provider.of<UserProviderV2>(context, listen: false)
            .getUserDataById(userId);

    final _currentUser =
        Provider.of<UserProviderV2>(context, listen: false).currentUser;
    final groupUserData = (group.users ?? []).firstWhere(
        (element) => element.userId == userId,
        orElse: () => GroupUserDataModel());
    currentUserIsAdmin = (group.users ?? []).any((element) =>
        element.userId == _currentUser.id &&
        element.role == GroupUserRole.admin);

    currentUserIsModerator = (group.users ?? []).any((element) =>
        element.userId == _currentUser.id &&
        element.role == GroupUserRole.moderator);

    userIsAdmin = groupUserData.role == GroupUserRole.admin ? true : false;
    userIsModerator =
        groupUserData.role == GroupUserRole.moderator ? true : false;

    if (currentUserIsAdmin) {
      if (userIsAdmin) {
        showRemoveControl = false;
        showDemoteControl = false;
      } else if (userIsModerator) {
        showRemoveControl = true;
        showDemoteControl = true;
      } else {
        showRemoveControl = true;
        showDemoteControl = true;
      }
    }

    if (currentUserIsModerator) {
      if (userIsAdmin) {
        showRemoveControl = false;
        showDemoteControl = false;
      } else if (userIsModerator) {
        showRemoveControl = false;
        showDemoteControl = false;
      } else {
        showRemoveControl = true;
        showDemoteControl = false;
      }
    }

    final adminMessage =
        'Has been an admin since ${f.format(groupUserData.createdDate ?? DateTime.now())}';
    final moderatorMessage =
        'Has been a moderator since ${f.format(groupUserData.modifiedDate ?? DateTime.now())}';
    final memberMessage =
        'Has been a member since ${f.format(groupUserData.createdDate ?? DateTime.now())}';

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
                        ('${user.firstName} ${user.lastName}').toUpperCase(),
                        style: TextStyle(
                            color: AppColors.lightBlue3,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                        child: Text(
                          userIsAdmin
                              ? adminMessage
                              : userIsModerator
                                  ? moderatorMessage
                                  : memberMessage,
                          style: TextStyle(
                              color: AppColors.textFieldText,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      showRemoveControl
                          ? Container(
                              height: 30,
                              margin: EdgeInsets.only(top: 20, bottom: 0),
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
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
                                      'REMOVE FROM GROUP',
                                      style: TextStyle(
                                          color: AppColors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
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
                      showDemoteControl
                          ? Container(
                              height: 30,
                              margin: EdgeInsets.only(top: 20, bottom: 0),
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
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
                                      userIsModerator
                                          ? 'REMOVE AS MODERATOR'
                                          : 'MAKE MODERATOR',
                                      style: TextStyle(
                                          color: AppColors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  onPressed: () {
                                    _changeMemberRole(group, user.id ?? '');
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
                      method == 'Delete'
                          ? _deleteGroup(data)
                          : _leaveGroup(data);
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
      String method, String message, UserDataModel user, GroupDataModel group) {
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
                      _removeUserFromGroup(user.id ?? '', group.id ?? '');
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

  Future<String> getUser(String userId) async {
    return await Provider.of<UserProviderV2>(context, listen: false)
        .getUserDataById(userId)
        .then((value) => '${value.firstName} ${value.lastName}')
        .catchError((e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    });
  }

  List<GroupUserDataModel> sortedGroupMembers(
      List<GroupUserDataModel> groupMembers) {
    final admin = groupMembers
        .firstWhere((element) => element.role == GroupUserRole.admin);
    final members = groupMembers
        .where((element) => element.role == GroupUserRole.member)
        .toList();
    final moderators = groupMembers
        .where((element) => element.role == GroupUserRole.moderator)
        .toList();
    moderators.sort((a, b) => (getMemberName(a.userId ?? ''))
        .toLowerCase()
        .compareTo((getMemberName(b.userId ?? '')).toLowerCase()));
    members.sort((a, b) => (getMemberName(a.userId ?? ''))
        .toLowerCase()
        .compareTo((getMemberName(b.userId ?? '')).toLowerCase()));
    final users = [admin, ...moderators, ...members];
    return users;
  }

  String getMemberName(String userId) {
    if (userId.isNotEmpty) {
      final user = userId == FirebaseAuth.instance.currentUser?.uid
          ? Provider.of<UserProviderV2>(context, listen: false).currentUser
          : Provider.of<UserProviderV2>(context, listen: false)
              .allUsers
              .firstWhere((u) => u.id == userId, orElse: () => UserDataModel());
      final senderName = (user.firstName ?? '') + ' ' + (user.lastName ?? '');
      return senderName;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProviderV2>(context).currentUser;
    final _groups = Provider.of<GroupProviderV2>(context).userGroups;
    final _groupProvider = Provider.of<GroupProviderV2>(context);
    final _userProvider = Provider.of<UserProviderV2>(context);

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
              title: 'Enable notifications from groups?',
              onChange: (bool value) async {
                try {
                  _userProvider.updateUserSettings(
                      'enableNotificationsForAllGroups', value);

                  if (value) {
                    messaging = FirebaseMessaging.instance;
                    messaging.getToken().then((value) => {
                          Provider.of<UserProviderV2>(context, listen: false)
                              .addPushToken(_currentUser.devices ?? [])
                        });
                  } else {
                    final user =
                        Provider.of<UserProviderV2>(context, listen: false)
                            .currentUser;
                    await Provider.of<UserProviderV2>(context, listen: false)
                        .removePushToken(user.devices ?? []);
                  }
                } on HttpException catch (e, s) {
                  BeStilDialog.hideLoading(context);

                  final user =
                      Provider.of<UserProviderV2>(context, listen: false)
                          .currentUser;
                  BeStilDialog.showErrorDialog(
                      context, StringUtils.getErrorMessage(e), user, s);
                } catch (e, s) {
                  BeStilDialog.hideLoading(context);

                  final user =
                      Provider.of<UserProviderV2>(context, listen: false)
                          .currentUser;
                  BeStilDialog.showErrorDialog(
                      context, StringUtils.getErrorMessage(e), user, s);
                }
              },
              value: _currentUser.enableNotificationsForAllGroups ?? false,
            ),
            Column(
              children: <Widget>[
                ..._groups.map((GroupDataModel group) {
                  bool isAdmin = (group.users ?? [])
                          .firstWhere(
                            (g) =>
                                g.userId ==
                                FirebaseAuth.instance.currentUser?.uid,
                            orElse: () => GroupUserDataModel(),
                          )
                          .role ==
                      GroupUserRole.admin;
                  bool isModerator = (group.users ?? [])
                          .firstWhere(
                            (g) =>
                                g.userId ==
                                FirebaseAuth.instance.currentUser?.uid,
                            orElse: () => GroupUserDataModel(),
                          )
                          .role ==
                      GroupUserRole.moderator;
                  bool isMember = (group.users ?? [])
                          .firstWhere(
                            (g) =>
                                g.userId ==
                                FirebaseAuth.instance.currentUser?.uid,
                            orElse: () => GroupUserDataModel(),
                          )
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
                          group.name ?? '',
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
                                        (group.purpose ?? '').isEmpty
                                            ? "-"
                                            : group.purpose ?? '',
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
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Text(
                                        (group.organization ?? '').isEmpty
                                            ? "-"
                                            : group.organization ?? '',
                                        style: AppTextStyles.regularText16b
                                            .copyWith(
                                                color: AppColors.textFieldText),
                                        overflow: TextOverflow.ellipsis,
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
                                        group.location ?? '',
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
                        SizedBox(height: 30),
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
                        SizedBox(height: 15),
                        if (isAdmin || isModerator)
                          CustomToggle(
                            title: 'Require admin approval to join group?',
                            onChange: (value) {
                              _groupProvider.editGroup(
                                  group.id ?? '',
                                  group.name ?? '',
                                  group.purpose ?? '',
                                  value,
                                  group.organization ?? '',
                                  group.location ?? '',
                                  group.type ?? '',
                                  _currentUser.groups ?? []);
                            },
                            value: group.requireAdminApproval ?? false,
                            disabled: isModerator,
                          ),
                        SizedBox(height: 25),
                        Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(children: <Widget>[
                                  Text('My Alerts',
                                      style: AppTextStyles.regularText11
                                          .copyWith(
                                              color: AppColors.lightBlue1)),
                                  SizedBox(width: 10),
                                  Expanded(
                                      child: Divider(
                                          color: AppColors.darkBlue,
                                          thickness: 1))
                                ])),
                            SizedBox(height: 15),
                            CustomToggle(
                                disabled: false,
                                title:
                                    'Enable alerts for new prayers in this group?',
                                onChange: (value) =>
                                    _groupProvider.updateGroupUserSettings(
                                        group,
                                        'enableNotificationForNewPrayers',
                                        value,
                                        _currentUser.groups ?? []),
                                value: (group.users ?? [])
                                        .firstWhere(
                                          (e) =>
                                              e.userId ==
                                              FirebaseAuth
                                                  .instance.currentUser?.uid,
                                          orElse: () => GroupUserDataModel(),
                                        )
                                        .enableNotificationForNewPrayers ??
                                    false),
                            CustomToggle(
                              disabled: false,
                              title:
                                  'Enable alerts for prayer updates in this group?',
                              onChange: (value) =>
                                  _groupProvider.updateGroupUserSettings(
                                      group,
                                      'enableNotificationForUpdates',
                                      value,
                                      _currentUser.groups ?? []),
                              value: (group.users ?? [])
                                      .firstWhere(
                                        (e) =>
                                            e.userId ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid,
                                        orElse: () => GroupUserDataModel(),
                                      )
                                      .enableNotificationForUpdates ??
                                  false,
                            ),
                          ],
                        ),
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
                                          'Members | ${(group.users ?? []).length}',
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
                                        ...sortedGroupMembers(group.users ?? [])
                                            .map(
                                          (groupUser) {
                                            return GestureDetector(
                                              onTap: () async {
                                                try {
                                                  _showMemberAlert(
                                                      groupUser.userId ?? '',
                                                      group,
                                                      groupUser.role ?? '');
                                                } on HttpException catch (e, s) {
                                                  BeStilDialog.hideLoading(
                                                      context);

                                                  final user = Provider.of<
                                                              UserProviderV2>(
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

                                                  final user = Provider.of<
                                                              UserProviderV2>(
                                                          context,
                                                          listen: false)
                                                      .currentUser;
                                                  BeStilDialog.showErrorDialog(
                                                      context,
                                                      StringUtils
                                                          .getErrorMessage(e),
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
                                                              getMemberName(
                                                                      groupUser
                                                                              .userId ??
                                                                          '')
                                                                  .sentenceCase(),
                                                              style: AppTextStyles
                                                                  .boldText14
                                                                  .copyWith(
                                                                      color: AppColors
                                                                          .lightBlue4)),
                                                          Text(
                                                            groupUser.role ==
                                                                    GroupUserRole
                                                                        .admin
                                                                ? 'Admin'
                                                                : groupUser.role ==
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
                                      context, message, method, title, group);
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
                        isModerator
                            ? GestureDetector(
                                onTap: () {
                                  _changeMemberRole(
                                      group, _currentUser.id ?? '');
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
                                      'REMOVE ME AS MODERATOR',
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
                                      context, message, method, title, group);
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
