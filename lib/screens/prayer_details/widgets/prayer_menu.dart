import 'dart:async';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/add_update/add_update.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/share_prayer.dart';
import 'package:be_still/widgets/snooze_prayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PrayerMenu extends StatefulWidget {
  final BuildContext parentcontext;
  final bool hasReminder;
  final Function updateUI;
  final CombinePrayerStream prayerData;
  final LocalNotificationModel reminder;
  @override
  PrayerMenu(this.parentcontext, this.hasReminder, this.reminder, this.updateUI,
      this.prayerData);

  @override
  _PrayerMenuState createState() => _PrayerMenuState();
}

class _PrayerMenuState extends State<PrayerMenu> {
  List<String> reminderInterval = [
    // 'Hourly',
    Frequency.daily,
    Frequency.weekly,
    // 'Monthly',
    // 'Yearly'
  ];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  _markPrayerAsFavorite(CombinePrayerStream prayerData) async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .favoritePrayer(prayerData.userPrayer.id);
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

  _unMarkPrayerAsFavorite(CombinePrayerStream prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .unfavoritePrayer(prayerData.userPrayer.id);
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

  _onDelete() async {
    BeStilDialog.showLoading(context);
    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == widget.prayerData.userPrayer.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .deletePrayer(widget.prayerData.userPrayer.id);
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

  @override
  void initState() {
    super.initState();
  }

  _openDeleteConfirmation(BuildContext context) {
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

  void _onMarkAsAnswered(CombinePrayerStream prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData.userPrayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(prayerData.prayer.id, prayerData.userPrayer.id);

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

  void _unMarkAsAnswered(CombinePrayerStream prayerData) async {
    BeStilDialog.showLoading(context);
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .unMarkPrayerAsAnswered(
              prayerData.prayer.id, prayerData.userPrayer.id);
      BeStilDialog.hideLoading(context);

      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
    } on HttpException catch (e, s) {
      // BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      // BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _unArchive(CombinePrayerStream prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .unArchivePrayer(prayerData.userPrayer.id, prayerData.prayer.id);
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

  void _unSnoozePrayer(CombinePrayerStream prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProvider>(context, listen: false).unSnoozePrayer(
          prayerData.prayer.id, DateTime.now(), prayerData.userPrayer.id);
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

  void _onArchive(CombinePrayerStream prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData.userPrayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));

      await Provider.of<PrayerProvider>(context, listen: false)
          .archivePrayer(widget.prayerData.userPrayer.id);
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

  Widget build(BuildContext context) {
    var isDisable = widget.prayerData.prayer.isAnswer ||
        widget.prayerData.userPrayer.isArchived ||
        widget.prayerData.userPrayer.isSnoozed;
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
                        isDisabled: isDisable,
                        onPress: () => isDisable ? null : _share()),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons.bestill_edit,
                      isDisabled: isDisable,
                      onPress: () => isDisable
                          ? null
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPrayer(
                                  isEdit: true,
                                  prayerData: widget.prayerData,
                                ),
                              ),
                            ),
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
                      isDisabled: isDisable,
                      onPress: () => isDisable
                          ? null
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddUpdate(),
                              ),
                            ),
                      text: 'Add an Update',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons.bestill_reminder,
                      isDisabled: isDisable,
                      suffix: widget.hasReminder &&
                              widget.reminder.frequency == Frequency.one_time
                          ? DateFormat('dd MMM yyyy HH:mma').format(widget
                              .reminder.scheduledDate) //'19 May 2021 11:45PM'
                          : widget.hasReminder &&
                                  widget.reminder.frequency !=
                                      Frequency.one_time
                              ? widget.reminder.frequency
                              : null,
                      onPress: () => isDisable
                          ? null
                          : showDialog(
                              context: context,
                              barrierColor: AppColors.detailBackgroundColor[1]
                                  .withOpacity(0.5),
                              builder: (BuildContext context) {
                                return Dialog(
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
                                        child: ReminderPicker(
                                          type: NotificationType.reminder,
                                          hideActionuttons: false,
                                          reminder: widget.hasReminder
                                              ? widget.reminder
                                              : null,
                                          onCancel: () =>
                                              Navigator.of(context).pop(),
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
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons.bestill_snooze,
                      isDisabled: widget.prayerData.prayer.isAnswer ||
                          widget.prayerData.userPrayer.isArchived,
                      onPress: () => widget.prayerData.prayer.isAnswer ||
                              widget.prayerData.userPrayer.isArchived
                          ? null
                          : widget.prayerData.userPrayer.isSnoozed
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
                                      side:
                                          BorderSide(color: AppColors.darkBlue),
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
                                          child:
                                              SnoozePrayer(widget.prayerData),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                      text: widget.prayerData.userPrayer.isSnoozed
                          ? 'Unsnooze'
                          : 'Snooze',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons.bestill_answered,
                      onPress: () => widget.prayerData.prayer.isAnswer
                          ? _unMarkAsAnswered(widget.prayerData)
                          : _onMarkAsAnswered(widget.prayerData),
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
                      icon: widget.prayerData.userPrayer.isFavorite
                          ? Icons.favorite_border_outlined
                          : Icons.favorite,
                      onPress: () => widget.prayerData.userPrayer.isFavorite
                          ? _unMarkPrayerAsFavorite(widget.prayerData)
                          : _markPrayerAsFavorite(widget.prayerData),
                      text: widget.prayerData.userPrayer.isFavorite
                          ? 'Unmark as Favorite '
                          : 'Mark as Favorite ',
                    ),
                    LongButton(
                      textColor: AppColors.lightBlue3,
                      hasIcon: true,
                      backgroundColor:
                          Provider.of<ThemeProvider>(context, listen: false)
                                  .isDarkModeEnabled
                              ? AppColors.backgroundColor[0].withOpacity(0.7)
                              : AppColors.white,
                      icon: AppIcons
                          .bestill_icons_bestill_archived_icon_revised_drk,
                      onPress: () => widget.prayerData.userPrayer.isArchived
                          ? _unArchive(widget.prayerData)
                          : _onArchive(widget.prayerData),
                      text: widget.prayerData.userPrayer.isArchived
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
                      icon: AppIcons.bestill_close,
                      onPress: () => _openDeleteConfirmation(context),
                      text: 'Delete',
                    ),
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
