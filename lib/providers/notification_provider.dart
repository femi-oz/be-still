import 'package:be_still/models/notification.model.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class NotificationProvider with ChangeNotifier {
  NotificationService _notificationService = locator<NotificationService>();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  Future setUserNotifications(String userId) async {
    _notificationService
        .getUserNotifications(userId)
        .asBroadcastStream()
        .listen((notifications) {
      _notifications = notifications;
      notifyListeners();
    });
  }
}
