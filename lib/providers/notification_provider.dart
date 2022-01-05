import 'dart:convert';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:be_still/services/notification_service.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:flutter/material.dart';
import '../locator.dart';
import 'group_prayer_provider.dart';

class NotificationProvider with ChangeNotifier {
  NotificationService _notificationService = locator<NotificationService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
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

  Future init(String token, String userId, UserModel currentUser) async {
    if (_firebaseAuth.currentUser == null) return null;
    _notificationService.init(token, userId, currentUser);
    notifyListeners();
  }

  Future disablePushNotifications(String userId, UserModel currentUser) async {
    if (_firebaseAuth.currentUser == null) return null;
    _notificationService.disablePushNotifications(userId, currentUser);
    notifyListeners();
  }

  Future enablePushNotifications(
      String token, String userId, UserModel currentUser) async {
    if (_firebaseAuth.currentUser == null) return null;
    _notificationService.enablePushNotification(token, userId, currentUser);
    notifyListeners();
  }

  Future<void> clearMessage() async {
    _message = null;
  }

  Future<void> setUserNotifications(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    _notificationService
        .getUserNotifications(userId)
        .asBroadcastStream()
        .listen((notifications) {
      _notifications =
          notifications.where((e) => e.status == Status.active).toList();
      _notifications =
          _notifications.where((e) => e.recieverId == userId).toList();
      notifyListeners();
    });
  }

  Future<void> clearNotification() async {
    var notificationsToClear =
        _notifications.where((e) => e.messageType != NotificationType.request);
    await _notificationService
        .clearNotification(notificationsToClear.map((e) => e.id).toList());

    notifyListeners();
  }

  Future<void> setLocalNotifications(userId) async {
    if (_firebaseAuth.currentUser == null) return null;
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
    if (_firebaseAuth.currentUser == null) return null;
    var reminderToDelete = data
        .where((e) =>
            e.scheduledDate.isBefore(DateTime.now()) &&
            e.frequency == Frequency.one_time)
        .toList();
    for (int i = 0; i < reminderToDelete.length; i++) {
      await deleteLocalNotification(reminderToDelete[i].id);
    }
    notifyListeners();
  }

  Future<void> setPrayerTimeNotifications(userId) async {
    if (_firebaseAuth.currentUser == null) return null;
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

  Future updateNotification(String notificationId) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _notificationService.updatePushNotification(notificationId);
  }

  Future sendPushNotification(
    String message,
    String messageType,
    String sender,
    String senderId,
    String recieverId,
    String title,
    String entityId,
    String entityId2,
    List<String> tokens,
  ) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _notificationService.sendPushNotification(
        message: message,
        entityId: entityId,
        entityId2: entityId2,
        messageType: messageType,
        sender: sender,
        senderId: senderId,
        recieverId: recieverId,
        tokens: tokens,
        title: title);
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
    if (_firebaseAuth.currentUser == null) return null;
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
    await setLocalNotifications(userId);
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
    if (_firebaseAuth.currentUser == null) return null;
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
    if (_firebaseAuth.currentUser == null) return null;
    var notification =
        _localNotifications.firstWhere((e) => e.id == notificationId);
    await LocalNotification.unschedule(notification.localNotificationId);
    await _notificationService.removeLocalNotification(notificationId);
  }

  Future<void> deletePrayerTime(String prayerTimeId) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _notificationService.deletePrayerTime(prayerTimeId);
  }

  Future sendPrayerNotification(
    String prayerId,
    String type,
    String selectedGroupId,
    BuildContext context,
    String prayerDetail,
  ) async {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

    List<String> followers =
        Provider.of<GroupPrayerProvider>(context, listen: false)
            .followedPrayers
            .map((e) => e.userId)
            .toList();
    final admins = Provider.of<GroupProvider>(context, listen: false)
        .currentGroup
        .groupUsers
        .where((e) => e.role == GroupUserRole.admin)
        .map((e) => e.userId)
        .toList();
    final _ids = [...followers, ...admins];
    _ids.removeWhere((e) => e == _user.id);
    _ids.forEach((e) async {
      final value = await Provider.of<UserProvider>(context, listen: false)
          .returnUserToken(e);

      sendPushNotification(
          prayerDetail,
          type,
          _user.firstName + ' ' + _user.lastName,
          _user.id,
          e,
          type == NotificationType.prayer ? 'New Prayer' : 'Prayer Update',
          prayerId,
          selectedGroupId,
          [value]);
    });
  }
}
