import 'package:be_still/enums/status.dart';
import 'package:be_still/models/device.model.dart';
import 'package:be_still/models/user_device.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final CollectionReference _userDeviceCollectionReference =
      FirebaseFirestore.instance.collection("UserDevice");
  final CollectionReference _deviceCollectionReference =
      FirebaseFirestore.instance.collection("Device");
  bool _initialized = false;

  Future<void> init(String userId) async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      final deviceId = Uuid().v1();
      final userDeviceID = Uuid().v1();
      //store device
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          _deviceCollectionReference.doc(deviceId),
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
        transaction.set(
          _userDeviceCollectionReference.doc(userDeviceID),
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
      });
    }

    _initialized = true;
  }
}
