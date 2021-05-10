import 'dart:async';
import 'dart:convert';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/add_update/add_update.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/menu-button.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/share_prayer.dart';
import 'package:be_still/widgets/snooze_prayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'delete_prayer.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PrayerMenu extends StatefulWidget {
  final BuildContext parentcontext;
  final bool hasReminder;
  final Function updateUI;
  final LocalNotificationModel reminder;
  @override
  PrayerMenu(
      this.parentcontext, this.hasReminder, this.reminder, this.updateUI);

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
    try {
      BeStilDialog.showLoading(
        context,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .favoritePrayer(prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  _unMarkPrayerAsFavorite(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(
        context,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .unfavoritePrayer(prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  _onDelete() async {
    BeStilDialog.showLoading(
      context,
    );
    final prayerData =
        Provider.of<PrayerProvider>(context, listen: false).currentPrayer;

    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == prayerData.prayer.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .deletePrayer(prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
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
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Are you sure you want to delete this prayer?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue4,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(
              height: 30,
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

  setNotification(selectedHour, selectedFrequency, selectedMinute, selectedDay,
      period, CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      final notificationText = selectedFrequency == Frequency.weekly
          ? '$selectedFrequency, $selectedDay, $selectedHour:$selectedMinute $period'
          : '$selectedFrequency, $selectedHour:$selectedMinute $period';
      final title = '$selectedFrequency reminder to pray';
      final description = prayerData.prayer.description;
      final scheduleDate = LocalNotification.scheduleDate(
          int.parse(selectedHour),
          int.parse(selectedMinute),
          selectedDay,
          period);
      final payload = NotificationMessage(
          entityId: prayerData.userPrayer.id, type: NotificationType.prayer);
      await LocalNotification.setLocalNotification(
        context: context,
        title: title,
        description: description,
        scheduledDate: scheduleDate,
        payload: jsonEncode(payload.toJson()),
        frequency: selectedFrequency,
      );
      if (widget.hasReminder)
        _updatePrayerTime(
          selectedDay,
          period,
          selectedFrequency,
          selectedHour,
          selectedMinute,
          scheduleDate,
          userId,
          notificationText,
        );
      else
        await storeNotification(
          notificationText,
          userId,
          title,
          description,
          selectedFrequency,
          scheduleDate,
          prayerData.userPrayer.id,
          selectedDay,
          period,
          selectedHour,
          selectedMinute,
        );
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  storeNotification(
    String notificationText,
    String userId,
    String title,
    String description,
    String frequency,
    tz.TZDateTime scheduledDate,
    String prayerid,
    String selectedDay,
    String period,
    String selectedHour,
    String selectedMinute,
  ) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .addLocalNotification(
      LocalNotification.localNotificationID,
      prayerid,
      notificationText,
      userId,
      prayerid,
      title,
      description,
      frequency,
      NotificationType.reminder,
      scheduledDate,
      selectedDay,
      period,
      selectedHour,
      selectedMinute,
    );
    await Future.delayed(Duration(milliseconds: 300));
    BeStilDialog.hideLoading(context);

    NavigationService.instance.goHome(0);
  }

  _updatePrayerTime(
    String selectedDay,
    String selectedPeriod,
    String selectedFrequency,
    String selectedHour,
    String selectedMinute,
    tz.TZDateTime scheduledDate,
    String userId,
    String notificationText,
  ) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .updateLocalNotification(
      selectedFrequency,
      scheduledDate,
      selectedDay,
      selectedPeriod,
      selectedHour,
      selectedMinute,
      widget.reminder.id,
      userId,
      notificationText,
    );
    await Future.delayed(Duration(milliseconds: 300));
    BeStilDialog.hideLoading(context);

    NavigationService.instance.goHome(0);
  }

  void _onMarkAsAnswered(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == prayerData.prayer.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));

      var reminders = notifications
          .where((e) => e.type == NotificationType.reminder)
          .toList();

      reminders.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));

      reminders.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(prayerData.prayer.id, prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _unMarkAsAnswered(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<PrayerProvider>(context, listen: false)
          .unMarkPrayerAsAnswered(
              prayerData.prayer.id, prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _unArchive(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<PrayerProvider>(context, listen: false)
          .unArchivePrayer(prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
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

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            child: EntryScreen(),
          ));
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void deleteNotifications(CombinePrayerStream prayerData) {}

  void _onArchive(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == prayerData.prayer.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      var reminders = Provider.of<NotificationProvider>(context, listen: false)
          .localNotifications
          .where((e) => e.type == NotificationType.reminder)
          .toList();
      reminders.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .archivePrayer(prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Widget build(BuildContext context) {
    final prayerData = Provider.of<PrayerProvider>(context).currentPrayer;
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10, left: 10, bottom: 30),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  AppIcons.bestill_close,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: AppColors.textFieldText,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MenuButton(
                  icon: AppIcons.bestill_share,
                  text: 'Share',
                  isDisable: prayerData.prayer.isAnswer ||
                      prayerData.userPrayer.isArchived,
                  onPressed: () => showModalBottomSheet(
                      context: context,
                      barrierColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.5),
                      backgroundColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SharePrayer(
                          prayerData: prayerData,
                        );
                      }),
                ),
                MenuButton(
                  icon: AppIcons.bestill_edit,
                  isDisable: prayerData.prayer.isAnswer ||
                      prayerData.userPrayer.isArchived,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPrayer(
                        isEdit: true,
                        prayerData: prayerData,
                      ),
                    ),
                  ),
                  text: 'Edit',
                ),
                MenuButton(
                  icon: AppIcons.bestill_update,
                  isDisable: prayerData.prayer.isAnswer ||
                      prayerData.userPrayer.isArchived,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddUpdate(),
                    ),
                  ),
                  text: 'Add an Update',
                ),
                MenuButton(
                  icon: AppIcons.bestill_reminder,
                  isDisable: prayerData.prayer.isAnswer ||
                      prayerData.userPrayer.isArchived,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    barrierColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.5),
                    backgroundColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.9),
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return ReminderPicker(
                        hideActionuttons: false,
                        frequency: LocalNotification.reminderInterval,
                        reminderDays: LocalNotification.reminderDays,
                        onCancel: () => Navigator.of(context).pop(),
                        onSave: (selectedFrequency, selectedHour,
                                selectedMinute, selectedDay, period) =>
                            setNotification(
                                selectedHour,
                                selectedFrequency,
                                selectedMinute,
                                selectedDay,
                                period,
                                prayerData),
                        selectedFrequency: widget.hasReminder
                            ? widget.reminder.frequency
                            : null,
                        selectedHour: widget.hasReminder
                            ? int.parse(widget.reminder.selectedHour)
                            : null,
                        selectedMinute: widget.hasReminder
                            ? int.parse(widget.reminder.selectedMinute)
                            : null,
                        selectedPeriod:
                            widget.hasReminder ? widget.reminder.period : null,
                      );
                    },
                  ),
                  text: widget.hasReminder ? 'Edit Reminder' : 'Set Reminder',
                ),
                MenuButton(
                  icon: AppIcons.bestill_snooze,
                  isDisable: prayerData.prayer.isAnswer ||
                      prayerData.userPrayer.isArchived,
                  onPressed: () => prayerData.userPrayer.isSnoozed
                      ? _unSnoozePrayer(prayerData)
                      : showModalBottomSheet(
                          context: context,
                          barrierColor: AppColors.detailBackgroundColor[1]
                              .withOpacity(0.5),
                          backgroundColor: AppColors.detailBackgroundColor[1]
                              .withOpacity(0.9),
                          isScrollControlled: true,
                          builder: (BuildContext context) =>
                              SnoozePrayer(prayerData),
                        ),
                  text: prayerData.userPrayer.isSnoozed ? 'Unsnooze' : 'Snooze',
                ),
                MenuButton(
                  icon: AppIcons.bestill_answered,
                  onPressed: () => prayerData.prayer.isAnswer
                      ? _unMarkAsAnswered(prayerData)
                      : _onMarkAsAnswered(prayerData),
                  text: prayerData.prayer.isAnswer
                      ? 'Unmark as Answered'
                      : 'Mark as Answered',
                ),
                MenuButton(
                  icon: prayerData.userPrayer.isFavorite
                      ? Icons.favorite_border_outlined
                      : Icons.favorite,
                  onPressed: () => prayerData.userPrayer.isFavorite
                      ? _unMarkPrayerAsFavorite(prayerData)
                      : _markPrayerAsFavorite(prayerData),
                  text: prayerData.userPrayer.isFavorite
                      ? 'Unmark as Favorite '
                      : 'Mark as Favorite ',
                ),
                MenuButton(
                  icon: AppIcons.bestill_archive,
                  onPressed: () => prayerData.userPrayer.isArchived
                      ? _unArchive(prayerData)
                      : _onArchive(prayerData),
                  text: prayerData.userPrayer.isArchived
                      ? 'Unarchive'
                      : 'Archive',
                ),
                MenuButton(
                  icon: AppIcons.bestill_delete,
                  onPressed: () => _openDeleteConfirmation(context),
                  text: 'Delete',
                ),
              ],
            ),
          ),
          // IconButton(
          //   icon: Icon(
          //     AppIcons.bestill_close,
          //   ),
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //   },
          //   color: AppColors.textFieldText,
          // ),
        ],
      ),
    );
  }
}
