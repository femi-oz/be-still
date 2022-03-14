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

  Future<void> _removeUserFromGroup(String groupId) async {
    try {
      final message = 'You have removed the user from your group';

      BeStilDialog.showLoading(context);
      await Provider.of<GroupProviderV2>(context, listen: false)
          .removeGroupUser(
              FirebaseAuth.instance.currentUser?.uid ?? "", groupId);

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

  Future<void> _leaveGroup(GroupDataModel group) async {
    try {
      Navigator.pop(context);
      BeStilDialog.showLoading(context, '');

      await Provider.of<GroupProviderV2>(context, listen: false)
          .leaveGroup(group.id ?? "");

      final receiver = (group.users ?? [])
          .firstWhere((element) => element.role == GroupUserRole.admin);
      final receiverData =
          await Provider.of<UserProviderV2>(context, listen: false)
              .getUserDataById(receiver.userId ?? '');
      final _currentUser =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      await _sendPushNotification(
          '${(_currentUser.firstName ?? '').capitalizeFirst} ${(_currentUser.lastName ?? '').capitalizeFirst} has left your group ${group.name}',
          NotificationType.leave_group,
          _currentUser.firstName ?? '',
          'Groups',
          (receiverData.devices ?? []).map((e) => e.token ?? '').toList(),
          groupId: group.id);
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
      final notifications =
          Provider.of<NotificationProviderV2>(context, listen: false)
              .notifications
              .where((e) => e.groupId == group.id)
              .toList();

      await Provider.of<GroupProviderV2>(context, listen: false)
          .deleteGroup(group.id ?? '', notifications);
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
      String sender, String title, List<String> tokens,
      {String? groupId, String? prayerId}) async {
    try {
      await Provider.of<NotificationProviderV2>(context, listen: false)
          .sendPushNotification(message, messageType, sender, tokens,
              groupId: groupId, prayerId: prayerId);
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
      UserDataModel user, GroupDataModel group, String role) async {
    bool userIsAdmin = false;
    UserDataModel userData = UserDataModel();
    try {
      final _currentUser =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      userIsAdmin = user.id == _currentUser.id && role == GroupUserRole.admin
          ? true
          : false;

      userData =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
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
                          'Has been a member since ${f.format(user.createdDate ?? DateTime.now())}',
                          style: TextStyle(
                              color: AppColors.textFieldText,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      !userIsAdmin
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
                      _removeUserFromGroup(group.id ?? '');
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

  // List<GroupUserDataModel> sortedGroupMembers(
  //     List<GroupUserDataModel> groupMembers) {
  //   final adminId = groupMembers
  //       .firstWhere((element) => element.role == GroupUserRole.admin);
  //       final adminData =
  //   final memberNames = groupMembers
  //       .where((element) => element.role == GroupUserRole.member)
  //       .toList();
  //   memberNames.sort((a, b) => (a.fullName ?? '')
  //       .toLowerCase()
  //       .compareTo((b.fullName ?? '').toLowerCase()));
  //   final users = [...adminName, ...memberNames];
  //   return users;
  // }

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
                                    Text(
                                      (group.organization ?? '').isEmpty
                                          ? "-"
                                          : group.organization ?? '',
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
                                      .firstWhere((e) =>
                                          e.userId ==
                                          FirebaseAuth
                                              .instance.currentUser?.uid)
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
                                        ...(group.users ?? []).map(
                                          (groupUser) {
                                            return FutureBuilder<UserDataModel>(
                                                future: Provider.of<
                                                            UserProviderV2>(
                                                        context,
                                                        listen: false)
                                                    .getUserDataById(
                                                        groupUser.userId ?? ''),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData)
                                                    return SizedBox.shrink();
                                                  else
                                                    return GestureDetector(
                                                      onTap: () async {
                                                        try {
                                                          _showMemberAlert(
                                                              snapshot.data ??
                                                                  UserDataModel(),
                                                              group,
                                                              groupUser.role ??
                                                                  '');
                                                        } on HttpException catch (e, s) {
                                                          BeStilDialog
                                                              .hideLoading(
                                                                  context);

                                                          final user = Provider
                                                                  .of<UserProviderV2>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                              .currentUser;
                                                          BeStilDialog
                                                              .showErrorDialog(
                                                                  context,
                                                                  StringUtils
                                                                      .getErrorMessage(
                                                                          e),
                                                                  user,
                                                                  s);
                                                        } catch (e, s) {
                                                          BeStilDialog
                                                              .hideLoading(
                                                                  context);

                                                          final user = Provider
                                                                  .of<UserProviderV2>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                              .currentUser;
                                                          BeStilDialog
                                                              .showErrorDialog(
                                                                  context,
                                                                  StringUtils
                                                                      .getErrorMessage(
                                                                          e),
                                                                  user,
                                                                  s);
                                                        }
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                vertical: 7.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .cardBorder,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                        ),
                                                        child: Container(
                                                          margin:
                                                              EdgeInsetsDirectional
                                                                  .only(
                                                                      start: 1,
                                                                      bottom: 1,
                                                                      top: 1),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  20),
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .prayerCardBgColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              bottomLeft: Radius
                                                                  .circular(9),
                                                              topLeft: Radius
                                                                  .circular(9),
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
                                                                      '${(snapshot.data ?? UserDataModel()).firstName} ${(snapshot.data ?? UserDataModel()).lastName}'
                                                                          .sentenceCase(),
                                                                      style: AppTextStyles
                                                                          .boldText14
                                                                          .copyWith(
                                                                              color: AppColors.lightBlue4)),
                                                                  Text(
                                                                    groupUser.role ==
                                                                            GroupUserRole
                                                                                .admin
                                                                        ? 'Admin'
                                                                        : groupUser.role ==
                                                                                GroupUserRole.moderator
                                                                            ? 'Moderator'
                                                                            : 'Member',
                                                                    style: AppTextStyles
                                                                        .regularText14
                                                                        .copyWith(
                                                                            color:
                                                                                AppColors.lightBlue1),
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
                                                });
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
