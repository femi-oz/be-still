import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  List<LocalNotificationModel> _prayerTimeNotifications = [];
  List<LocalNotificationModel> get prayerTimeNotifications =>
      _prayerTimeNotifications;

  List<LocalNotificationModel> _localNotifications = [];
  List<LocalNotificationModel> get localNotifications => _localNotifications;
  Future<void> init(BuildContext context) async {
    _firebaseMessaging.configure(
      // onMessage: (Map<String, dynamic> message) async {
      //   print("onMessage: $message");
      //   onRoute(message, context);
      // },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        onRoute(message, context);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        onRoute(message, context);
      },
    );
  }

  Future<void> onRoute(message, context) async {
    if (message['type'] == 'prayer' && message['entityId'] != 'N/A') {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayer(message['entityId']);
      Navigator.of(context).pushNamed(PrayerDetails.routeName);
      print(message);
    }
    return;
  }

  Future<void> setDevice(String userId) async {
    if (!_initialized) {
      // For testing purposes print the Firebase Messaging token
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: true, badge: true, alert: true, provisional: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
      String token = await _firebaseMessaging.getToken();
      await _notificationService.init(token, userId);
      _initialized = true;
    }
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
      notifyListeners();
    });
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
    String fallbackRoute,
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
        selectedDay,
        period,
        selectedHour,
        selectedMinute);
  }

  Future<void> deleteLocalNotification(String notificationId) async {
    var notification =
        _localNotifications.firstWhere((e) => e.id == notificationId);
    await LocalNotification.unschedule(notification.localNotificationId);
    await _notificationService.removeLocalNotification(notificationId);
  }

  Future<void> deletePrayerTime(String prayerTimeId) async =>
      await _notificationService.deletePrayerTime(prayerTimeId);

  Future<void> updateLocalNotification(
      String selectedDay,
      String selectedPeriod,
      String selectedFrequency,
      String selectedHour,
      String selectedMinute,
      String notificationId) async {
    await _notificationService.updatePrayerTimeNotification(
        selectedDay,
        selectedPeriod,
        selectedFrequency,
        selectedHour,
        selectedMinute,
        notificationId);
  }

  //   Future<void> addPrayerTime(
  //     String selectedDay,
  //     String selectedFrequency,
  //     String period,
  //     String selectedHour,
  //     String selectedMinute,
  //     String userId) async =>
  // await _notificationService.addPrayerTime(selectedDay, selectedFrequency, period,
  //     selectedHour, selectedMinute, userId);

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
