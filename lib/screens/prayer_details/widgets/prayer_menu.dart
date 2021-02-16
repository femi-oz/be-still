import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/menu-button.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/share_prayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'delete_prayer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class PrayerMenu extends StatefulWidget {
  final CombinePrayerStream prayerData;
  final List<PrayerUpdateModel> updates;

  final BuildContext parentcontext;
  @override
  PrayerMenu(this.prayerData, this.updates, this.parentcontext);

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
  List<String> snoozeInterval = [
    '7 Days',
    '14 Days',
    '30 Days',
    '90 Days',
    '1 Year'
  ];
  List<String> reminderDays = [
    DaysOfWeek.mon,
    DaysOfWeek.tue,
    DaysOfWeek.wed,
    DaysOfWeek.thu,
    DaysOfWeek.fri,
    DaysOfWeek.sat,
    DaysOfWeek.sun,
  ];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future onSelectNotification(String payload) async {
    await Provider.of<PrayerProvider>(context, listen: false)
        .setPrayer(widget.prayerData.userPrayer.id);
    Navigator.of(context).pushNamed(PrayerDetails.routeName);
  }

  @override
  void initState() {
    _configureLocalTimeZone();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
    super.initState();
  }

  int _getExactDy(day) {
    var now = new DateTime.now();

    while (now.weekday != day) {
      now = now.subtract(new Duration(days: 1));
    }
    return now.day;
  }

  String currentTimeZone;
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();

    currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  tz.TZDateTime _scheduleDate(
      selectedHour, selectedMinute, selectedDay, period) {
    var day = reminderDays.indexOf(selectedDay) + 1;
    var hour = period == PeriodOfDay.am ? selectedHour : selectedHour + 12;
    hour = hour == 24 ? 00 : hour;
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, _getExactDy(day), hour, selectedMinute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  String reminderId;
  int localNotificationId;
  bool get hasReminder {
    var reminders = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications;
    final prayerData =
        Provider.of<PrayerProvider>(context, listen: false).currentPrayer;
    var reminder = reminders.firstWhere(
        (reminder) => reminder.entityId == prayerData.prayer.id,
        orElse: () => null);
    reminderId = reminder?.id ?? '';
    localNotificationId = reminder?.localNotificationId ?? 0;

    if (reminder == null)
      return false;
    else
      return true;
  }

  setNotification(selectedHour, selectedFrequency, selectedMinute, selectedDay,
      period) async {
    if (hasReminder) {
      Provider.of<NotificationProvider>(context, listen: false)
          .deleteLocalNotification(reminderId);
      flutterLocalNotificationsPlugin.cancel(localNotificationId);
    }
    var localNots = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications;
    var localId = localNots.length > 0
        ? localNots
                .reduce((a, b) =>
                    a.localNotificationId > b.localNotificationId ? a : b)
                .localNotificationId +
            1
        : 0;
    await flutterLocalNotificationsPlugin.zonedSchedule(
        localId,
        '$selectedFrequency reminder to pray',
        widget.prayerData.prayer.description,
        _scheduleDate(selectedHour, selectedMinute, selectedDay, period),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name', 'your channel description'),
            iOS: IOSNotificationDetails()),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: selectedFrequency.toString().toLowerCase() ==
                Frequency.daily.toLowerCase()
            ? DateTimeComponents.time
            : DateTimeComponents
                .dayOfWeekAndTime); //daily:time,weekly:dayOfWeekAndTime
    var notificationText = selectedFrequency == Frequency.weekly
        ? '$selectedFrequency, $selectedDay, $selectedHour:$selectedMinute $period'
        : '$selectedFrequency, $selectedHour:$selectedMinute $period';
    await storeNotification(localId, notificationText);
  }

  storeNotification(localId, notificationText) async {
    try {
      BeStilDialog.showLoading(bcontext);
      await Provider.of<NotificationProvider>(context, listen: false)
          .addLocalNotification(
              localId, widget.prayerData.prayer.id, notificationText);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      _goToDetails();
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  BuildContext bcontext;

  void _onMarkAsAnswered() async {
    try {
      BeStilDialog.showLoading(bcontext);
      await Provider.of<PrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(widget.prayerData.prayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      _goToDetails();
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  void _unArchive() async {
    try {
      BeStilDialog.showLoading(bcontext);
      await Provider.of<PrayerProvider>(context, listen: false)
          .unArchivePrayer(widget.prayerData.prayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      _goToDetails();
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  void _onArchive() async {
    try {
      BeStilDialog.showLoading(bcontext);
      await Provider.of<PrayerProvider>(context, listen: false)
          .archivePrayer(widget.prayerData.prayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      _goToDetails();
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  _goToDetails() {
    Navigator.of(context).pushReplacementNamed(PrayerDetails.routeName);
  }

  Widget build(BuildContext context) {
    List<String> updates = [];
    widget.updates.forEach((data) => {
          updates = [...updates, data.description].toList()
        });

    var newUpdates = updates.join("<br>");

    setState(() => this.bcontext = context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MenuButton(
                  icon: AppIcons.bestill_share,
                  text: 'Share',
                  onPressed: () => showModalBottomSheet(
                      context: context,
                      barrierColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.5),
                      backgroundColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SharePrayer(
                            prayer: widget.prayerData.prayer.description,
                            updates:
                                widget.updates.length > 0 ? newUpdates : '');
                      }),
                ),
                MenuButton(
                  icon: AppIcons.bestill_edit,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPrayer(
                        isEdit: true,
                        prayer: widget.prayerData.prayer,
                      ),
                    ),
                  ),
                  text: 'Edit',
                ),
                MenuButton(
                  icon: AppIcons.bestill_reminder,
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
                        frequency: reminderInterval,
                        reminderDays: reminderDays,
                        onCancel: () => Navigator.of(context).pop(),
                        onSave: (selectedFrequency, selectedHour,
                                selectedMinute, selectedDay, period) =>
                            setNotification(selectedHour, selectedFrequency,
                                selectedMinute, selectedDay, period),
                      );
                    },
                  ),
                  text: 'Reminder',
                ),
                MenuButton(
                  icon: AppIcons.bestill_snooze,
                  onPressed: () => null,
                  // showModalBottomSheet(
                  //   context: context,
                  //   barrierColor:
                  //       AppColors.detailBackgroundColor[1].withOpacity(0.5),
                  //   backgroundColor:
                  //       AppColors.detailBackgroundColor[1].withOpacity(0.9),
                  //   isScrollControlled: true,
                  //   builder: (BuildContext context) {
                  //     return CustomPicker(
                  //         snoozeInterval, setSnooze, false, null);
                  //   },
                  // ),
                  text: 'Snooze',
                ),
                widget.prayerData.prayer.isAnswer == false
                    ? MenuButton(
                        icon: AppIcons.bestill_answered,
                        onPressed: () => _onMarkAsAnswered(),
                        text: 'Mark as Answered',
                      )
                    : Container(),
                widget.prayerData.prayer.status == Status.active &&
                        !widget.prayerData.prayer.isArchived
                    ? MenuButton(
                        icon: AppIcons.bestill_archive,
                        onPressed: () => _onArchive(),
                        text: 'Archive',
                      )
                    : MenuButton(
                        icon: AppIcons.bestill_archive,
                        onPressed: () => _unArchive(),
                        text: 'Unarchive',
                      ),
                MenuButton(
                  icon: AppIcons.bestill_delete,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    barrierColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.5),
                    backgroundColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.9),
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return DeletePrayer(widget.prayerData);
                    },
                  ),
                  text: 'Delete',
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              AppIcons.bestill_close,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: AppColors.textFieldText,
          ),
        ],
      ),
    );
  }
}
