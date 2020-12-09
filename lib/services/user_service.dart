import 'dart:io';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/device.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/models/user_device.model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../locator.dart';

class UserService {
  final CollectionReference _userCollectionReference =
      Firestore.instance.collection("User");
  final CollectionReference _userDeviceCollectionReference =
      Firestore.instance.collection("UserDevice");
  final CollectionReference _deviceCollectionReference =
      Firestore.instance.collection("Device");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  deviceModel() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      print(iosInfo);
    } else {
      var andriodInfo = await deviceInfo.androidInfo;

      print(andriodInfo);
    }
  }

  populateDevice(
    String deviceModel,
    String deviceName,
    String deviceID,
    String email,
  ) {
    DeviceModel device = DeviceModel(
      createdBy: email,
      createdOn: DateTime.now(),
      modifiedOn: DateTime.now(),
      modifiedBy: email,
      model: deviceModel.toUpperCase(),
      deviceId: deviceID,
      name: deviceName.toUpperCase(),
      status: Status.active,
    );
    return device;
  }

  populateUserDevice(
    String deviceID,
    String userID,
    String email,
  ) {
    UserDeviceModel userDevice = UserDeviceModel(
      createdBy: email,
      createdOn: DateTime.now(),
      modifiedOn: DateTime.now(),
      modifiedBy: email,
      deviceId: deviceID,
      userId: userID,
      status: Status.active,
    );
    return userDevice;
  }

  Future addUserData(
    String uid,
    String email,
    String password,
    String firstName,
    String lastName,
    DateTime dob,
  ) async {
    final UserModel _userData = UserModel(
      churchId: 0,
      createdBy: email.toUpperCase(),
      createdOn: DateTime.now(),
      dateOfBirth: dob,
      email: email,
      firstName: firstName,
      keyReference: uid,
      lastName: lastName,
      modifiedBy: email,
      modifiedOn: DateTime.now(),
    );

    // Generate uuid
    final deviceIdGuid = Uuid().v1();
    final userID = Uuid().v1();
    final userDeviceID = Uuid().v1();

    // get device infomation
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceModel;
    String deviceName;
    String deviceID;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      deviceName = androidInfo.brand;
      deviceID = androidInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.utsname.machine;
      deviceName = iosInfo.name;
      deviceID = iosInfo.identifierForVendor;
    }

    try {
      Firestore.instance.runTransaction(
        (transaction) async {
          // store user details
          await _userCollectionReference.document(userID).setData(
                _userData.toJson(),
              );

          //store device
          await _deviceCollectionReference.document(deviceIdGuid).setData(
                populateDevice(email, deviceModel, deviceName, deviceID)
                    .toJson(),
              );

          // store user device
          await _userDeviceCollectionReference.document(userDeviceID).setData(
                populateUserDevice(email, deviceID.toString(), userID).toJson(),
              );
          // store defaul settings
          await locator<SettingsService>().addSettings(deviceID, userID, email);
        },
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    try {
      final userRes = await _userCollectionReference
          .where('KeyReference', isEqualTo: user.uid)
          .limit(1)
          .getDocuments();
      return UserModel.fromData(userRes.documents[0]);
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future updateEmail(String newEmail, String userId) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    try {
      await user.updateEmail(newEmail);
      await _userCollectionReference
          .document(userId)
          .updateData({'Email': newEmail});
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future updatePassword(String newPassword) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    try {
      user.updatePassword(newPassword);
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
