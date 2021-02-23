import 'dart:io';

import 'package:be_still/enums/status.dart';
import 'package:be_still/models/device.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/user_device.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  final CollectionReference _notificationCollectionReference =
      FirebaseFirestore.instance.collection("MobileNotification");
  final CollectionReference _localNotificationCollectionReference =
      FirebaseFirestore.instance.collection("LocalNotification");
  final CollectionReference _userDeviceCollectionReference =
      FirebaseFirestore.instance.collection("UserDevice");
  final CollectionReference _deviceCollectionReference =
      FirebaseFirestore.instance.collection("Device");

  init(String token, String userId) async {
    final deviceId = Uuid().v1();
    final userDeviceID = Uuid().v1();
    //store device
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
  }

  Future<List<DeviceModel>> getNotificationToken(_userID) async {
    //get user devices
    var userDevices = await _userDeviceCollectionReference
        .where('UserId', isEqualTo: _userID)
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
      throw HttpException(e.message);
    }
    return devices;
  }

  addMobileNotification(String message, String messageType, String sender,
      String senderId, String userId) async {
    final _notificationId = Uuid().v1();
    try {
      _notificationCollectionReference
          .doc(_notificationId)
          .set(NotificationModel(
            message: message,
            messageType: messageType,
            sender: senderId,
            userId: userId,
            createdBy: 'SYSTEM',
            createdOn: DateTime.now(),
            extra1: '',
            extra2: '',
            extra3: sender,
            status: Status.active,
          ).toJson());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  sendEmail(String email, DocumentSnapshot template, String sender,
      String receiver, String message) async {
    var dio = Dio(BaseOptions(followRedirects: false));
    if (email != null) {
      var _template = MessageTemplate.fromData(template);
      var templateSubject = _template.templateSubject;
      var templateBody = _template.templateBody;
      templateSubject = templateSubject.replaceAll("{Sender}", sender);
      templateBody = templateBody.replaceAll("{Receiver}", receiver);
      templateBody = templateBody.replaceAll("{Sender}", sender);
      templateBody = templateBody.replaceAll("{message}", message);
      templateBody = templateBody.replaceAll(
          "{Link}", "<a href='https://www.bestillapp.com/'>Learn more.</a>");
      var data = {
        'templateSubject': templateSubject,
        'templateBody': templateBody,
        'email': email,
        'sender': sender,
      };
      try {
        await dio.post(
          'https://us-central1-bestill-app.cloudfunctions.net/SendMessage',
          data: data,
        );
      } catch (e) {
        throw HttpException(e.message);
      }
      return;
    }
  }

  sendSMS(String phoneNumber, DocumentSnapshot template, String sender,
      String receiver, String message) async {
    var dio = Dio(BaseOptions(followRedirects: false));
    if (phoneNumber != null) {
      var _templateBody = MessageTemplate.fromData(template).templateBody;
      _templateBody = _templateBody.replaceAll('{Sender}', sender);
      _templateBody = _templateBody.replaceAll("{Receiver}", receiver);
      _templateBody = _templateBody.replaceAll('{message}', message);
      _templateBody = _templateBody.replaceAll('<br/>', "\n");
      _templateBody =
          _templateBody.replaceAll("{Link}", 'https://www.bestillapp.com/');
      var data = {
        'phoneNumber': phoneNumber,
        'template': _templateBody,
        'country': 'US',
      };
      try {
        await dio.post(
          'https://us-central1-bestill-app.cloudfunctions.net/SendTextMessage',
          data: data,
        );
      } catch (e) {
        throw HttpException(e.message);
      }
      return;
    }
  }

  addLocalNotification(
      int localId, String entityId, String notificationText) async {
    final _notificationId = Uuid().v1();
    String deviceId;
    final DeviceInfoPlugin info = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await info.androidInfo;
        deviceId = build.androidId;
      } else if (Platform.isIOS) {
        var build = await info.iosInfo;
        deviceId = build.identifierForVendor;
      }
      _localNotificationCollectionReference.doc(_notificationId).set(
          LocalNotificationModel(
                  deviceId: deviceId,
                  localNotificationId: localId,
                  entityId: entityId,
                  notificationText: notificationText)
              .toJson());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  removeLocalNotification(String notificationId) async {
    try {
      _localNotificationCollectionReference.doc(notificationId).delete();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<List<LocalNotificationModel>> getLocalNotifications(String deviceId) {
    try {
      return _localNotificationCollectionReference
          .where('DeviceId', isEqualTo: deviceId)
          .snapshots()
          .map((e) => e.docs
              .map((doc) => LocalNotificationModel.fromData(doc))
              .toList());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    try {
      return _notificationCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((e) =>
              e.docs.map((doc) => NotificationModel.fromData(doc)).toList());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  acceptGroupInvite(
      String groupId, String userId, String name, String email) async {
    try {
      var dio = Dio(BaseOptions(followRedirects: false));
      var data = {
        'groupId': groupId,
        'userId': userId,
        'name': name,
        'email': email
      };
      print(data);

      await dio.post(
        'https://us-central1-bestill-app.cloudfunctions.net/InviteAcceptance',
        data: data,
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  newPrayerGroupNotification(String prayerId, String groupId) async {
    try {
      var dio = Dio(BaseOptions(followRedirects: false));
      var data = {'groupId': groupId, 'prayerId': prayerId};
      print(data);

      await dio.post(
        'https://us-central1-bestill-app.cloudfunctions.net/NewPrayer',
        data: data,
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
