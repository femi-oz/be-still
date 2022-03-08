import 'dart:async';
import 'dart:convert';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/models/v2/local_notification.model.dart';
import 'package:be_still/models/v2/notification.model.dart';
import 'package:be_still/models/v2/notification_message.model.dart';

import 'package:be_still/providers/v2/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:be_still/services/v2/notification_service.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:flutter/material.dart';

class NotificationProviderV2 with ChangeNotifier {
  NotificationServiceV2 _notificationService = locator<NotificationServiceV2>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  NotificationProviderV2._();
  factory NotificationProviderV2() => _instance;

  static final NotificationProviderV2 _instance = NotificationProviderV2._();
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late StreamSubscription<List<NotificationModel>> userNotificationStream;
  late StreamSubscription<List<LocalNotificationDataModel>>
      localNotificationStream;
  late StreamSubscription<List<LocalNotificationDataModel>> prayerTimeStream;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  List<NotificationModel> _requests = [];
  List<NotificationModel> get requests => _requests;

  List<NotificationModel> _inappropriateContent = [];
  List<NotificationModel> get inappropriateContent => _inappropriateContent;

  List<NotificationModel> _leftGroup = [];
  List<NotificationModel> get leftGroup => _leftGroup;

  List<NotificationModel> _joinGroup = [];
  List<NotificationModel> get joinGroup => _joinGroup;

  List<NotificationModel> _requestAccepted = [];
  List<NotificationModel> get requestAccepted => _requestAccepted;

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
    _message = NotificationMessageModel.defaultValue();
  }

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
      _notificationService.init(userDevices);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future disablePushNotifications(String notificationId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _notificationService.cancelPushNotification(notificationId);
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

        _newPrayers = notifications
            .where((e) => e.type == NotificationType.prayer)
            .toList();

        _prayerUpdates = notifications
            .where((e) => e.type == NotificationType.prayer_updates)
            .toList();

        _editedPrayers = notifications
            .where((e) => e.type == NotificationType.edited_prayers)
            .toList();

        _archivedPrayers = notifications
            .where((e) => e.type == NotificationType.archived_prayers)
            .toList();

        _answeredPrayers = notifications
            .where((e) => e.type == NotificationType.answered_prayers)
            .toList();

        _notifications = notifications;

        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearNotification() async {
    try {
      var notificationsToClear =
          _notifications.where((e) => e.type != NotificationType.request);
      await _notificationService.clearAllNotifications(
          ids: notificationsToClear.map((e) => e.id ?? '').toList());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setLocalNotifications(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      localNotificationStream = _notificationService
          .getUserLocalNotification()
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

  Future<void> _deletePastReminder(
      List<LocalNotificationDataModel> data) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var reminderToDelete = data
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

  Future<void> setPrayerTimeNotifications(userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      prayerTimeStream = _notificationService
          .getUserLocalNotification()
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
      return await _notificationService.cancelPushNotification(notificationId);
    } catch (e) {
      rethrow;
    }
  }

  Future sendPushNotification(
    String message,
    String type,
    String senderName,
    List<String> tokens,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _notificationService.addNotification(
          senderName: senderName, message: message, tokens: tokens, type: type);
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
      await setLocalNotifications(_firebaseAuth.currentUser?.uid ?? '');
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
  ) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _notificationService.updateLocalNotification(
          notificationId: notificationId,
          message: message,
          localNotificationId: localNotificationId,
          type: type,
          scheduleDate: scheduledDate,
          status: status);
      await setLocalNotifications(_firebaseAuth.currentUser?.uid ?? '');
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

  Future sendPrayerNotification(
      String? prayerId,
      String? groupPrayerId,
      String? type,
      String? selectedGroupId,
      BuildContext context,
      String? prayerDetail,
      List<GroupUserDataModel> members,
      List<String> followers) async {
    try {
      List<String> _ids = [];
      final _user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;

      if (type == NotificationType.prayer ||
          type == NotificationType.prayer_updates) {
        _ids = members.map((e) => e.userId ?? '').toList();
      } else {
        _ids = followers;
      }

      _ids.removeWhere((e) => e == _user.id);

      for (final id in _ids) {
        final member = members.firstWhere((element) => element.userId == id);
        if (type == NotificationType.prayer ||
            type == NotificationType.prayer_updates) {
          if (member.enableNotificationFormNewPrayers ?? false) {
            final userTokens =
                await Provider.of<UserProviderV2>(context, listen: false)
                    .returnUserToken(id);
            final name = ((_user.firstName ?? '').capitalizeFirst ?? '') +
                ' ' +
                ((_user.lastName ?? '').capitalizeFirst ?? '');

            sendPushNotification(prayerDetail?.capitalizeFirst ?? '',
                type ?? '', name, userTokens);
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  void cancelLocalNotifications() {
    _flutterLocalNotificationsPlugin.cancelAll();
  }

  void flush() {
    userNotificationStream.cancel();
    localNotificationStream.cancel();
    prayerTimeStream.cancel();
    resetValues();
  }
}
