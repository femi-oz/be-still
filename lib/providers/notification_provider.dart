import 'package:be_still/enums/status.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../locator.dart';

class NotificationProvider with ChangeNotifier {
  NotificationService _notificationService = locator<NotificationService>();
  NotificationProvider._();
  factory NotificationProvider() => _instance;

  static final NotificationProvider _instance = NotificationProvider._();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  List<PushNotificationModel> _notifications = [];
  List<PushNotificationModel> get notifications => _notifications;

  List<LocalNotificationModel> _localNotifications = [];
  List<LocalNotificationModel> get localNotifications => _localNotifications;
  Future<void> init(String userId) async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print(token);
      await _notificationService.init(token, userId);
    }

    _initialized = true;
  }

  Future setUserNotifications(String userId) async {
    _notificationService
        .getUserNotifications(userId)
        .asBroadcastStream()
        .listen((notifications) {
      _notifications =
          notifications.where((e) => e.status == Status.active).toList();
      notifyListeners();
    });
  }

  Future clearNotification() async {
    await _notificationService
        .clearNotification(_notifications.map((e) => e.id).toList());
  }

  Future setLocalNotifications(userId) async {
    _notificationService
        .getLocalNotifications(userId)
        .asBroadcastStream()
        .listen((notifications) {
      _localNotifications = notifications;
      notifyListeners();
    });
  }

  Future addLocalNotification(
    int localId,
    String entityId,
    String notificationText,
    String userId,
    String fallbackRoute,
    String payload,
    String title,
    String description,
    String frequency,
    String type,
    DateTime scheduledDate,
  ) async {
    await _notificationService.addLocalNotification(
      localId,
      entityId,
      notificationText,
      userId,
      fallbackRoute,
      payload,
      title,
      description,
      frequency,
      type,
      scheduledDate,
    );
  }

  Future deleteLocalNotification(String notificationId) async {
    await _notificationService.removeLocalNotification(notificationId);
  }

  // Future acceptGroupInvite(
  //     String groupId, String userId, String name, String email) async {
  //   return await _notificationService.acceptGroupInvite(
  //       groupId, userId, name, email);
  // }

  // Future newPrayerGroupNotification(String prayerId, String groupId) async {
  //   return await _notificationService.newPrayerGroupNotification(
  //       prayerId, groupId);
  // }
}
