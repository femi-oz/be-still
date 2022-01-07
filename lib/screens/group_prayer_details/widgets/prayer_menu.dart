import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PrayerGroupMenu extends StatefulWidget {
  final BuildContext parentcontext;
  final bool hasReminder;
  final Function updateUI;
  final CombineGroupPrayerStream prayerData;
  final LocalNotificationModel reminder;

  @override
  PrayerGroupMenu(this.parentcontext, this.hasReminder, this.reminder,
      this.updateUI, this.prayerData);

  @override
  _PrayerGroupMenuState createState() => _PrayerGroupMenuState();
}

class _PrayerGroupMenuState extends State<PrayerGroupMenu> {
  List<String> reminderInterval = [
    Frequency.daily,
    Frequency.weekly,
  ];

  FollowedPrayerModel followedPrayer;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await Provider.of<GroupPrayerProvider>(context, listen: false)
        .setFollowedPrayer(widget.prayerData.prayer.id);
    super.didChangeDependencies();
  }

  void _followPrayer() async {
    BeStilDialog.showLoading(context);
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final currentGroup =
        Provider.of<GroupProvider>(context, listen: false).currentGroup;
    try {
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .addToMyList(
              widget.prayerData.prayer.id, user.id, currentGroup.group.id);
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .setFollowedPrayerByUserId(user.id);
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      AppCOntroller appCOntroller = Get.find();
      appCOntroller.setCurrentPage(8, true);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _unFollowPrayer(followedPrayerId, userPrayerId) async {
    BeStilDialog.showLoading(context);
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    try {
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .removeFromMyList(followedPrayerId, userPrayerId);
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .setFollowedPrayerByUserId(user.id);
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      AppCOntroller appCOntroller = Get.find();
      appCOntroller.setCurrentPage(8, true);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  _sendNotification(
      String groupId, List<String> tokens, String receiverId) async {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

    await Provider.of<NotificationProvider>(context, listen: false)
        .sendPushNotification(
            '${_user.firstName} flagged a prayer as inappropriate',
            NotificationType.inappropriate_content,
            _user.firstName,
            _user.id,
            receiverId,
            'Prayer flagged as innapropriate',
            widget.prayerData.groupPrayer.id,
            '',
            tokens);
  }

  void _flagAsInappropriate(CombineGroupUserStream group) async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .flagAsInappropriate(widget.prayerData.prayer.id);

      var admin = group.groupUsers
          .firstWhere((element) => element.role == GroupUserRole.admin);
      await Provider.of<UserProvider>(context, listen: false)
          .getUserById(admin.userId);
      final adminData =
          Provider.of<UserProvider>(context, listen: false).selectedUser;
      _sendNotification(group.group.id, [adminData.pushToken], adminData.id);
      BeStilDialog.hideLoading(context);
      AppCOntroller appCOntroller = Get.find();
      appCOntroller.setCurrentPage(8, true);
      Navigator.pop(context);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  _onDelete() async {
    BeStilDialog.showLoading(context);
    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == widget.prayerData.groupPrayer.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .deletePrayer(
              widget.prayerData.groupPrayer.id, widget.prayerData.prayer.id);
      _deleteFollowedPrayers();
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      AppCOntroller appCOntroller = Get.find();
      appCOntroller.setCurrentPage(8, true);
      Navigator.pop(context);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _deleteFollowedPrayers() async {
    try {
      var followedPrayers =
          Provider.of<GroupPrayerProvider>(context, listen: false)
              .followedPrayers;
      if (followedPrayers.length > 0) {
        followedPrayers.forEach((element) async {
          await Provider.of<GroupPrayerProvider>(context, listen: false)
              .removeFromMyList(element.id, element.userPrayerId);
        });
      }
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _onMarkAsAnswered() async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData.prayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(
              widget.prayerData.prayer.id, widget.prayerData.groupPrayer.id);
      _deleteFollowedPrayers();

      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _unMarkAsAnswered() async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .unMarkPrayerAsAnswered(
              widget.prayerData.prayer.id, widget.prayerData.groupPrayer.id);
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _openDeleteConfirmation(BuildContext context) {
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
                'DELETE PRAYER',
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
                  'Are you sure you want to delete this prayer?',
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
                    onTap: _onDelete,
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
                            'DELETE',
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

  void _unArchive(CombineGroupPrayerStream prayerData) async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .unArchivePrayer(prayerData.groupPrayer.id, prayerData.prayer.id);
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _onArchive(CombineGroupPrayerStream prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData.groupPrayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));

      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .archivePrayer(widget.prayerData.groupPrayer.id);
      _deleteFollowedPrayers();

      BeStilDialog.hideLoading(context);

      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  bool get isFollowing {
    var isFollowing = Provider.of<GroupPrayerProvider>(context, listen: false)
        .followedPrayers
        .any((element) => element.prayerId == widget.prayerData.prayer.id);
    return isFollowing;
  }

  Widget build(BuildContext context) {
    var isDisable = widget.prayerData.prayer.isAnswer ||
        widget.prayerData.groupPrayer.isArchived ||
        widget.prayerData.groupPrayer.isSnoozed;
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    final group = Provider.of<GroupProvider>(context).currentGroup;
    bool isAdmin = Provider.of<GroupProvider>(context)
            .currentGroup
            .groupUsers
            .firstWhere((g) => g.userId == _currentUser.id)
            .role ==
        GroupUserRole.admin;
    bool isOwner = widget.prayerData.prayer.createdBy == _currentUser.id;

    if (isFollowing)
      followedPrayer = Provider.of<GroupPrayerProvider>(context, listen: false)
          .followedPrayers
          .firstWhere((element) =>
              element.prayerId == widget.prayerData.prayer.id &&
              element.createdBy == _currentUser.id);

    return Container(
      padding: EdgeInsets.only(top: 50),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 30),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context, listen: false)
                          .isDarkModeEnabled
                      ? Colors.transparent
                      : AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                ),
                child: TextButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Provider.of<ThemeProvider>(context, listen: false)
                              .isDarkModeEnabled
                          ? Colors.transparent
                          : AppColors.white,
                    ),
                  ),
                  icon: Icon(
                    AppIcons.bestill_back_arrow,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  label: Text(
                    'BACK',
                    style: AppTextStyles.boldText20,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(left: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    LongButton(
                        textColor: AppColors.lightBlue3,
                        backgroundColor:
                            Provider.of<ThemeProvider>(context, listen: false)
                                    .isDarkModeEnabled
                                ? AppColors.backgroundColor[0].withOpacity(0.7)
                                : AppColors.white,
                        icon: AppIcons.bestill_share,
                        text: 'Share',
                        isDisabled:
                            (isOwner || isAdmin) || (!isOwner && !isAdmin),
                        onPress: () => () {}),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons.bestill_edit,
                      isDisabled: !isOwner && !isAdmin,
                      onPress: !isOwner && !isAdmin
                          ? () {}
                          : () async {
                              Provider.of<GroupPrayerProvider>(context,
                                      listen: false)
                                  .setEditMode(true);
                              Provider.of<GroupPrayerProvider>(context,
                                      listen: false)
                                  .setEditPrayer(widget.prayerData);
                              Navigator.pop(context);
                              await Future.delayed(Duration(milliseconds: 200));
                              AppCOntroller appCOntroller = Get.find();
                              appCOntroller.setCurrentPage(10, true);
                            },
                      text: 'Edit',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons.bestill_update,
                      isDisabled: !isOwner && !isAdmin,
                      onPress: !isOwner && !isAdmin
                          ? () {}
                          : () async {
                              await Provider.of<GroupPrayerProvider>(context,
                                      listen: false)
                                  .setPrayerFuture(
                                      widget.prayerData.groupPrayer.id);
                              Navigator.pop(context);
                              await Future.delayed(Duration(milliseconds: 200));
                              AppCOntroller appCOntroller = Get.find();
                              appCOntroller.setCurrentPage(13, true);
                            },
                      text: 'Add an Update',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons.bestill_snooze,
                      isDisabled:
                          (isOwner || isAdmin) || (!isOwner && !isAdmin),
                      onPress: () => (isOwner || isAdmin) ||
                              (!isOwner && !isAdmin)
                          ? () {}
                          : showDialog(
                              context: context,
                              barrierColor: AppColors.detailBackgroundColor[1]
                                  .withOpacity(0.5),
                              builder: (BuildContext context) => Dialog(
                                insetPadding: EdgeInsets.all(20),
                                backgroundColor: AppColors.prayerCardBgColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: AppColors.darkBlue),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 30),
                                        child: Container()),
                                  ],
                                ),
                              ),
                            ),
                      text: 'Snooze',
                      // text: 'Snooze',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      isDisabled: !isOwner && !isAdmin,
                      icon: AppIcons.bestill_answered,
                      onPress: () => !isOwner && !isAdmin
                          ? () {}
                          : widget.prayerData.prayer.isAnswer
                              ? _unMarkAsAnswered()
                              : _onMarkAsAnswered(),
                      text: widget.prayerData.prayer.isAnswer
                          ? 'Unmark as Answered'
                          : 'Mark as Answered',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: Icons.favorite,
                      isDisabled:
                          (isOwner || isAdmin) || (!isOwner && !isAdmin),
                      onPress: () {},
                      text: 'Mark as Favorite ',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      hasIcon: true,
                      isDisabled: !isOwner && !isAdmin,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons
                          .bestill_icons_bestill_archived_icon_revised_drk,
                      onPress: () => !isOwner && !isAdmin
                          ? () {}
                          : widget.prayerData.groupPrayer.isArchived
                              ? _unArchive(widget.prayerData)
                              : _onArchive(widget.prayerData),
                      text: widget.prayerData.groupPrayer.isArchived
                          ? 'Unarchive'
                          : 'Archive',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: Icons.delete_forever,
                      isDisabled: !isOwner && !isAdmin,
                      onPress: !isOwner && !isAdmin
                          ? () {}
                          : () {
                              _openDeleteConfirmation(context);
                            },
                      text: 'Delete',
                    ),
                    LongButton(
                        textColor: AppColors.lightBlue3,
                        backgroundColor:
                            Provider.of<ThemeProvider>(context, listen: false)
                                    .isDarkModeEnabled
                                ? AppColors.backgroundColor[0].withOpacity(0.7)
                                : AppColors.white,
                        icon: Icons.star_border,
                        text: isFollowing ? 'Unfollow' : 'Follow',
                        isDisabled: isOwner,
                        onPress: () => isOwner
                            ? () {}
                            : isFollowing
                                ? _unFollowPrayer(followedPrayer.id,
                                    followedPrayer.userPrayerId)
                                : _followPrayer()),
                    LongButton(
                        textColor: AppColors.lightBlue3,
                        backgroundColor:
                            Provider.of<ThemeProvider>(context, listen: false)
                                    .isDarkModeEnabled
                                ? AppColors.backgroundColor[0].withOpacity(0.7)
                                : AppColors.white,
                        icon: Icons.info,
                        text: 'Flag as inappropriate',
                        isDisabled: isOwner || isAdmin,
                        onPress: () => isOwner || isAdmin
                            ? () {}
                            : _flagAsInappropriate(group)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
