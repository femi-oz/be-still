import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/local_notification.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/theme_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PrayerGroupMenu extends StatefulWidget {
  final BuildContext parentcontext;
  final bool hasReminder;
  final Function updateUI;
  final PrayerDataModel? prayerData;
  final LocalNotificationDataModel reminder;

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

  // FollowedPrayerModel followedPrayer = FollowedPrayerModel();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AppController appController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  void clearSearch() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    await Provider.of<MiscProviderV2>(context, listen: false)
        .setSearchMode(false);
    await Provider.of<MiscProviderV2>(context, listen: false)
        .setSearchQuery('');
    await Provider.of<PrayerProviderV2>(context, listen: false)
        .searchPrayers('', userId ?? '');
  }

  void _followPrayer() async {
    BeStilDialog.showLoading(context);
    final currentGroup =
        Provider.of<GroupProviderV2>(context, listen: false).currentGroup;

    try {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      await Provider.of<PrayerProviderV2>(context, listen: false).followPrayer(
          widget.prayerData?.id ?? '',
          currentGroup.id ?? '',
          (user.prayers ?? []).map((e) => e.prayerId ?? '').toList());
      clearSearch();
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);

      appController.setCurrentPage(8, true, 8);
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

  void _unFollowPrayer() async {
    BeStilDialog.showLoading(context);
    try {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      final currentGroup =
          Provider.of<GroupProviderV2>(context, listen: false).currentGroup;
      final follower = (widget.prayerData?.followers ?? []).firstWhere(
          (e) => e.userId == FirebaseAuth.instance.currentUser?.uid);
      final prayer = (user.prayers ?? [])
          .firstWhere((e) => e.prayerId == widget.prayerData?.id);
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .unFollowPrayer(
              widget.prayerData?.id ?? '',
              currentGroup.id ?? '',
              (user.prayers ?? []).map((e) => e.prayerId ?? '').toList(),
              prayer,
              follower);
      clearSearch();

      BeStilDialog.hideLoading(context);
      Navigator.pop(context);

      appController.setCurrentPage(8, true, 8);
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

  void _flagAsInappropriate(GroupDataModel group) async {
    BeStilDialog.showLoading(context);

    try {
      final adminId = (group.users ?? [])
          .firstWhere((e) => e.role == GroupUserRole.admin)
          .userId;
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      await Provider.of<NotificationProviderV2>(context, listen: false)
          .flagAsInappropriate(
              widget.prayerData?.id ?? '',
              widget.prayerData?.groupId ?? '',
              adminId ?? '',
              (user.firstName ?? '') + ' ' + (user.lastName ?? ''),
              (user.devices ?? []).map((e) => e.token ?? '').toList(),
              group.name ?? '');

      clearSearch();

      BeStilDialog.hideLoading(context);

      appController.setCurrentPage(8, true, 8);
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

  _onDelete() async {
    BeStilDialog.showLoading(context);

    try {
      final notifications =
          Provider.of<NotificationProviderV2>(context, listen: false)
              .localNotifications
              .where((e) => e.prayerId == widget.prayerData?.id)
              .toList();
      // final pushNotifications =
      //     await Provider.of<NotificationProviderV2>(context, listen: false)
      //         .getNotifications(widget.prayerData?.groupPrayer?.id ?? '');
      // (pushNotifications ?? []).where((element) =>
      //     element.prayerId == widget.prayerData?.groupPrayer?.id ||
      //     element.groupId == widget.prayerData?.groupPrayer?.groupId);

      // for (final not in notifications)
      //   await Provider.of<NotificationProvider>(context, listen: false)
      //       .deleteLocalNotification(
      //           not.id ?? '', not.localNotificationId ?? 0);
      // (pushNotifications ?? []).forEach((e) async =>
      //     await Provider.of<NotificationProvider>(context, listen: false)
      //         .updateNotification(e.id ?? ''));
      await Provider.of<PrayerProviderV2>(context, listen: false).deletePrayer(
          widget.prayerData?.id ?? '', widget.prayerData?.followers ?? []);
      clearSearch();

      // _deleteFollowedPrayers();
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      appController.setCurrentPage(8, true, 8);
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

  void _sendPrayerNotification(String type) async {
    await Provider.of<NotificationProviderV2>(context, listen: false)
        .sendPrayerNotification(
            widget.prayerData?.id ?? '',
            type,
            widget.prayerData?.groupId ?? '',
            widget.prayerData?.description ?? '');
  }

  void _onMarkAsAnswered() async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProviderV2>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.prayerId == widget.prayerData?.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProviderV2>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));
      _sendPrayerNotification(NotificationType.answered_prayers);
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .markPrayerAsAnswered(
              widget.prayerData?.id ?? '', widget.prayerData?.followers ?? []);
      // _deleteFollowedPrayers();
      clearSearch();
      appController.setCurrentPage(8, false, 0);
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

  void _unMarkAsAnswered() async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .unMarkPrayerAsAnswered(widget.prayerData?.id ?? '');
      clearSearch();
      appController.setCurrentPage(8, false, 0);
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
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

  void _unArchive(PrayerDataModel? prayerData) async {
    BeStilDialog.showLoading(context);
    try {
      bool isAdmin = (Provider.of<GroupProviderV2>(context, listen: false)
                      .currentGroup
                      .users ??
                  [])
              .firstWhere(
                  (g) => g.userId == FirebaseAuth.instance.currentUser?.uid)
              .role ==
          GroupUserRole.admin;
      await Provider.of<PrayerProviderV2>(context, listen: false)
          .unArchivePrayer(
              prayerData?.id ?? '', prayerData?.followers ?? [], isAdmin);
      clearSearch();
      appController.setCurrentPage(8, false, 0);
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

  void _onArchive(PrayerDataModel? prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProviderV2>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.prayerId == widget.prayerData?.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProviderV2>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));
      await Provider.of<PrayerProviderV2>(context, listen: false).archivePrayer(
          widget.prayerData?.id ?? '', widget.prayerData?.followers ?? []);
      await Provider.of<NotificationProviderV2>(context, listen: false)
          .sendPrayerNotification(
        widget.prayerData?.id ?? '',
        NotificationType.archived_prayers,
        widget.prayerData?.groupId ?? '',
        widget.prayerData?.description ?? '',
      );
      clearSearch();
      appController.setCurrentPage(8, false, 0);
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

  bool get isFollowing {
    final isFollowing = Provider.of<PrayerProviderV2>(context, listen: false)
        .followedPrayers
        .any((element) => element.id == widget.prayerData?.id);
    return isFollowing;
  }

  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProviderV2>(context).currentUser;
    final group = Provider.of<GroupProviderV2>(context).currentGroup;
    bool isAdmin =
        (Provider.of<GroupProviderV2>(context).currentGroup.users ?? [])
                .firstWhere((g) => g.userId == _currentUser.id)
                .role ==
            GroupUserRole.admin;
    bool isOwner = widget.prayerData?.createdBy == _currentUser.id;

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
                  color: Provider.of<ThemeProviderV2>(context, listen: false)
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
                      Provider.of<ThemeProviderV2>(context, listen: false)
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
                            Provider.of<ThemeProviderV2>(context, listen: false)
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
                          Provider.of<ThemeProviderV2>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons.bestill_edit,
                      isDisabled: !isOwner && !isAdmin,
                      onPress: !isOwner && !isAdmin
                          ? () {}
                          : () async {
                              try {
                                Provider.of<PrayerProviderV2>(context,
                                        listen: false)
                                    .setCurrentPrayerId(
                                        widget.prayerData?.id ?? '');
                                Provider.of<PrayerProviderV2>(context,
                                        listen: false)
                                    .setEditMode(true, false);
                                Provider.of<PrayerProviderV2>(context,
                                        listen: false)
                                    .setEditPrayer(
                                        prayer: widget.prayerData ??
                                            PrayerDataModel(),
                                        updates:
                                            widget.prayerData?.updates ?? [],
                                        tags: widget.prayerData?.tags ?? []);
                                Navigator.pop(context);
                                await Future.delayed(
                                    Duration(milliseconds: 200));

                                appController.setCurrentPage(
                                    1, true, appController.currentPage);
                              } on HttpException catch (e, s) {
                                final user = Provider.of<UserProviderV2>(
                                        context,
                                        listen: false)
                                    .currentUser;
                                BeStilDialog.showErrorDialog(context,
                                    StringUtils.getErrorMessage(e), user, s);
                              } catch (e, s) {
                                final user = Provider.of<UserProviderV2>(
                                        context,
                                        listen: false)
                                    .currentUser;
                                BeStilDialog.showErrorDialog(context,
                                    StringUtils.getErrorMessage(e), user, s);
                              }
                            },
                      text: 'Edit',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProviderV2>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons.bestill_update,
                      isDisabled: !isOwner && !isAdmin,
                      onPress: !isOwner && !isAdmin
                          ? () {}
                          : () async {
                              try {
                                Provider.of<PrayerProviderV2>(context,
                                        listen: false)
                                    .setCurrentPrayerId(
                                        widget.prayerData?.id ?? '');

                                Provider.of<PrayerProviderV2>(context,
                                        listen: false)
                                    .setEditPrayer(
                                        prayer: widget.prayerData ??
                                            PrayerDataModel(),
                                        updates:
                                            widget.prayerData?.updates ?? [],
                                        tags: widget.prayerData?.tags ?? []);
                                Navigator.pop(context);
                                await Future.delayed(
                                    Duration(milliseconds: 200));

                                appController.setCurrentPage(
                                    13, true, appController.currentPage);
                              } on HttpException catch (e, s) {
                                final user = Provider.of<UserProviderV2>(
                                        context,
                                        listen: false)
                                    .currentUser;
                                BeStilDialog.showErrorDialog(context,
                                    StringUtils.getErrorMessage(e), user, s);
                              } catch (e, s) {
                                final user = Provider.of<UserProviderV2>(
                                        context,
                                        listen: false)
                                    .currentUser;
                                BeStilDialog.showErrorDialog(context,
                                    StringUtils.getErrorMessage(e), user, s);
                              }
                            },
                      text: 'Add an Update',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProviderV2>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons.bestill_reminder,
                      isDisabled: true,
                      onPress: () => () {},
                      text: 'Reminder',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProviderV2>(context, listen: false)
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 30),
                                    ),
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
                          Provider.of<ThemeProviderV2>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      isDisabled: !isOwner && !isAdmin,
                      icon: AppIcons.bestill_answered,
                      onPress: () => !isOwner && !isAdmin
                          ? () {}
                          : widget.prayerData?.isAnswered ?? false
                              ? _unMarkAsAnswered()
                              : _onMarkAsAnswered(),
                      text: widget.prayerData?.isAnswered ?? false
                          ? 'Unmark as Answered'
                          : 'Mark as Answered',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProviderV2>(context, listen: false)
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
                          Provider.of<ThemeProviderV2>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons
                          .bestill_icons_bestill_archived_icon_revised_drk,
                      onPress: () => !isOwner && !isAdmin
                          ? () {}
                          : widget.prayerData?.status == Status.archived
                              ? _unArchive(widget.prayerData)
                              : _onArchive(widget.prayerData),
                      text: widget.prayerData?.status == Status.archived
                          ? 'Unarchive'
                          : 'Archive',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProviderV2>(context, listen: false)
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
                            Provider.of<ThemeProviderV2>(context, listen: false)
                                    .isDarkModeEnabled
                                ? AppColors.backgroundColor[0].withOpacity(0.7)
                                : AppColors.white,
                        icon: Icons.star_border,
                        text: isFollowing ? 'Unfollow' : 'Follow',
                        isDisabled: isOwner ||
                            widget.prayerData?.status !=
                                Status.active, //disabled only for owner
                        onPress: () => isOwner ||
                                widget.prayerData?.status != Status.active
                            ? () {}
                            : isFollowing
                                ? _unFollowPrayer()
                                : _followPrayer()),
                    LongButton(
                        textColor: AppColors.lightBlue3,
                        backgroundColor:
                            Provider.of<ThemeProviderV2>(context, listen: false)
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
