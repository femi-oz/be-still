import 'package:be_still/enums/time_range.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static String reminderId;
  static int localNotificationId;
  static List<String> reminderDays = [
    DaysOfWeek.mon,
    DaysOfWeek.tue,
    DaysOfWeek.wed,
    DaysOfWeek.thu,
    DaysOfWeek.fri,
    DaysOfWeek.sat,
    DaysOfWeek.sun,
  ];

  static Future<void> setNotificationsOnNewDevice(context) async {
    final _localNotifications =
        Provider.of<NotificationProvider>(context, listen: false)
            .localNotifications;
    //set notification in new device

    // The device's timezone.
    String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

    // Find the 'current location'
    final location = tz.getLocation(timeZoneName);
    //set notification in new device
    for (int i = 0; i < _localNotifications.length; i++) {
      final scheduledDate =
          tz.TZDateTime.from(_localNotifications[i].scheduledDate, location);
      await setLocalNotification(
        title: _localNotifications[i].title,
        description: _localNotifications[i].description,
        scheduledDate: scheduledDate,
        payload: _localNotifications[i].payload,
        frequency: _localNotifications[i].frequency,
        context: context,
      );
    }
  }

  static Future<void> setLocalNotification({
    @required String title,
    @required String description,
    @required tz.TZDateTime scheduledDate,
    @required payload,
    @required String frequency,
    @required BuildContext context,
  }) async {
    final localNots = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications;
    final allIds = localNots.map((e) => e.localNotificationId).toList();

    localNotificationId =
        allIds.length > 0 ? allIds.reduce((a, b) => a > b ? a : b) + 1 : 0;
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      localNotificationId,
      title,
      description,
      scheduledDate,
      const NotificationDetails(
          android: AndroidNotificationDetails('your channel id',
              'your channel name', 'your channel description'),
          iOS: IOSNotificationDetails()),
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          frequency.toString().toLowerCase() == Frequency.daily.toLowerCase()
              ? DateTimeComponents.time
              : DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static int _getExactDy(day) {
    var now = new DateTime.now();

    while (now.weekday != day) {
      now = now.subtract(new Duration(days: 1));
    }
    return now.day;
  }

  static tz.TZDateTime scheduleDate(
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

  static Future<void> clearAll() async {
    _flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> unschedule(id) async {
    _flutterLocalNotificationsPlugin.cancel(id);
  }
}
