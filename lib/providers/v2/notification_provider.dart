import 'dart:async';

import 'package:be_still/locator.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/v2/notification.model.dart';
import 'package:be_still/services/v2/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationProviderV2 with ChangeNotifier {
  NotificationServiceV2 _notificationService = locator<NotificationServiceV2>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  NotificationProviderV2._();
  factory NotificationProviderV2() => _instance;

  static final NotificationProviderV2 _instance = NotificationProviderV2._();
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late StreamSubscription<List<NotificationModel>> userNotificationStream;
  late StreamSubscription<List<LocalNotificationModel>> localNotificationStream;
  late StreamSubscription<List<LocalNotificationModel>> prayerTimeStream;

  List<PushNotificationModel> _notifications = [];
  List<PushNotificationModel> get notifications => _notifications;

  List<PushNotificationModel> _requests = [];
  List<PushNotificationModel> get requests => _requests;

  List<PushNotificationModel> _inappropriateContent = [];
  List<PushNotificationModel> get inappropriateContent => _inappropriateContent;

  List<PushNotificationModel> _leftGroup = [];
  List<PushNotificationModel> get leftGroup => _leftGroup;

  List<PushNotificationModel> _joinGroup = [];
  List<PushNotificationModel> get joinGroup => _joinGroup;

  List<PushNotificationModel> _requestAccepted = [];
  List<PushNotificationModel> get requestAccepted => _requestAccepted;

  List<PushNotificationModel> _newPrayers = [];
  List<PushNotificationModel> get newPrayers => _newPrayers;

  List<PushNotificationModel> _prayerUpdates = [];
  List<PushNotificationModel> get prayerUpdates => _prayerUpdates;

  List<PushNotificationModel> _editedPrayers = [];
  List<PushNotificationModel> get editedPrayers => _editedPrayers;

  List<PushNotificationModel> _archivedPrayers = [];
  List<PushNotificationModel> get archivedPrayers => _archivedPrayers;

  List<PushNotificationModel> _answeredPrayers = [];
  List<PushNotificationModel> get answeredPrayers => _answeredPrayers;

  List<LocalNotificationModel> _prayerTimeNotifications = [];
  List<LocalNotificationModel> get prayerTimeNotifications =>
      _prayerTimeNotifications;

  List<LocalNotificationModel> _localNotifications = [];
  List<LocalNotificationModel> get localNotifications => _localNotifications;
  NotificationMessage _message = NotificationMessage.defaultValue();
  NotificationMessage get message => _message;
}
