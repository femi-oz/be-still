import 'dart:convert';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/notification.model.dart';
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

  Future init(String token, String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    _notificationService.init(token, userId);
    notifyListeners();
  }

  Future disablePushNotifications(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    _notificationService.disablePushNotifications(userId);
    notifyListeners();
  }

  Future enablePushNotifications(String token, String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    _notificationService.enablePushNotification(token, userId);
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
      notifyListeners();
    });
  }

  Future<void> clearNotification(BuildContext context) async {
    // _notifications = [];
    BeStilDialog.showLoading(context);
    var notificationsToClear =
        _notifications.where((e) => e.messageType != NotificationType.request);
    await _notificationService
        .clearNotification(notificationsToClear.map((e) => e.id).toList());
    BeStilDialog.hideLoading(context);
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

  Future addPushNotification(
    String message,
    String messageType,
    String sender,
    String senderId,
    String recieverId,
    String title,
    String entityId,
  ) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _notificationService.addPushNotification(
        message: message,
        entityId: entityId,
        messageType: messageType,
        sender: sender,
        senderId: senderId,
        recieverId: recieverId,
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

  Future sendPrayerNotification(String prayerId, String type,
      String selectedGroupId, BuildContext context, String prayerDetail) async {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final data = Provider.of<GroupProvider>(context, listen: false).userGroups;
    List receiver;
    var followedPrayers;
    if (type == NotificationType.prayer_updates) {
      final editPrayerId =
          Provider.of<GroupPrayerProvider>(context, listen: false)
              .prayerToEdit
              .prayer
              .id;
      followedPrayers = Provider.of<GroupPrayerProvider>(context, listen: false)
          .followedPrayers;
      receiver = followedPrayers
          .where((element) => element.prayerId == editPrayerId)
          .toList();
    } else {
      data.forEach((element) {
        int validGroupsLength = element.groupUsers
            .where((e) => e.groupId == selectedGroupId && e.userId != _user.id)
            .toList()
            .length;
        if (validGroupsLength > 0) {
          receiver = element.groupUsers
              .where(
                  (e) => e.groupId == selectedGroupId && e.userId != _user.id)
              .toList();
        }
      });
    }

    for (var i = 0; i < receiver.length; i++) {
      if (receiver.length > 0) {
        addPushNotification(
            prayerDetail,
            type,
            _user.firstName,
            _user.id,
            receiver[i].userId,
            type == NotificationType.prayer ? 'New Prayer' : 'Prayer Update',
            prayerId);
      }
    }
  }
}
