import 'dart:io';

import 'package:be_still/enums/status.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../locator.dart';

class NotificationProvider with ChangeNotifier {
  NotificationService _notificationService = locator<NotificationService>();
  NotificationProvider._();
  factory NotificationProvider() => _instance;

  static final NotificationProvider _instance = NotificationProvider._();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  List<LocalNotificationModel> _localNotifications = [];
  List<LocalNotificationModel> get localNotifications => _localNotifications;
  Future<void> init(String userId) async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      await _notificationService.init(token, userId);
      // });
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

  Future setLocalNotifications() async {
    final DeviceInfoPlugin info = new DeviceInfoPlugin();
    String deviceId;
    try {
      if (Platform.isAndroid) {
        var build = await info.androidInfo;
        deviceId = build.androidId;
      } else if (Platform.isIOS) {
        var build = await info.iosInfo;
        deviceId = build.identifierForVendor;
      }
    } on PlatformException {
      print("couldn't fetch platform");
    }
    _notificationService
        .getLocalNotifications(deviceId)
        .asBroadcastStream()
        .listen((notifications) {
      _localNotifications = notifications;
      notifyListeners();
    });
  }

  Future addLocalNotification(
      int localId, String entityId, String notificationText) async {
    await _notificationService.addLocalNotification(
        localId, entityId, notificationText);
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
