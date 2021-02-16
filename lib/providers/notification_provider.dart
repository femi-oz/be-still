import 'dart:io';

import 'package:be_still/models/notification.model.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../locator.dart';

class NotificationProvider with ChangeNotifier {
  NotificationService _notificationService = locator<NotificationService>();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  List<LocalNotificationModel> _localNotifications = [];
  List<LocalNotificationModel> get localNotifications => _localNotifications;

  Future setUserNotifications(String userId) async {
    _notificationService
        .getUserNotifications(userId)
        .asBroadcastStream()
        .listen((notifications) {
      _notifications = notifications;
      notifyListeners();
    });
  }

  Future acceptGroupInvite(
      String groupId, String userId, String name, String email) async {
    return await _notificationService.acceptGroupInvite(
        groupId, userId, name, email);
  }

  Future newPrayerGroupNotification(String prayerId, String groupId) async {
    return await _notificationService.newPrayerGroupNotification(
        prayerId, groupId);
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

  Future addLocalNotification(int localId) async {
    await _notificationService.addLocalNotification(localId);
  }

  Future deleteLocalNotification(String notificationId) async {
    await _notificationService.removeLocalNotification(notificationId);
  }
}
