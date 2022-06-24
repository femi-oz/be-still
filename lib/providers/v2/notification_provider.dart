import 'dart:async';
import 'dart:convert';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/local_notification.model.dart';
import 'package:be_still/models/v2/notification.model.dart';
import 'package:be_still/models/v2/notification_message.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:be_still/services/v2/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationProviderV2 with ChangeNotifier {
  NotificationServiceV2 _notificationService = locator<NotificationServiceV2>();
  UserServiceV2 _userService = locator<UserServiceV2>();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late StreamSubscription<List<NotificationModel>> userNotificationStream;

  late StreamSubscription<List<LocalNotificationDataModel>>
      localNotificationStream;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  List<NotificationModel> _requests = [];
  List<NotificationModel> get requests => _requests;

  List<NotificationModel> _adminRequests = [];
  List<NotificationModel> get adminRequests => _adminRequests;

  List<NotificationModel> _inappropriateContent = [];
  List<NotificationModel> get inappropriateContent => _inappropriateContent;

  List<NotificationModel> _leftGroup = [];
  List<NotificationModel> get leftGroup => _leftGroup;

  List<NotificationModel> _joinGroup = [];
  List<NotificationModel> get joinGroup => _joinGroup;

  List<NotificationModel> _requestAccepted = [];
  List<NotificationModel> get requestAccepted => _requestAccepted;

  List<NotificationModel> _requestDenied = [];
  List<NotificationModel> get requestDenied => _requestDenied;

  List<NotificationModel> _newPrayers = [];
  List<NotificationModel> get newPrayers => _newPrayers;

  List<NotificationModel> _prayerUpdates = [];
  List<NotificationModel> get prayerUpdates => _prayerUpdates;

  List<NotificationModel> _editedPrayers = [];
  List<NotificationModel> get editedPrayers => _editedPrayers;

  List<NotificationModel> _archivedPrayers = [];
  List<NotificationModel> get archivedPrayers => _archivedPrayers;

  List<NotificationModel> _answeredPrayers = [];
  List<NotificationModel> get answeredPrayers => _answeredPrayers;

  List<LocalNotificationDataModel> _prayerTimeNotifications = [];
  List<LocalNotificationDataModel> get prayerTimeNotifications =>
      _prayerTimeNotifications;

  List<LocalNotificationDataModel> _localNotifications = [];
  List<LocalNotificationDataModel> get localNotifications =>
      _localNotifications;
  NotificationMessageModel _message = NotificationMessageModel.defaultValue();
  NotificationMessageModel get message => _message;

  resetValues() {
    _notifications = [];
    _prayerTimeNotifications = [];
    _localNotifications = [];
    _answeredPrayers = [];
    _archivedPrayers = [];
    _editedPrayers = [];
    _prayerUpdates = [];
    _joinGroup = [];
    _requestAccepted = [];
    _requestDenied = [];
    _inappropriateContent = [];
    _leftGroup = [];
    _requests = [];
    _adminRequests = [];
    _prayerTimeNotifications = [];
    _message = NotificationMessageModel.defaultValue();
  }

  Future<void> initLocal(BuildContext context) async {
    tz.initializeTimeZones();

    var currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    _flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: _onSelectNotification);
  }

  Future _onSelectNotification(String? payload) async {
    try {
      final messagePayload = jsonDecode(payload ?? '');
      _message = NotificationMessageModel.fromData(messagePayload);
      if ((_message.type ?? '').toLowerCase() == 'fcm message') {
        AppController appController = Get.find();
        appController.setCurrentPage(14, false, 0);
      }
    } catch (e) {
      print(e);
    }
  }

  Future init(List<DeviceModel> userDevices) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _userService.addPushToken(userDevices);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearMessage() async {
    try {
      _message = NotificationMessageModel.defaultValue();
      notifyListeners();
    } catch (e) {}
  }

  Future setUserNotifications(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      userNotificationStream = _notificationService
          .getUserPushNotifications()
          .asBroadcastStream()
          .listen((notifications) async {
        notifications.sort((a, b) => (b.createdDate ?? DateTime.now())
            .compareTo(a.createdDate ?? DateTime.now()));
        _requests = notifications
            .where((e) => e.type == NotificationType.request)
            .toList();

        _adminRequests = notifications
            .where((e) => e.type == NotificationType.adminRequest)
            .toList();

        _inappropriateContent = notifications
            .where((e) => e.type == NotificationType.inappropriate_content)
            .toList();

        _leftGroup = notifications
            .where((e) => e.type == NotificationType.leave_group)
            .toList();

        _joinGroup = notifications
            .where((e) => e.type == NotificationType.join_group)
            .toList();

        _requestAccepted = notifications
            .where((e) => e.type == NotificationType.accept_request)
            .toList();

        _requestDenied = notifications
            .where((e) => e.type == NotificationType.deny_request)
            .toList();

        _newPrayers = notifications
            .where((e) => e.type == NotificationType.prayer)
            .toList();

        final updates = notifications
            .where((e) => e.type == NotificationType.prayer_updates)
            .toList();

        _prayerUpdates = [];
        var idSet = <String>{};
        for (var e in updates) {
          if (idSet.add(e.prayerId ?? '')) {
            _prayerUpdates.add(e);
          }
        }

        _editedPrayers = notifications
            .where((e) => e.type == NotificationType.edited_prayers)
            .toList();

        _archivedPrayers = notifications
            .where((e) => e.type == NotificationType.archived_prayers)
            .toList();

        _answeredPrayers = notifications
            .where((e) => e.type == NotificationType.answered_prayers)
            .toList();

        _notifications = [
          ..._requests,
          ..._adminRequests,
          ..._inappropriateContent,
          ..._leftGroup,
          ..._joinGroup,
          ..._requestAccepted,
          ..._requestDenied,
          ..._newPrayers,
          ..._prayerUpdates,
          ..._editedPrayers,
          ..._archivedPrayers,
          ..._answeredPrayers
        ];

        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearNotification() async {
    try {
      var notificationsToClear = _notifications.where((e) =>
          e.type != NotificationType.request &&
          e.type != NotificationType.adminRequest &&
          e.type != NotificationType.inappropriate_content);
      await _notificationService.clearAllNotifications(
          ids: notificationsToClear.map((e) => e.id ?? '').toList());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setLocalNotifications() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      localNotificationStream = _notificationService
          .getLocalNotifications()
          .asBroadcastStream()
          .listen((notifications) {
        _localNotifications = notifications;
        _localNotifications.sort((a, b) => (b.modifiedDate ?? DateTime.now())
            .compareTo(a.modifiedDate ?? DateTime.now()));
        _prayerTimeNotifications = notifications
            .where((e) => e.type == NotificationType.prayer_time)
            .toList();
        _deletePastReminder(notifications);
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocalNotificationDataModel>> getLocalNotificationsFuture() async {
    try {
      return _notificationService
          .getLocalNotificationsFuture()
          .then((notifications) {
        _localNotifications = notifications;
        return notifications;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocalNotificationDataModel>> getLocalNotificationsByPrayerId(
      String prayerId) async {
    try {
      return _notificationService
          .getLocalNotificationsByPrayerId(prayerId)
          .then((notifications) {
        return notifications;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _deletePastReminder(
      List<LocalNotificationDataModel> data) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      final reminderToDelete = data
          .where((e) =>
              (e.scheduleDate ?? DateTime.now()).isBefore(DateTime.now()) &&
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

  Future cancelNotification(String notificationId, {String? prayerId}) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return await _notificationService.cancelPushNotification(
          notificationId, prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future deleteInappropriateNotification(
      String senderId, String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return await _notificationService.cancelInappropriateNotification(
          senderId, prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future sendPushNotification(
      String message, String type, String senderName, List<String> tokens,
      {String? groupId, String? prayerId, String? receiverId}) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _notificationService.addNotification(
        groupId: groupId ?? '',
        prayerId: prayerId ?? '',
        receiverId: receiverId ?? '',
        senderName: senderName,
        message: message,
        tokens: tokens,
        type: type,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addLocalNotification(
    String prayerId,
    int localId,
    String message,
    String type,
    String frequency,
    DateTime scheduledDate,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _notificationService.storeLocalNotifications(
          prayerId: prayerId,
          message: message,
          type: type,
          frequency: frequency,
          localNotificationId: localId,
          scheduleDate: scheduledDate);
      await setLocalNotifications();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLocalNotification(
    DateTime scheduledDate,
    String notificationId,
    String message,
    int localNotificationId,
    String type,
    String status,
    String frequency,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _notificationService.updateLocalNotification(
          notificationId: notificationId,
          message: message,
          localNotificationId: localNotificationId,
          type: type,
          scheduleDate: scheduledDate,
          status: status,
          frequency: frequency);
      await setLocalNotifications();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLocalNotification(
      String notificationId, int localNotificationId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;

      // await LocalNotification.unschedule(localNotificationId);
      await _notificationService.removeLocalNotification(notificationId);
    } catch (e) {
      rethrow;
    }
  }

  Future sendPrayerNotification(
      String prayerId, String type, String groupId, String message,
      {PrayerDataModel? prayerData}) async {
    try {
      _notificationService.sendPrayerNotification(
        prayerData: prayerData,
        message: message,
        type: type,
        groupId: groupId,
        prayerId: prayerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelLocalNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelLocalNotificationById(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> flagAsInappropriate(
      String prayerId,
      String groupId,
      String adminId,
      String senderName,
      List<String> tokens,
      String groupName) async {
    final message = '$senderName flagged a prayer as inappropriate';
    await _notificationService.addNotification(
        prayerId: prayerId,
        message: message,
        senderName: groupName,
        type: NotificationType.inappropriate_content,
        tokens: tokens,
        groupId: groupId,
        receiverId: adminId);
  }

  Future flush() async {
    resetValues();
    await userNotificationStream.cancel();
    await localNotificationStream.cancel();
  }
}
