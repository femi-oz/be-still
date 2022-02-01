import 'package:be_still/enums/time_range.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static String reminderId = '';
  static int localNotificationID = 0;
  static List<String> daysOfWeek = [
    DaysOfWeek.mon,
    DaysOfWeek.tue,
    DaysOfWeek.wed,
    DaysOfWeek.thu,
    DaysOfWeek.fri,
    DaysOfWeek.sat,
    DaysOfWeek.sun,
  ];

  static List<String> frequency = [
    Frequency.one_time,
    Frequency.daily,
    Frequency.weekly,
  ];

  static List<String> months = new List<String>.generate(12,
      (i) => DateFormat('MMM').format(DateTime(DateTime.now().year, i + 1)));

  static Future<void> setNotificationsOnNewDevice(context) async {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    final _localNotifications =
        await Provider.of<NotificationProvider>(context, listen: false)
            .getLocalNotificationsFuture(userId);
    //set notification in new device

    // The device's timezone.
    String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

    // Find the 'current location'
    final location = tz.getLocation(timeZoneName);
    //set notification in new device
    for (int i = 0; i < _localNotifications.length; i++) {
      final scheduledDate = tz.TZDateTime.from(
          _localNotifications[i].scheduledDate ?? DateTime.now(), location);
      await setLocalNotification(
        title: _localNotifications[i].title ?? '',
        description: _localNotifications[i].description ?? '',
        scheduledDate: scheduledDate,
        payload: _localNotifications[i].payload,
        frequency: _localNotifications[i].frequency ?? '',
        context: context,
      );
    }
  }

  static Future<void> setLocalNotification({
    required String title,
    required String description,
    required tz.TZDateTime scheduledDate,
    required payload,
    required String frequency,
    required BuildContext context,
    int? localNotificationId,
  }) async {
    if (localNotificationId != null)
      localNotificationID = localNotificationId;
    else {
      final localNots =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications;
      final allIds = localNots.map((e) => e.localNotificationId).toList();

      localNotificationID = allIds.length > 0
          ? allIds.reduce((a, b) => (a ?? 0) > (b ?? 0) ? a : b) ?? 0 + 1
          : 0;
    }
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      localNotificationID,
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
    int selectedHour,
    int selectedMinute,
    int selectedDay,
    String period,
    int selectedYear,
    String selectedMonth,
    int selectedDayOfMonth,
    bool isOneTime,
  ) {
    int hour = selectedHour;
    if (period == PeriodOfDay.am && selectedHour == 12)
      hour = 00;
    else if (period == PeriodOfDay.pm && selectedHour == 12) hour = 12;
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      isOneTime ? selectedYear : now.year,
      isOneTime ? months.indexOf(selectedMonth) + 1 : now.month,
      isOneTime ? selectedDayOfMonth : _getExactDy(selectedDay),
      hour,
      selectedMinute,
    );
    if (scheduledDate.isBefore(now) && !isOneTime) {
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
