import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/share_prayer.dart';
import 'package:be_still/widgets/snooze_prayer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class PrayerMenu extends StatefulWidget {
  final BuildContext parentcontext;
  final bool hasReminder;
  final Function updateUI;
  final CombinePrayerStream? prayerData;
  final LocalNotificationModel reminder;
  @override
  PrayerMenu(this.parentcontext, this.hasReminder, this.reminder, this.updateUI,
      this.prayerData);

  @override
  _PrayerMenuState createState() => _PrayerMenuState();
}

class _PrayerMenuState extends State<PrayerMenu> {
  List<String> reminderInterval = [
    Frequency.daily,
    Frequency.weekly,
  ];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // FollowedPrayerModel followedPrayer = FollowedPrayerModel();
  // bool isAdmin = false;

  @override
  void initState() {
    // getGroup();

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    Provider.of<PrayerProvider>(context).getPrayer();
    super.didChangeDependencies();
  }

  bool get isAdmin {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      return Provider.of<GroupPrayerProvider>(context)
          .followedPrayers
          .any((element) {
        if (element.prayerId == widget.prayerData?.prayer?.id &&
            element.createdBy == _user.id &&
            (element.isFollowedByAdmin ?? false)) {
          return true;
        } else {
          return false;
        }
      });
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
      return false;
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
      return false;
    }
  }

  // getGroup() async {
  //   try {
  //     var _userId =
  //         Provider.of<UserProvider>(context, listen: false).currentUser.id;
  //     await Provider.of<GroupPrayerProvider>(context, listen: false)
  //         .setFollowedPrayerByUserId(_userId ?? '');
  //   } on HttpException catch (e, s) {
  //     BeStilDialog.hideLoading(context);
  //     final user =
  //         Provider.of<UserProvider>(context, listen: false).currentUser;
  //     BeStilDialog.showErrorDialog(
  //         context, StringUtils.getErrorMessage(e), user, s);
  //   } catch (e, s) {
  //     BeStilDialog.hideLoading(context);
  //     final user =
  //         Provider.of<UserProvider>(context, listen: false).currentUser;
  //     BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
  //   }
  // }

  void _markPrayerAsFavorite(CombinePrayerStream? prayerData) async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .favoritePrayer(prayerData?.userPrayer?.id ?? '');
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);

      AppController appController = Get.find();
      appController.setCurrentPage(0, true, 0);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  void _unFollowPrayer() async {
    BeStilDialog.showLoading(context);
    try {
      final _userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;

      final s = Provider.of<GroupPrayerProvider>(context, listen: false)
          .followedPrayers;
      final followedPrayer = s.firstWhere(
          (element) =>
              element.prayerId == widget.prayerData?.prayer?.id &&
              element.createdBy == _userId,
          orElse: () => FollowedPrayerModel.defaultValue());
      await Provider.of<GroupPrayerProvider>(context, listen: false)
          .removeFromMyList(
              followedPrayer.id ?? '', widget.prayerData?.userPrayer?.id ?? '');

      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      AppController appController = Get.find();
      appController.setCurrentPage(0, true, 0);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  bool get isFollowing {
    var isFollowing = Provider.of<GroupPrayerProvider>(context, listen: false)
        .followedPrayers
        .any((element) => element.prayerId == widget.prayerData?.prayer?.id);
    return isFollowing;
  }

  void _unMarkPrayerAsFavorite(CombinePrayerStream? prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .unfavoritePrayer(prayerData?.userPrayer?.id ?? '');
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);
      AppController appController = Get.find();
      appController.setCurrentPage(0, true, 0);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  void _onDelete() async {
    BeStilDialog.showLoading(context);
    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == widget.prayerData?.userPrayer?.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));
      await Provider.of<PrayerProvider>(context, listen: false)
          .deletePrayer(widget.prayerData?.userPrayer?.id ?? '');
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);

      AppController appController = Get.find();
      Navigator.pop(context);
      appController.setCurrentPage(0, true, 0);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
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
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 30,
                        // width: MediaQuery.of(context).size.width * .28,
                        decoration: BoxDecoration(
                          color: AppColors.grey.withOpacity(0.5),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 7, horizontal: 18),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _onDelete,
                      child: Container(
                        height: 30,
                        // width: MediaQuery.of(context).size.width * .28,
                        padding:
                            EdgeInsets.symmetric(vertical: 7, horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'DELETE',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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

  void _onMarkAsAnswered(CombinePrayerStream? prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData?.userPrayer?.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));
      await Provider.of<PrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(
              prayerData?.prayer?.id ?? '', prayerData?.userPrayer?.id ?? '');

      BeStilDialog.hideLoading(context);
      Navigator.pop(context);

      AppController appController = Get.find();
      appController.setCurrentPage(0, true, 0);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  void _unMarkAsAnswered(CombinePrayerStream? prayerData) async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .unMarkPrayerAsAnswered(
              prayerData?.prayer?.id ?? '', prayerData?.userPrayer?.id ?? '');
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);

      AppController appController = Get.find();
      appController.setCurrentPage(0, true, 0);
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  void _unArchive(CombinePrayerStream? prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProvider>(context, listen: false).unArchivePrayer(
          prayerData?.userPrayer?.id ?? '', prayerData?.prayer?.id ?? '');
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);

      AppController appController = Get.find();
      appController.setCurrentPage(0, true, 0);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  void _onArchive(CombinePrayerStream? prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData?.userPrayer?.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));

      await Provider.of<PrayerProvider>(context, listen: false)
          .archivePrayer(widget.prayerData?.userPrayer?.id ?? '');
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);

      AppController appController = Get.find();
      appController.setCurrentPage(0, true, 0);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  _share() {
    Navigator.pop(context);
    showModalBottomSheet(
        context: context,
        barrierColor:
            Provider.of<ThemeProvider>(context, listen: false).isDarkModeEnabled
                ? AppColors.backgroundColor[0].withOpacity(0.5)
                : Color(0xFF021D3C).withOpacity(0.7),
        backgroundColor:
            Provider.of<ThemeProvider>(context, listen: false).isDarkModeEnabled
                ? AppColors.backgroundColor[0].withOpacity(0.5)
                : Color(0xFF021D3C).withOpacity(0.7),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SharePrayer(
            prayerData: widget.prayerData,
            hasReminder: widget.hasReminder,
            reminder: widget.reminder,
          );
        });
  }

  void _unSnoozePrayer(CombinePrayerStream? prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProvider>(context, listen: false).unSnoozePrayer(
          prayerData?.prayer?.id ?? '',
          DateTime.now(),
          prayerData?.userPrayer?.id ?? '');
      BeStilDialog.hideLoading(context);
      Navigator.pop(context);

      AppController appController = Get.find();
      appController.setCurrentPage(0, true, 0);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  Widget build(BuildContext context) {
    bool isGroupPrayer = widget.prayerData?.prayer?.isGroup ?? false;
    final _user = Provider.of<UserProvider>(context).currentUser;
    bool isOwner = widget.prayerData?.prayer?.createdBy == _user.id;
    bool isArchived = widget.prayerData?.userPrayer?.isArchived ?? false;
    bool isSnoozed = widget.prayerData?.userPrayer?.isSnoozed ?? false;
    bool isAnswered = widget.prayerData?.prayer?.isAnswer ?? false;
    /*
    LOGICS FOR DISABLING
    ----------------------
      cases
      ---------
      is owner
      is archived
      is answered
      is snoozed
      -----------
      logics
      -----------
      Share => is archived,is snoozed,is answered
      Edit => is not owner, is archived,is snoozed,is answered
      Add update => is not owner, is archived,is snoozed,is answered
      Reminder => is not owner, is archived,is snoozed,is answered
      Snooze => is not owner, is archived,is answered
      Mark as Answered
      Mark as Favorite
      Archive
      Delete => is owner
      Un-follow => is group prayer
      Flag as inappropriate => is group prayer and not owner
    */

    return Container(
        padding: EdgeInsets.only(top: 50),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
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
                            backgroundColor: Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .isDarkModeEnabled
                                ? AppColors.backgroundColor[0].withOpacity(0.7)
                                : AppColors.white,
                            icon: AppIcons.bestill_share,
                            text: 'Share',
                            isDisabled: isAnswered || isSnoozed || isArchived,
                            onPress: () => isAnswered || isSnoozed || isArchived
                                ? () {}
                                : _share()),
                        LongButton(
                          textColor: AppColors.lightBlue3,
                          backgroundColor: Provider.of<ThemeProvider>(context,
                                      listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                          icon: AppIcons.bestill_edit,
                          isDisabled:
                              !isOwner | isAnswered || isSnoozed || isArchived,
                          onPress: !isOwner | isAnswered ||
                                  isSnoozed ||
                                  isArchived
                              ? () {}
                              : () async {
                                  try {
                                    Provider.of<PrayerProvider>(context,
                                            listen: false)
                                        .setEditMode(true, false);
                                    Provider.of<PrayerProvider>(context,
                                            listen: false)
                                        .setEditPrayer(
                                            prayer: widget.prayerData?.prayer ??
                                                PrayerModel.defaultValue(),
                                            updates:
                                                widget.prayerData?.updates ??
                                                    [],
                                            tags:
                                                widget.prayerData?.tags ?? []);
                                    Navigator.pop(context);
                                    await Future.delayed(
                                        Duration(milliseconds: 200));
                                    AppController appController = Get.find();

                                    appController.setCurrentPage(
                                        1, true, appController.currentPage);
                                  } on HttpException catch (e, s) {
                                    BeStilDialog.hideLoading(context);
                                    final user = Provider.of<UserProvider>(
                                            context,
                                            listen: false)
                                        .currentUser;
                                    BeStilDialog.showErrorDialog(
                                        context,
                                        StringUtils.getErrorMessage(e),
                                        user,
                                        s);
                                  } catch (e, s) {
                                    BeStilDialog.hideLoading(context);
                                    final user = Provider.of<UserProvider>(
                                            context,
                                            listen: false)
                                        .currentUser;
                                    BeStilDialog.showErrorDialog(context,
                                        StringUtils.errorOccured, user, s);
                                  }
                                },
                          text: 'Edit',
                        ),
                        LongButton(
                          textColor: AppColors.lightBlue3,
                          backgroundColor: Provider.of<ThemeProvider>(context,
                                      listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                          icon: AppIcons.bestill_update,
                          isDisabled:
                              !isOwner | isAnswered || isSnoozed || isArchived,
                          onPress: !isOwner | isAnswered ||
                                  isSnoozed ||
                                  isArchived
                              ? () {}
                              : () {
                                  Provider.of<PrayerProvider>(context,
                                          listen: false)
                                      .setEditPrayer(
                                          prayer: widget.prayerData?.prayer ??
                                              PrayerModel.defaultValue(),
                                          updates:
                                              widget.prayerData?.updates ?? [],
                                          tags: widget.prayerData?.tags ?? []);

                                  AppController appController = Get.find();
                                  appController.setCurrentPage(
                                      13, true, appController.currentPage);
                                  Navigator.pop(context);
                                },
                          text: 'Add an Update',
                        ),
                        LongButton(
                          textColor: AppColors.lightBlue3,
                          backgroundColor: Provider.of<ThemeProvider>(context,
                                      listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                          icon: AppIcons.bestill_reminder,
                          isDisabled:
                              !isOwner | isAnswered || isSnoozed || isArchived,
                          suffix: widget.hasReminder &&
                                  widget.reminder.frequency ==
                                      Frequency.one_time
                              ? DateFormat('dd MMM yyyy hh:mma').format(
                                  widget.reminder.scheduledDate ??
                                      DateTime.now())
                              : widget.hasReminder &&
                                      widget.reminder.frequency !=
                                          Frequency.one_time
                                  ? widget.reminder.frequency
                                  : '',
                          onPress: () => !isOwner | isAnswered ||
                                  isSnoozed ||
                                  isArchived
                              ? () {}
                              : showDialog(
                                  context: context,
                                  barrierColor: AppColors
                                      .detailBackgroundColor[1]
                                      .withOpacity(0.5),
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      insetPadding: EdgeInsets.all(20),
                                      backgroundColor:
                                          AppColors.prayerCardBgColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: AppColors.darkBlue),
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
                                            child: ReminderPicker(
                                              isGroup: false,
                                              entityId: widget.prayerData
                                                      ?.userPrayer?.id ??
                                                  '',
                                              type: NotificationType.reminder,
                                              hideActionuttons: false,
                                              reminder: widget.hasReminder
                                                  ? widget.reminder
                                                  : null,
                                              onCancel: () =>
                                                  Navigator.of(context).pop(),
                                              prayerData: widget.prayerData,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                          text: 'Reminder',
                        ),
                        LongButton(
                          textColor: AppColors.lightBlue3,
                          backgroundColor: Provider.of<ThemeProvider>(context,
                                      listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                          icon: AppIcons.bestill_snooze,
                          isDisabled: !isOwner | isAnswered || isArchived,
                          onPress: () => !isOwner | isAnswered || isArchived
                              ? () {}
                              : widget.prayerData?.userPrayer?.isSnoozed ??
                                      false
                                  ? _unSnoozePrayer(widget.prayerData)
                                  : showDialog(
                                      context: context,
                                      barrierColor: AppColors
                                          .detailBackgroundColor[1]
                                          .withOpacity(0.5),
                                      builder: (BuildContext context) => Dialog(
                                        insetPadding: EdgeInsets.all(20),
                                        backgroundColor:
                                            AppColors.prayerCardBgColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: AppColors.darkBlue),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 30),
                                              child: SnoozePrayer(
                                                  widget.prayerData),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          text:
                              widget.prayerData?.userPrayer?.isSnoozed ?? false
                                  ? 'Unsnooze'
                                  : 'Snooze',
                          // text: 'Snooze',
                        ),
                        LongButton(
                          textColor: AppColors.lightBlue3,
                          backgroundColor: Provider.of<ThemeProvider>(context,
                                      listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                          isDisabled: !isOwner && !isAdmin,
                          icon: AppIcons.bestill_answered,
                          onPress: !isOwner && !isAdmin
                              ? () {}
                              : () =>
                                  widget.prayerData?.prayer?.isAnswer ?? false
                                      ? _unMarkAsAnswered(widget.prayerData)
                                      : _onMarkAsAnswered(widget.prayerData),
                          text: widget.prayerData?.prayer?.isAnswer ?? false
                              ? 'Unmark as Answered'
                              : 'Mark as Answered',
                        ),
                        LongButton(
                          textColor: AppColors.lightBlue3,
                          backgroundColor: Provider.of<ThemeProvider>(context,
                                      listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                          icon:
                              widget.prayerData?.userPrayer?.isFavorite ?? false
                                  ? Icons.favorite_border_outlined
                                  : Icons.favorite,
                          isDisabled: !isOwner,
                          onPress: !isOwner
                              ? () {}
                              : () => widget
                                          .prayerData?.userPrayer?.isFavorite ??
                                      false
                                  ? _unMarkPrayerAsFavorite(widget.prayerData)
                                  : _markPrayerAsFavorite(widget.prayerData),
                          text:
                              widget.prayerData?.userPrayer?.isFavorite ?? false
                                  ? 'Unmark as Favorite '
                                  : 'Mark as Favorite ',
                        ),
                        LongButton(
                          textColor: AppColors.lightBlue3,
                          hasIcon: true,
                          isDisabled: !isOwner && !isAdmin,
                          backgroundColor: Provider.of<ThemeProvider>(context,
                                      listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                          icon: AppIcons
                              .bestill_icons_bestill_archived_icon_revised_drk,
                          onPress: !isOwner && !isAdmin
                              ? () {}
                              : () =>
                                  widget.prayerData?.userPrayer?.isArchived ??
                                          false
                                      ? _unArchive(widget.prayerData)
                                      : _onArchive(widget.prayerData),
                          text:
                              widget.prayerData?.userPrayer?.isArchived ?? false
                                  ? 'Unarchive'
                                  : 'Archive',
                        ),
                        LongButton(
                          textColor: AppColors.lightBlue3,
                          backgroundColor: Provider.of<ThemeProvider>(context,
                                      listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                          icon: Icons.delete_forever,
                          isDisabled: !isOwner,
                          onPress: !isOwner
                              ? () {}
                              : () => _openDeleteConfirmation(context),
                          text: 'Delete',
                        ),
                        if (isGroupPrayer)
                          LongButton(
                            textColor: AppColors.lightBlue3,
                            backgroundColor: Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .isDarkModeEnabled
                                ? AppColors.backgroundColor[0].withOpacity(0.7)
                                : AppColors.white,
                            icon: Icons.star,
                            isDisabled: !isGroupPrayer,
                            suffix: '',
                            onPress: () => _unFollowPrayer(),
                            text: 'Unfollow',
                          ),
                        if (isGroupPrayer)
                          LongButton(
                              textColor: AppColors.lightBlue3,
                              backgroundColor: Provider.of<ThemeProvider>(
                                          context,
                                          listen: false)
                                      .isDarkModeEnabled
                                  ? AppColors.backgroundColor[0]
                                      .withOpacity(0.7)
                                  : AppColors.white,
                              icon: Icons.info,
                              isDisabled: isGroupPrayer,
                              suffix: '',
                              onPress: () => () {},
                              text: 'Flag as inappropriate')
                      ])))
        ])));
  }
}
