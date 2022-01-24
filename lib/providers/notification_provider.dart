import 'dart:convert';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
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
  NotificationMessage _message = NotificationMessage.defaultValue();
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

  Future _onSelectNotification(String? payload) async {
    try {
      final messagePayload = jsonDecode(payload ?? '');
      _message = NotificationMessage.fromData(messagePayload);
      if ((_message.type ?? '').toLowerCase() == 'fcm message') {
        AppController appController = Get.find();
        appController.setCurrentPage(14, false);
      }
    } catch (e) {
      print(e);
    }
  }

  Future init(String token, String userId, UserModel currentUser) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _notificationService.init(token, userId, currentUser);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future disablePushNotifications(String userId, UserModel currentUser) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _notificationService.disablePushNotifications(userId, currentUser);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future enablePushNotifications(
      String token, String userId, UserModel currentUser) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _notificationService.enablePushNotification(token, userId, currentUser);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearMessage() async {
    try {
      _message = NotificationMessage.defaultValue();
      notifyListeners();
    } catch (e) {}
  }

  Future<void> setNotifications() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _notificationService
          .getAllNotifications()
          .asBroadcastStream()
          .listen((notifications) {
        _notifications = notifications;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setUserNotifications(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _notificationService
          .getUserNotifications(userId)
          .asBroadcastStream()
          .listen((notifications) {
        _notifications = notifications;

        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearNotification() async {
    try {
      var notificationsToClear = _notifications
          .where((e) => e.messageType != NotificationType.request);
      await _notificationService.clearNotification(
          notificationsToClear.map((e) => e.id ?? '').toList());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setLocalNotifications(userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _notificationService
          .getLocalNotifications(userId)
          .asBroadcastStream()
          .listen((notifications) {
        _localNotifications = notifications;
        _deletePastReminder(notifications);
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _deletePastReminder(List<LocalNotificationModel> data) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var reminderToDelete = data
          .where((e) =>
              (e.scheduledDate ?? DateTime.now()).isBefore(DateTime.now()) &&
              e.frequency == Frequency.one_time)
          .toList();
      for (int i = 0; i < reminderToDelete.length; i++) {
        await deleteLocalNotification(reminderToDelete[i].id ?? '',
            reminderToDelete[i].localNotificationId ?? 0);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setPrayerTimeNotifications(userId) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  Future updateNotification(String notificationId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return await _notificationService.updatePushNotification(notificationId);
    } catch (e) {
      rethrow;
    }
  }

  Future sendPushNotification(
    String message,
    String messageType,
    String sender,
    String senderId,
    String receiverId,
    String title,
    String prayerId,
    String groupId,
    List<String> tokens,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return await _notificationService.sendPushNotification(
          message: message,
          prayerId: prayerId,
          groupId: groupId,
          messageType: messageType,
          sender: sender,
          senderId: senderId,
          recieverId: receiverId,
          tokens: tokens,
          title: title);
    } catch (e) {
      rethrow;
    }
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
    try {
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
    } catch (e) {
      rethrow;
    }
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
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLocalNotification(
      String notificationId, int localNotificationId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;

      await LocalNotification.unschedule(localNotificationId);
      await _notificationService.removeLocalNotification(notificationId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePrayerTime(String prayerTimeId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _notificationService.deletePrayerTime(prayerTimeId);
    } catch (e) {
      rethrow;
    }
  }

  Future sendPrayerNotification(
    String? prayerId,
    String? groupPrayerId,
    String? type,
    String? selectedGroupId,
    BuildContext context,
    String? prayerDetail,
  ) async {
    try {
      List<String> _ids = [];
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      List<String> members = [];

      List<String> followers = [];

      if (type == NotificationType.prayer) {
        members = (Provider.of<GroupProvider>(context, listen: false)
                    .currentGroup
                    .groupUsers ??
                [])
            .map((e) => e.userId ?? '')
            .toList();
        _ids = [...members];
      } else {
        final prayers =
            await Provider.of<GroupPrayerProvider>(context, listen: false)
                .setFollowedPrayers(prayerId);
        followers = prayers.map((e) => e.userId ?? '').toList();
        _ids = [...followers];
      }
      _ids.removeWhere((e) => e == _user.id);
      _ids.forEach((e) {
        Provider.of<UserProvider>(context, listen: false).returnUserToken(e);
        final value =
            Provider.of<UserProvider>(context, listen: false).userToken;
        final name = ((_user.firstName ?? '').capitalizeFirst ?? '') +
            ' ' +
            ((_user.lastName ?? '').capitalizeFirst ?? '');

        sendPushNotification(
            prayerDetail?.capitalizeFirst ?? '',
            type ?? '',
            name,
            _user.id ?? '',
            (e),
            type ?? '',
            groupPrayerId ?? '',
            selectedGroupId ?? '',
            [value]);
      });
    } catch (e) {
      rethrow;
    }
  }
}
