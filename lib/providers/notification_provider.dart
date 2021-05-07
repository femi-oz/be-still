import 'dart:convert';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:be_still/services/notification_service.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:flutter/material.dart';
import '../locator.dart';

class NotificationProvider with ChangeNotifier {
  NotificationService _notificationService = locator<NotificationService>();
  NotificationProvider._();
  factory NotificationProvider() => _instance;

  static final NotificationProvider _instance = NotificationProvider._();
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<PushNotificationModel> _notifications = [];
  List<PushNotificationModel> get notifications => _notifications;

  List<LocalNotificationModel> _prayerTimeNotifications = [];
  List<LocalNotificationModel> get prayerTimeNotifications =>
      _prayerTimeNotifications;

  List<LocalNotificationModel> _localNotifications = [];
  List<LocalNotificationModel> get localNotifications => _localNotifications;
  NotificationMessage _message;
  NotificationMessage get message => _message;

  Future<void> initLocal(BuildContext context) async {
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

  Future _onSelectNotification(String payload) async {
    _message = NotificationMessage.fromData(jsonDecode(payload));
    print('message -- prov _onSelectNotification ===> $_message');
  }

  Future<void> clearMessage() async {
    _message = null;
  }

  Future<void> setUserNotifications(String userId) async {
    _notificationService
        .getUserNotifications(userId)
        .asBroadcastStream()
        .listen((notifications) {
      _notifications =
          notifications.where((e) => e.status == Status.active).toList();
      notifyListeners();
    });
  }

  Future<void> clearNotification() async {
    _notifications = [];
    notifyListeners();
    await _notificationService
        .clearNotification(_notifications.map((e) => e.id).toList());
  }

  Future<void> setLocalNotifications(userId) async {
    _notificationService
        .getLocalNotifications(userId)
        .asBroadcastStream()
        .listen((notifications) {
      _localNotifications = notifications;
      _deletePastReminder(notifications);
      notifyListeners();
    });
  }

  Future<void> _deletePastReminder(List<LocalNotificationModel> data) async {
    var reminderToDelete =
        data.where((e) => e.scheduledDate.isBefore(DateTime.now())).toList();
    for (int i = 0; i < reminderToDelete.length; i++) {
      await deleteLocalNotification(reminderToDelete[i].id);
    }
  }

  Future<void> setPrayerTimeNotifications(userId) async {
    _notificationService
        .getLocalNotifications(userId)
        .asBroadcastStream()
        .listen((notifications) {
      _prayerTimeNotifications = notifications
          .where((e) => e.type == NotificationType.prayer_time)
          .toList();
      notifyListeners();
    });
  }

  Future<void> addLocalNotification(
    int localId,
    String entityId,
    String notificationText,
    String userId,
    String payload,
    String title,
    String description,
    String frequency,
    String type,
    DateTime scheduledDate,
    String selectedDay,
    String period,
    String selectedHour,
    String selectedMinute,
    String selectedYear,
    String selectedMonth,
    String selectedDayOfMonth,
  ) async {
    await _notificationService.addLocalNotification(
      localId,
      entityId,
      notificationText,
      userId,
      payload,
      title,
      description,
      frequency,
      type,
      scheduledDate,
      selectedDay,
      period,
      selectedHour,
      selectedMinute,
      selectedYear,
      selectedMonth,
      selectedDayOfMonth,
    );
    notifyListeners();
  }

  Future<void> updateLocalNotification(
    String frequency,
    DateTime scheduledDate,
    String selectedDay,
    String period,
    String selectedHour,
    String selectedMinute,
    String notificationId,
    String userId,
    String notificationText,
    String selectedYear,
    String selectedMonth,
    String selectedDayOfMonth,
  ) async {
    await _notificationService.updateLocalNotification(
      frequency,
      scheduledDate,
      selectedDay,
      period,
      selectedHour,
      selectedMinute,
      notificationId,
      notificationText,
      selectedYear,
      selectedMonth,
      selectedDayOfMonth,
    );
    await setLocalNotifications(userId);
    notifyListeners();
  }

  Future<void> deleteLocalNotification(String notificationId) async {
    var notification =
        _localNotifications.firstWhere((e) => e.id == notificationId);
    await LocalNotification.unschedule(notification.localNotificationId);
    await _notificationService.removeLocalNotification(notificationId);
  }

  Future<void> deletePrayerTime(String prayerTimeId) async =>
      await _notificationService.deletePrayerTime(prayerTimeId);
}
