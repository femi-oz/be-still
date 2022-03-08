import 'dart:io';

import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/flavor_config.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/local_notification.model.dart';
import 'package:be_still/models/v2/message.model.dart';
import 'package:be_still/models/v2/notification.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationServiceV2 {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>> _smsCollectionReference =
      FirebaseFirestore.instance.collection("SMSMessage");
  final CollectionReference<Map<String, dynamic>> _emailCollectionReference =
      FirebaseFirestore.instance.collection("MailMessage");
  final CollectionReference<Map<String, dynamic>>
      _notificationCollectionReference =
      FirebaseFirestore.instance.collection("notifications");
  final CollectionReference<Map<String, dynamic>>
      _localNotificationCollectionReference =
      FirebaseFirestore.instance.collection("local_notifications");

  final CollectionReference<Map<String, dynamic>> _userDataCollectionReference =
      FirebaseFirestore.instance.collection("users");

  UserServiceV2 _userService = locator<UserServiceV2>();

  init(List<DeviceModel> userDevices) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _userService.addPushToken(userDevices);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> addNotification({
    required String message,
    required String senderName,
    required List<String> tokens,
    required String type,
  }) async {
    try {
      final doc = NotificationModel(
        message: message,
        status: Status.active,
        tokens: tokens,
        type: type,
        userId: _firebaseAuth.currentUser?.uid,
        modifiedBy: _firebaseAuth.currentUser?.uid,
        createdBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();
      _notificationCollectionReference.add(doc);
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> storeLocalNotifications({
    required String prayerId,
    required String message,
    required String type,
    required String frequency,
    required int localNotificationId,
    required DateTime scheduleDate,
  }) async {
    try {
      final doc = LocalNotificationDataModel(
        message: message,
        status: Status.active,
        localNotificationId: localNotificationId,
        scheduleDate: scheduleDate,
        frequency: frequency,
        prayerId: prayerId,
        type: type,
        userId: _firebaseAuth.currentUser?.uid,
        modifiedBy: _firebaseAuth.currentUser?.uid,
        createdBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();
      _localNotificationCollectionReference.add(doc).then((value) =>
          _localNotificationCollectionReference
              .doc(value.id)
              .update({'id': value.id}));
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Stream<List<NotificationModel>> getUserPushNotifications() {
    try {
      return _notificationCollectionReference
          .where('userId', isEqualTo: _firebaseAuth.currentUser?.uid)
          .snapshots()
          .map((event) => event.docs
              .map((e) => NotificationModel.fromJson(e.data()))
              .toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> cancelPushNotification(String notificationId) async {
    try {
      _notificationCollectionReference
          .doc(notificationId)
          .update({'status': Status.inactive});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> addSMS({
    String? senderId,
    String? message,
    String? sender,
    String? phoneNumber,
    String? title,
    MessageTemplate? template,
    String? receiver,
  }) async {
    String _templateBody = template?.templateBody ?? '';
    _templateBody = (_templateBody).replaceAll('{Sender}', sender ?? '');
    _templateBody = _templateBody.replaceAll("{Receiver}", receiver ?? '');
    _templateBody = _templateBody.replaceAll('{message}', message ?? '');
    _templateBody = _templateBody.replaceAll('<br/>', "\n");
    _templateBody =
        _templateBody.replaceAll("{Link}", 'https://www.bestillapp.com/');
    final data = MessageModel(
        email: '',
        phoneNumber: phoneNumber,
        isSent: 0,
        senderId: senderId,
        title: title,
        message: _templateBody,
        sender: sender,
        createdBy: senderId,
        createdOn: DateTime.now(),
        modifiedBy: senderId,
        modifiedOn: DateTime.now(),
        receiver: receiver,
        subject: '',
        country: FlavorConfig.instance.values.country);
    try {
      _smsCollectionReference.add(data.toJson());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> addEmail({
    String? senderId,
    String? message,
    String? sender,
    String? email,
    String? title,
    String? receiver,
    MessageTemplate? template,
  }) async {
    String templateSubject = template?.templateSubject ?? '';
    String? templateBody = template?.templateBody;
    templateSubject = (templateSubject).replaceAll("{Sender}", sender ?? '');
    templateBody = templateBody ?? ''.replaceAll("{Receiver}", receiver ?? '');
    templateBody = templateBody.replaceAll("{Sender}", sender ?? '');
    templateBody = templateBody.replaceAll("{message}", message ?? '');
    templateBody = templateBody.replaceAll(
        "{Link}", "<a href='https://www.bestillapp.com/'>Learn more.</a>");

    final data = MessageModel(
        email: email,
        phoneNumber: '',
        isSent: 0,
        senderId: senderId,
        title: title,
        message: templateBody,
        sender: sender,
        createdBy: senderId,
        createdOn: DateTime.now(),
        modifiedBy: senderId,
        modifiedOn: DateTime.now(),
        receiver: receiver,
        subject: templateSubject,
        country: '');
    try {
      _emailCollectionReference.add(data.toJson());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<LocalNotificationDataModel>> getUserLocalNotification() {
    return _localNotificationCollectionReference
        .where('userId', isEqualTo: _firebaseAuth.currentUser?.uid)
        .snapshots()
        .map((event) => event.docs
            .map((e) => LocalNotificationDataModel.fromJson(e.data()))
            .toList());
  }

  Future<void> updateLocalNotification({
    required String notificationId,
    required String message,
    required int localNotificationId,
    required String type,
    required DateTime scheduleDate,
    required String status,
  }) async {
    try {
      await _notificationCollectionReference.doc(notificationId).update({
        'message': message,
        'localNotificationId': localNotificationId,
        'type': type,
        'scheduleDate': scheduleDate,
        'status': status,
        'modifiedBy': _firebaseAuth.currentUser?.uid,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> removeLocalNotification(String notificationId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _localNotificationCollectionReference.doc(notificationId).delete();
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> clearAllNotifications({required List<String> ids}) async {
    try {
      ids.forEach((element) {
        _notificationCollectionReference.doc(element).delete();
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }
}
