import 'dart:io';

import 'package:be_still/enums/status.dart';
import 'package:be_still/flavor_config.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/device.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/user_device.model.dart';
import 'package:be_still/services/log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  final CollectionReference _localNotificationCollectionReference =
      FirebaseFirestore.instance.collection("LocalNotification");
  final CollectionReference _pushNotificationCollectionReference =
      FirebaseFirestore.instance.collection("PushNotification");
  final CollectionReference _smsCollectionReference =
      FirebaseFirestore.instance.collection("SMSMessage");
  final CollectionReference _emailCollectionReference =
      FirebaseFirestore.instance.collection("MailMessage");
  final CollectionReference _userDeviceCollectionReference =
      FirebaseFirestore.instance.collection("UserDevice");
  final CollectionReference _deviceCollectionReference =
      FirebaseFirestore.instance.collection("Device");
  final CollectionReference _prayerTimeCollectionReference =
      FirebaseFirestore.instance.collection("PrayerTime");

  init(String token, String userId) async {
    final deviceId = Uuid().v1();
    final userDeviceID = Uuid().v1();
    //store device
    try {
      var tokens = await getNotificationToken(userId);
      print(tokens);
      if (tokens.contains(token)) return;
      await _deviceCollectionReference.doc(deviceId).set(
            DeviceModel(
                    createdBy: 'MOBILE',
                    createdOn: DateTime.now(),
                    modifiedOn: DateTime.now(),
                    modifiedBy: 'MOBILE',
                    model: 'MOBILE',
                    deviceId: '',
                    name: token,
                    status: Status.active)
                .toJson(),
          );

      // store user device
      await _userDeviceCollectionReference.doc(userDeviceID).set(
            UserDeviceModel(
              createdBy: 'MOBILE',
              createdOn: DateTime.now(),
              modifiedOn: DateTime.now(),
              modifiedBy: 'MOBILE',
              deviceId: deviceId,
              userId: userId,
              status: Status.active,
            ).toJson(),
          );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'NOTIFICATION/service/init');
      throw HttpException(e.message);
    }
  }

  Future<List<String>> getNotificationToken(userId) async {
    //get user devices
    var userDevices = await _userDeviceCollectionReference
        .where('UserId', isEqualTo: userId)
        .get();
    var userDevicesDocs =
        userDevices.docs.map((e) => UserDeviceModel.fromData(e)).toList();
    List<DeviceModel> devices = [];
    try {
      for (int i = 0; i < userDevicesDocs.length; i++) {
        var dev = await _deviceCollectionReference
            .doc(userDevicesDocs[i].deviceId)
            .get();
        devices.add(DeviceModel.fromData(dev));
      }
    } catch (e) {
      locator<LogService>().createLog(
          e.message, userId, 'NOTIFICATION/service/getNotificationToken');
      throw HttpException(e.message);
    }
    return devices.map((e) => e.name).toList();
  }

  addPushNotification({
    String message,
    String messageType,
    String sender,
    List<String> tokens,
    String senderId,
    String recieverId,
    @required String entityId,
  }) async {
    final _notificationId = Uuid().v1();
    var data = PushNotificationModel(
      messageType: messageType,
      message: message,
      sender: sender,
      title: "You have been tagged in a prayer",
      tokens: tokens,
      createdBy: senderId,
      createdOn: DateTime.now(),
      modifiedBy: senderId,
      modifiedOn: DateTime.now(),
      isSent: 0,
      recieverId: recieverId,
      status: Status.active,
      entityId: entityId,
    );
    try {
      _pushNotificationCollectionReference
          .doc(_notificationId)
          .set(data.toJson());
    } catch (e) {
      locator<LogService>().createLog(
          e.message, senderId, 'NOTIFICATION/service/addPushNotification');
      throw HttpException(e.message);
    }
  }

  updatePrayerTimeNotification(
      String selectedDay,
      String selectedPeriod,
      String selectedFrequency,
      String selectedHour,
      String selectedMinute,
      String notificationId) {
    try {
      _localNotificationCollectionReference.doc(notificationId).update({
        'SelectedDay': selectedDay,
        'Period': selectedPeriod,
        'Frequency': selectedFrequency,
        'Minute': selectedMinute,
        'Hour': selectedHour
      });
    } catch (e) {
      locator<LogService>().createLog(e.message, notificationId,
          'NOTIFICATION/service/addPushNotification');
      throw HttpException(e.message);
    }
  }

  addSMS({
    String senderId,
    String message,
    String sender,
    String phoneNumber,
    String title,
    MessageTemplate template,
    String receiver,
  }) async {
    final _smsId = Uuid().v1();
    var _templateBody = template.templateBody;
    _templateBody = _templateBody.replaceAll('{Sender}', sender);
    _templateBody = _templateBody.replaceAll("{Receiver}", receiver);
    _templateBody = _templateBody.replaceAll('{message}', message);
    _templateBody = _templateBody.replaceAll('<br/>', "\n");
    _templateBody =
        _templateBody.replaceAll("{Link}", 'https://www.bestillapp.com/');
    var data = MessageModel(
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
      _smsCollectionReference.doc(_smsId).set(data.toJson());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          senderId,
          'NOTIFICATION/service/addSMS');
      throw HttpException(e.message);
    }
  }

  addEmail({
    String senderId,
    String message,
    String sender,
    String email,
    String title,
    String receiver,
    MessageTemplate template,
  }) async {
    final _emailId = Uuid().v1();
    var templateSubject = template.templateSubject;
    var templateBody = template.templateBody;
    templateSubject = templateSubject.replaceAll("{Sender}", sender);
    templateBody = templateBody.replaceAll("{Receiver}", receiver);
    templateBody = templateBody.replaceAll("{Sender}", sender);
    templateBody = templateBody.replaceAll("{message}", message);
    templateBody = templateBody.replaceAll(
        "{Link}", "<a href='https://www.bestillapp.com/'>Learn more.</a>");

    var data = MessageModel(
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
      _emailCollectionReference.doc(_emailId).set(data.toJson());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          senderId,
          'NOTIFICATION/service/addEmail');
      throw HttpException(e.message);
    }
  }

  addLocalNotification(
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
      String selectedMinute) async {
    final _notificationId = Uuid().v1();
    String deviceId;
    try {
      _localNotificationCollectionReference.doc(_notificationId).set(
          LocalNotificationModel(
                  type: type,
                  description: description,
                  frequency: frequency,
                  scheduledDate: scheduledDate,
                  title: title,
                  fallbackRoute: fallbackRoute,
                  payload: payload,
                  userId: userId,
                  localNotificationId: localId,
                  entityId: entityId,
                  notificationText: notificationText,
                  selectedDay: selectedDay,
                  selectedHour: selectedHour,
                  selectedMinute: selectedMinute,
                  period: period)
              .toJson());
      // await addPrayerTime(selectedDay, frequency, period, selectedHour,
      //     selectedMinute, userId, _notificationId);
    } catch (e) {
      locator<LogService>().createLog(
          e.message, deviceId, 'NOTIFICATION/service/addLocalNotification');
      throw HttpException(e.message);
    }
  }

  Future deletePrayerTime(String prayerTimeId) async {
    try {
      _prayerTimeCollectionReference.doc(prayerTimeId).delete();
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerTimeId,
          'PRAYER/service/deletePrayerTime');
      throw HttpException(e.message);
    }
  }

  removeLocalNotification(String notificationId) async {
    try {
      _localNotificationCollectionReference.doc(notificationId).delete();
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          notificationId,
          'NOTIFICATION/service/removeLocalNotification');
      throw HttpException(e.message);
    }
  }

  Stream<List<LocalNotificationModel>> getLocalNotifications(String userId) {
    try {
      return _localNotificationCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((e) => e.docs
              .map((doc) => LocalNotificationModel.fromData(doc))
              .toList());
    } catch (e) {
      locator<LogService>().createLog(
          e.message, userId, 'NOTIFICATION/service/getLocalNotifications');
      throw HttpException(e.message);
    }
  }

  Stream<List<PushNotificationModel>> getUserNotifications(String userId) {
    try {
      return _pushNotificationCollectionReference
          .where('RecieverId', isEqualTo: userId)
          .snapshots()
          .map((e) => e.docs
              .map((doc) => PushNotificationModel.fromData(doc))
              .toList());
    } catch (e) {
      locator<LogService>().createLog(
          e.message, userId, 'NOTIFICATION/service/getUserNotifications');
      throw HttpException(e.message);
    }
  }

  Future clearNotification(List<String> ids) async {
    try {
      for (int i = 0; i < ids.length; i++) {
        await _pushNotificationCollectionReference
            .doc(ids[i])
            .update({'Status': Status.inactive});
      }
    } catch (e) {
      for (int i = 0; i < ids.length; i++) {
        locator<LogService>().createLog(
            e.message, ids[i], 'NOTIFICATION/service/clearNotification');
      }
      throw HttpException(e.message);
    }
  }

  // acceptGroupInvite(
  //     String groupId, String userId, String name, String email) async {
  //   try {
  //     var dio = Dio(BaseOptions(followRedirects: false));
  //     var data = {
  //       'groupId': groupId,
  //       'userId': userId,
  //       'name': name,
  //       'email': email
  //     };
  //     print(data);

  //     await dio.post(
  //       'https://us-central1-bestill-app.cloudfunctions.net/InviteAcceptance',
  //       data: data,
  //     );
  //   } catch (e) {
  //     throw HttpException(e.message);
  //   }
  // }

  // newPrayerGroupNotification(String prayerId, String groupId) async {
  //   try {
  //     var dio = Dio(BaseOptions(followRedirects: false));
  //     var data = {'groupId': groupId, 'prayerId': prayerId};
  //     print(data);

  //     await dio.post(
  //       'https://us-central1-bestill-app.cloudfunctions.net/NewPrayer',
  //       data: data,
  //     );
  //   } catch (e) {
  //     throw HttpException(e.message);
  //   }
  // }
}
