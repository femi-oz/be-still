import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserProviderV2 with ChangeNotifier {
  UserServiceV2 _userService = locator<UserServiceV2>();
  final _firebaseUserId = FirebaseAuth.instance.currentUser?.uid;

  UserDataModel _currentUser = UserDataModel();
  UserDataModel get currentUser => _currentUser;

  List<UserDataModel> _allUsers = <UserDataModel>[];
  List<UserDataModel> get allUsers => _allUsers;

  Future<void> setCurrentUser() async {
    try {
      await _userService.getUserByIdFuture(_firebaseUserId ?? '').then((event) {
        _currentUser = event;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<UserDataModel> getUserDataById(String userId) async {
    try {
      return _userService
          .getUserByIdFuture(_firebaseUserId ?? '')
          .then((event) {
        return event;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> returnUserToken(String userId) async {
    try {
      return await _userService.getUserByIdFuture(userId).then((value) {
        return (value.devices ?? []).map((e) => e.token ?? '').toList();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future setAllUsers() async {
    try {
      _userService.getAllUsers().asBroadcastStream().listen((users) {
        _allUsers = users.where((e) => e.id != _firebaseUserId).toList();
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  String getPrayerCreatorName(String userId) {
    final user = userId == _firebaseUserId
        ? currentUser
        : _allUsers.firstWhere((element) => element.id == userId);
    final userName = (user.firstName ?? '') + ' ' + (user.lastName ?? '');
    return userName;
  }

  Future updateEmail(String newEmail, String userId) async {
    try {
      await _userService.updateEmail(newEmail: newEmail);
      // setCurrentUser(false);
    } catch (e) {
      rethrow;
    }
  }

  Future updatePassword(String newPassword) async {
    try {
      await _userService.updatePassword(newPassword);
      // setCurrentUser(false);
    } catch (e) {
      rethrow;
    }
  }

  Future removePushToken(String deviceId, List<DeviceModel> devices) async {
    try {
      await _userService.deletePushToken(deviceId: deviceId, devices: devices);
    } catch (e) {
      rethrow;
    }
  }
}
