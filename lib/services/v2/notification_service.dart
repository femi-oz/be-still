import 'dart:io';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/flavor_config.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/local_notification.model.dart';
import 'package:be_still/models/v2/message.model.dart';
import 'package:be_still/models/v2/message_template.dart';
import 'package:be_still/models/v2/notification.model.dart';
import 'package:be_still/services/v2/group_service.dart';
import 'package:be_still/services/v2/prayer_service.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

class NotificationServiceV2 {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>> _smsCollectionReference =
      FirebaseFirestore.instance.collection("messages");
  final CollectionReference<Map<String, dynamic>> _emailCollectionReference =
      FirebaseFirestore.instance.collection("emails");
  final CollectionReference<Map<String, dynamic>>
      _notificationCollectionReference =
      FirebaseFirestore.instance.collection("notifications");
  final CollectionReference<Map<String, dynamic>>
      _localNotificationCollectionReference =
      FirebaseFirestore.instance.collection("local_notifications");

  Future<void> addNotification({
    required String message,
    required String senderName,
    required List<String> tokens,
    required String type,
    required String groupId,
    required String prayerId,
    required String receiverId,
  }) async {
    try {
      final doc = NotificationModel(
        message: message,
        status: Status.active,
        tokens: tokens,
        isSent: 0,
        type: type,
        groupId: groupId,
        prayerId: prayerId,
        receiverId: receiverId,
        senderId: _firebaseAuth.currentUser?.uid,
        modifiedBy: _firebaseAuth.currentUser?.uid,
        createdBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();
      _notificationCollectionReference.add(doc).then((value) {
        _notificationCollectionReference.doc(value.id).update({'id': value.id});
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> sendPrayerNotification({
    required String message,
    required String type,
    required String groupId,
    required String prayerId,
  }) async {
    try {
      final _userService = locator<UserServiceV2>();
      final _groupService = locator<GroupServiceV2>();
      final _prayerService = locator<PrayerServiceV2>();
      List<String> _ids = [];
      final _user = await _userService
          .getUserByIdFuture(_firebaseAuth.currentUser?.uid ?? '');

      final group = await _groupService.getGroup(groupId);
      final prayer = await _prayerService.getPrayerFuture(prayerId);

      if (type == NotificationType.prayer ||
          type == NotificationType.edited_prayers ||
          type == NotificationType.prayer_updates) {
        _ids = (group.users ?? []).map((e) => e.userId ?? '').toList();
      } else {
        _ids = (prayer.followers ?? []).map((e) => e.userId ?? '').toList();
      }

      _ids.removeWhere((e) => e == _firebaseAuth.currentUser?.uid);

      for (final id in _ids) {
        final member =
            (group.users ?? []).firstWhere((element) => element.userId == id);
        List<String> userTokens = [];

        if (type == NotificationType.inappropriate_content) {
          userTokens = await _userService.getUserByIdFuture(id).then((value) =>
              (value.devices ?? []).map((e) => e.token ?? '').toList());
        }

        final name = ((_user.firstName ?? '').capitalizeFirst ?? '') +
            ' ' +
            ((_user.lastName ?? '').capitalizeFirst ?? '');

        if (type == NotificationType.prayer ||
            type == NotificationType.edited_prayers) {
          if (member.enableNotificationForNewPrayers ?? false) {
            addNotification(
                message: message.capitalizeFirst ?? '',
                senderName: name,
                groupId: groupId,
                receiverId: id,
                prayerId: prayerId,
                tokens: userTokens,
                type: type);
          }
        } else if (type == NotificationType.prayer_updates) {
          if (member.enableNotificationForUpdates ?? false) {
            addNotification(
                message: message.capitalizeFirst ?? '',
                senderName: name,
                groupId: groupId,
                receiverId: id,
                prayerId: prayerId,
                tokens: userTokens,
                type: type);
          }
        } else {
          addNotification(
              message: message.capitalizeFirst ?? '',
              senderName: name,
              groupId: groupId,
              receiverId: id,
              prayerId: prayerId,
              tokens: userTokens,
              type: type);
        }
      }
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

  Stream<List<LocalNotificationDataModel>> getLocalNotifications() {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _localNotificationCollectionReference
          .where('userId', isEqualTo: _firebaseAuth.currentUser?.uid)
          .snapshots()
          .map((e) => e.docs
              .map((doc) =>
                  LocalNotificationDataModel.fromJson(doc.data(), doc.id))
              .toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<List<LocalNotificationDataModel>> getLocalNotificationsFuture() {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return _localNotificationCollectionReference
          .where('userId', isEqualTo: _firebaseAuth.currentUser?.uid)
          .get()
          .then((e) => e.docs
              .map((doc) =>
                  LocalNotificationDataModel.fromJson(doc.data(), doc.id))
              .toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<List<LocalNotificationDataModel>> getLocalNotificationsByPrayerId(
      String prayerId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return _localNotificationCollectionReference
          .where('prayerId', isEqualTo: prayerId)
          .get()
          .then((e) => e.docs
              .map((doc) =>
                  LocalNotificationDataModel.fromJson(doc.data(), doc.id))
              .toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<NotificationModel>> getUserPushNotifications() {
    try {
      return _notificationCollectionReference
          .where('receiverId', isEqualTo: _firebaseAuth.currentUser?.uid)
          .where('status', isNotEqualTo: Status.inactive)
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

  Future<void> cancelInappropriateNotification(
      String senderId, String prayerId) async {
    try {
      final notifications = await _notificationCollectionReference
          .where('senderId', isEqualTo: senderId)
          .where('status', isEqualTo: Status.active)
          .get()
          .then((value) => value.docs
              .map((e) => NotificationModel.fromJson(e.data()))
              .toList());
      final notificationIds = notifications
          .where((element) =>
              element.type == NotificationType.inappropriate_content &&
              element.prayerId == prayerId)
          .map((e) => e.id)
          .toList();
      for (final notificationId in notificationIds) {
        _notificationCollectionReference
            .doc(notificationId)
            .update({'status': Status.inactive});
      }
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

  Future<void> updateLocalNotification({
    required String notificationId,
    required String message,
    required int localNotificationId,
    required String type,
    required DateTime scheduleDate,
    required String status,
    required String frequency,
  }) async {
    try {
      _localNotificationCollectionReference.doc(notificationId).update({
        'message': message,
        'localNotificationId': localNotificationId,
        'type': type,
        "frequency": frequency,
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
