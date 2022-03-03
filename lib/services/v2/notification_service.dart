import 'dart:io';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/flavor_config.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/v2/local_notification.model.dart';
import 'package:be_still/models/v2/message.model.dart';
import 'package:be_still/models/v2/notification.mode.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
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

  Future<void> addNotification({
    required String message,
    required List<String> tokens,
    required String type,
    required String userId,
  }) async {
    try {
      final doc = NotificationModel(
        message: message,
        status: Status.active,
        tokens: tokens,
        type: type,
        userId: userId,
        modifiedBy: userId,
        createdBy: userId,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();
      _notificationCollectionReference.add(doc);
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> storeLocalNotifications({
    required String message,
    required String type,
    required String userId,
    required int localNotificationId,
    required DateTime scheduleDate,
  }) async {
    try {
      final doc = LocalNotificationModel(
        message: message,
        status: Status.active,
        localNotificationId: localNotificationId,
        scheduleDate: scheduleDate,
        type: type,
        userId: userId,
        modifiedBy: userId,
        createdBy: userId,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();
      _localNotificationCollectionReference.add(doc);
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Stream<List<NotificationModel>> getUserPushNotifications(String userId) {
    try {
      return _notificationCollectionReference
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((event) => event.docs
              .map((e) => NotificationModel.fromJson(e.data()))
              .toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> cancelPushNotification(
      {required DocumentReference notificationReference}) async {
    try {
      notificationReference.update({'status': Status.inactive});
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
}
