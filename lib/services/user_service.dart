import 'dart:io';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../locator.dart';

class UserService {
  final CollectionReference<Map<String, dynamic>> _userCollectionReference =
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
      dateOfBirth: dob == null ? '' : DateFormat('MM/DD/YY').format(dob),
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
      if (_firebaseAuth.currentUser == null) return null;
      // store user details
      await _userCollectionReference.doc(userId).set(
            _userData.toJson(),
          );

      // store default settings
      await locator<SettingsService>().addSettings('', userId, email);
      await locator<SettingsService>().addGroupPreferenceSettings(userId);
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'USER/service/addUserData');
      throw HttpException(e.message);
    }
  }

  Future getCurrentUser(String keyReference) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      final userRes = await _userCollectionReference
          .where('KeyReference', isEqualTo: keyReference)
          .limit(1)
          .get();
      return UserModel.fromData(userRes.docs[0]);
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          keyReference,
          'USER/service/getCurrentUser');
      throw HttpException(e.message);
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var users = await _userCollectionReference.get();
      return users.docs.map((e) => UserModel.fromData(e)).toList();
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          _firebaseAuth.currentUser.email,
          'USER/service/getAllUsers');
      throw HttpException(e.message);
    }
  }

  Future updateEmail(String newEmail, String userId) async {
    User user = _firebaseAuth.currentUser;
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await user.updateEmail(newEmail.toLowerCase());
      await user.sendEmailVerification();
      await _userCollectionReference.doc(userId).update({'Email': newEmail});
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'USER/service/updateEmail');
      throw HttpException(e.message);
    }
  }

  Future updatePassword(String newPassword) async {
    User user = _firebaseAuth.currentUser;
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await user.updatePassword(newPassword);
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          user.email,
          'USER/service/updatePassword');
      throw HttpException(e.message);
    }
  }
}
