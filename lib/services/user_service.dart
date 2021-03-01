import 'dart:io';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../locator.dart';

class UserService {
  final CollectionReference _userCollectionReference =
      FirebaseFirestore.instance.collection("User");
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
    final userId = Uuid().v1();
    try {
      // store user details
      await _userCollectionReference.doc(userId).set(
            _userData.toJson(),
          );

      // store default settings
      await locator<SettingsService>().addSettings('', userId, email);
      await locator<SettingsService>().addGroupPreferenceSettings(userId);
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, userId);
      throw HttpException(e.message);
    }
  }

  Future getCurrentUser(String keyReference) async {
    try {
      final userRes = await _userCollectionReference
          .where('KeyReference', isEqualTo: keyReference)
          .limit(1)
          .get();
      return UserModel.fromData(userRes.docs[0]);
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, keyReference);
      throw HttpException(e.message);
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      var users = await _userCollectionReference.get();
      return users.docs.map((e) => UserModel.fromData(e)).toList();
    } catch (e) {
      locator<LogService>()
          .createLog(e.code, e.message, _firebaseAuth.currentUser.email);
      throw HttpException(e.message);
    }
  }

  Future updateEmail(String newEmail, String userId) async {
    User user = _firebaseAuth.currentUser;
    try {
      await user.updateEmail(newEmail);
      await _userCollectionReference.doc(userId).update({'Email': newEmail});
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, userId);
      throw HttpException(e.message);
    }
  }

  Future updatePassword(String newPassword) async {
    User user = _firebaseAuth.currentUser;
    try {
      user.updatePassword(newPassword);
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, user.email);
      throw HttpException(e.message);
    }
  }
}
