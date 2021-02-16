import 'dart:io';

import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  final CollectionReference _notificationCollectionReference =
      FirebaseFirestore.instance.collection("MobileNotification");
  final CollectionReference _localNotificationCollectionReference =
      FirebaseFirestore.instance.collection("LocalNotification");

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
}
