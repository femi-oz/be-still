import 'dart:io';
import 'package:be_still/models/device.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

class UserService {
  final CollectionReference _userCollectionReference =
      Firestore.instance.collection("User");
  final CollectionReference _userDeviceCollectionReference =
      Firestore.instance.collection("UserDevice");
  final CollectionReference _deviceCollectionReference =
      Firestore.instance.collection("Device");

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

  setDevice(UserModel user, String deviceModel, String deviceName) {
    DeviceModel device = DeviceModel(
      createdBy: '${user.firstName} ${user.lastName}',
      createdOn: user.createdOn,
      modifiedOn: user.modifiedOn,
      modifiedBy: '${user.firstName} ${user.lastName}',
      model: deviceModel,
      deviceId: '',
      name: deviceName,
      status: 'Active',
    );
    return device;
  }

  setUser(UserModel userData, String uid) {
    UserModel user = UserModel(
      churchId: 0,
      createdBy: '${userData.firstName} ${userData.lastName}',
      createdOn: DateTime.now(),
      dateOfBirth: userData.dateOfBirth,
      email: userData.email,
      firstName: userData.firstName,
      keyReference: uid,
      lastName: userData.lastName,
      modifiedBy: '${userData.firstName} ${userData.lastName}',
      modifiedOn: DateTime.now(),
      phone: '',
    );
    return user;
  }

  setUserDevice(UserModel user, String deviceID, String uid) {
    UserDeviceModel userDevice = UserDeviceModel(
      createdBy: '${user.firstName} ${user.lastName}',
      createdOn: user.createdOn,
      modifiedOn: user.modifiedOn,
      modifiedBy: '${user.firstName} ${user.lastName}',
      deviceId: deviceID,
      userId: uid,
      status: 'Active',
    );
    return userDevice;
  }

  Future addUserData(UserModel userData, uid) async {
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
      // store user details
      Firestore.instance.runTransaction((transaction) async {
        await _userCollectionReference.add(setUser(userData, uid).toJson());
//store device
        final deviceRes = await _deviceCollectionReference
            .add(setDevice(userData, deviceModel, deviceName).toJson());
        // store user device
        await _userDeviceCollectionReference
            .add(setUserDevice(userData, deviceRes.documentID, uid).toJson());
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future getUser(String uid) async {
    try {
      var userData = await _userCollectionReference.document(uid).get();
      return UserModel.fromData(userData);
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return null;
    }
  }
}
