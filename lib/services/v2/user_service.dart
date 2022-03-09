import 'dart:io';

import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserServiceV2 {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>> _userDataCollectionReference =
      FirebaseFirestore.instance.collection("users");

  Stream<List<UserDataModel>> getAllUsers() {
    try {
      return _userDataCollectionReference.snapshots().map((event) => event.docs
          .map((e) => UserDataModel.fromJson(e.data(), e.id))
          .toList());
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
    }
  }

  Future<void> createUser({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      final doc = UserDataModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        dateOfBirth: dateOfBirth,
        allowEmergencyCalls: true,
        archiveAutoDeleteMinutes: 0,
        defaultSnoozeFrequency: IntervalRange.thirtyMinutes,
        defaultSnoozeDuration: 0,
        includeAnsweredPrayerAutoDelete: false,
        archiveSortBy: SortType.date,
        autoPlayMusic: true,
        churchEmail: '',
        groups: [],
        churchName: '',
        churchPhone: '',
        churchWebFormUrl: '',
        devices: [DeviceModel(id: await deviceId(), token: token)],
        prayers: [],
        enableBackgroundMusic: true,
        enableSharingViaEmail: true,
        enableSharingViaText: true,
        enableNotificationsForAllGroups: true,
        doNotDisturb: true,
        createdBy: uid,
        modifiedBy: uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
        status: Status.active,
      ).toJson();
      _userDataCollectionReference.doc(uid).set(doc);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<UserDataModel> getUserByIdFuture(String userId) async {
    try {
      final doc = await _userDataCollectionReference.doc(userId).get();
      if (doc.exists)
        return UserDataModel.fromJson(doc.data()!, doc.id);
      else
        throw HttpException(StringUtils.documentDoesNotExist);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<UserDataModel> getUserById(String userId) {
    try {
      return _userDataCollectionReference
          .doc(userId)
          .snapshots()
          .map((event) => UserDataModel.fromJson(event.data()!, event.id));
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future updatePassword(String newPassword) async {
    User? user = _firebaseAuth.currentUser;
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await user?.updatePassword(newPassword);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> updateEmail(
      {
      // required DocumentReference userReference,
      required String newEmail}) async {
    try {
      _userDataCollectionReference
          .doc(_firebaseAuth.currentUser?.uid ?? '')
          .update({'email': newEmail});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> updateUserSettings({
    required String key,
    required dynamic value,
  }) async {
    try {
      _userDataCollectionReference
          .doc(_firebaseAuth.currentUser?.uid ?? '')
          .update({key: value});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> addPushToken(List<DeviceModel> userDevices) async {
    try {
      final id = await deviceId();
      DeviceModel device = DeviceModel();
      final messaging = FirebaseMessaging.instance;
      final newToken = await messaging.getToken();
      if (userDevices.any((element) => element.id == id)) {
        userDevices = userDevices.map((element) {
          if (element.id == id) {
            element = element..token = newToken;
            device = DeviceModel(id: element.id, token: newToken);
          }
          return element;
        }).toList();
      } else {
        userDevices.add(DeviceModel(id: await deviceId(), token: newToken));
        device = DeviceModel(id: await deviceId(), token: newToken);
      }
      _userDataCollectionReference.doc(_firebaseAuth.currentUser?.uid).update({
        'devices': FieldValue.arrayUnion([device.toJson()])
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<String> deviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        return build.androidId; //UUID for Android
      } else {
        var data = await deviceInfoPlugin.iosInfo;
        return data.identifierForVendor; //UUID for iOS
      }
    } catch (e) {
      throw Exception('Failed to get platform version');
    }
  }

  Future<void> deletePushToken() async {
    try {
      final devices = await _userDataCollectionReference
              .doc(_firebaseAuth.currentUser?.uid)
              .get()
              .then((value) =>
                  UserDataModel.fromJson(value.data()!, value.id).devices) ??
          [];
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(
          _userDataCollectionReference
              .doc(_firebaseAuth.currentUser?.uid ?? ''),
          {
            'devices': FieldValue.arrayRemove(devices),
            'modifiedBy': _firebaseAuth.currentUser?.uid,
            'modifiedDate': DateTime.now()
          });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }
}
