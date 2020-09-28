import 'dart:io';
import 'package:be_still/models/device.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/models/user_device.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

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
    UserModel userData,
    String deviceModel,
    String deviceName,
    String deviceID,
  ) {
    DeviceModel device = DeviceModel(
      createdBy: userData.createdBy,
      createdOn: userData.createdOn,
      modifiedOn: userData.modifiedOn,
      modifiedBy: userData.modifiedBy,
      model: deviceModel.toUpperCase(),
      deviceId: deviceID,
      name: deviceName.toUpperCase(),
      status: 'Active',
    );
    return device;
  }

  populateUser(
    UserModel userData,
    String authUid,
  ) {
    UserModel user = UserModel(
      churchId: 0,
      createdBy: userData.createdBy,
      createdOn: DateTime.now(),
      dateOfBirth: userData.dateOfBirth,
      email: userData.email,
      firstName: userData.firstName.toUpperCase(),
      keyReference: authUid,
      lastName: userData.lastName.toUpperCase(),
      modifiedBy: userData.modifiedBy,
      modifiedOn: DateTime.now(),
      phone: '',
    );
    return user;
  }

  populateUserDevice(
    UserModel userData,
    String deviceID,
    String userID,
  ) {
    UserDeviceModel userDevice = UserDeviceModel(
      createdBy: userData.createdBy,
      createdOn: userData.createdOn,
      modifiedOn: userData.modifiedOn,
      modifiedBy: userData.modifiedBy,
      deviceId: deviceID,
      userId: userID,
      status: 'Active',
    );
    return userDevice;
  }

  Future addUserData(
    UserModel userData,
    String authUid,
  ) async {
    // Generate uuid
    final deviceID = Uuid().v1();
    final userID = Uuid().v1();
    final userDeviceID = Uuid().v1();

    // get device infomation
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceModel;
    String deviceName;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      deviceName = androidInfo.brand;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.utsname.machine;
      deviceName = iosInfo.name;
    }

    try {
      Firestore.instance.runTransaction(
        (transaction) async {
          // store user details
          await _userCollectionReference.document(userID).setData(
                populateUser(userData, authUid).toJson(),
              );

          //store device
          await _deviceCollectionReference.document(deviceID).setData(
                populateDevice(userData, deviceModel, deviceName, deviceID)
                    .toJson(),
              );

          // store user device
          await _userDeviceCollectionReference.document(userDeviceID).setData(
                populateUserDevice(userData, deviceID.toString(), userID)
                    .toJson(),
              );
        },
      );
    } catch (e) {
      print(e.toString());
      return null;
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
      if (e is PlatformException) {
        return e.message;
      }
      return null;
    }
  }
}