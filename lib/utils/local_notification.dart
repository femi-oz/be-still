import 'package:be_still/enums/time_range.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static BuildContext _context;
  static String reminderId;
  static int localNotificationId;
  static String _fallbackRoute;
  static List<String> reminderDays = [
    DaysOfWeek.mon,
    DaysOfWeek.tue,
    DaysOfWeek.wed,
    DaysOfWeek.thu,
    DaysOfWeek.fri,
    DaysOfWeek.sat,
    DaysOfWeek.sun,
  ];

  static Future<void> configureNotification(
      BuildContext context, String fallbackRoute) async {
    _context = context;
    _fallbackRoute = fallbackRoute;
    tz.initializeTimeZones();

    var currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    _flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: _onSelectNotification);
  }

  static Future _onSelectNotification(String payload) async {
    if (_fallbackRoute == PrayerDetails.routeName)
      await Provider.of<PrayerProvider>(_context, listen: false)
          .setPrayer(payload);
    Navigator.of(_context).pushNamed(_fallbackRoute);
  }

  static Future<void> setLocalNotification({
    @required String title,
    @required String description,
    @required tz.TZDateTime scheduledDate,
    @required payload,
    @required String frequency,
  }) async {
    final localNots = Provider.of<NotificationProvider>(_context, listen: false)
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

  static bool get _hasReminder {
    var reminders = Provider.of<NotificationProvider>(_context, listen: false)
        .localNotifications;
    final prayerData =
        Provider.of<PrayerProvider>(_context, listen: false).currentPrayer;
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
}
