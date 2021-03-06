import 'dart:io';
import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/auth_service.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../locator.dart';

class UserService {
  //#region
  final CollectionReference<Map<String, dynamic>> _userCollectionReference =
      FirebaseFirestore.instance.collection("User");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthenticationService _authenticationService =
      locator<AuthenticationService>();

  Future addUserData(String uid, String email, String password,
      String firstName, String lastName, DateTime dob) async {
    // Generate uuid
    final userId = Uuid().v1();
    final UserModel _userData = UserModel(
        id: userId,
        churchId: 0,
        createdBy: email.toUpperCase(),
        createdOn: DateTime.now(),
        dateOfBirth: DateFormat('MM/dd/yyyy').format(dob),
        email: email,
        firstName: firstName,
        keyReference: uid,
        lastName: lastName,
        modifiedBy: email,
        pushToken: '',
        modifiedOn: DateTime.now());

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
          StringUtils.getErrorMessage(e), userId, 'USER/service/addUserData');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future addUserToken(
      {required String userId,
      required String token,
      required UserModel user}) async {
    user = user..pushToken = token;

    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      await _userCollectionReference.doc(userId).update(
            user.toJson(),
          );
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), userId, 'USER/service/addUserToken');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<UserModel> getCurrentUser(String keyReference) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final userRes = await _userCollectionReference
          .where('KeyReference', isEqualTo: keyReference)
          .limit(1)
          .get();
      return UserModel.fromData(userRes.docs[0].data(), userRes.docs[0].id);
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          keyReference, 'USER/service/getCurrentUser');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<UserModel> getUserById(String id) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final x = await _userCollectionReference
          .doc(id)
          .get()
          .then((e) => UserModel.fromData(e.data()!, e.id));
      return x;
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), id, 'USER/service/getCurrentUser');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<UserModel> getUserByIdFuture(String id) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return _userCollectionReference.doc(id).get().then((e) {
        var g = e.data();
        if (g != null) {
          return UserModel.fromData(g, e.id);
        } else {
          return UserModel.defaultValue();
        }
      });
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), id, 'USER/service/getUserByIdFuture');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      var users = await _userCollectionReference.get();
      return users.docs.map((e) => UserModel.fromData(e.data(), e.id)).toList();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          _firebaseAuth.currentUser?.email ?? '', 'USER/service/getAllUsers');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future updateEmail(String newEmail, String userId) async {
    User? user = _firebaseAuth.currentUser;
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await user?.updateEmail(newEmail.toLowerCase());
      _userCollectionReference.doc(userId).update({'Email': newEmail});
      _authenticationService.sendEmailVerification();
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), userId, 'USER/service/updateEmail');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future updatePassword(String newPassword) async {
    User? user = _firebaseAuth.currentUser;
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await user?.updatePassword(newPassword);
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          user?.email ?? '', 'USER/service/updatePassword');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future removePushToken(String userId) async {
    try {
      _userCollectionReference.doc(userId).update({'PushToken': ''});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }
  //#endregion

  //=============================================================================================================================//
  //new data structure

  final CollectionReference<Map<String, dynamic>> _userDataCollectionReference =
      FirebaseFirestore.instance.collection("users");

  Future<void> createUser({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    required String token,
    required String deviceId,
  }) async {
    try {
      final doc = UserDataModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        dateOfBirth: dateOfBirth,
        allowEmergencyCalls: true,
        archiveAutoDeleteMinutes: 0,
        defaultSnoozeFrequency: IntervalRange.thirtyMinutes,
        includeAnsweredPrayerAutoDelete: false,
        archiveSortBy: SortType.date,
        autoPlayMusic: true,
        churchEmail: '',
        churchName: '',
        churchPhone: '',
        churchWebFormUrl: '',
        devices: [
          DeviceModel(id: deviceId, token: token)
        ], // update token on login where deviceId == deviceId
        enableBackgroundMusic: true,
        enableSharingViaEmail: true,
        enableSharingViaText: true,
        doNotDisturb: true,
        createdBy: uid,
        modifiedBy: uid,
        createdDate: DateTime.now(), modifiedDate: DateTime.now(),
        status: Status.active,
      ).toJson();
      _userDataCollectionReference.doc(uid).set(doc);
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }
}
