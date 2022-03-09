import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserProviderV2 with ChangeNotifier {
  UserServiceV2 _userService = locator<UserServiceV2>();
  final _firebaseUserId = FirebaseAuth.instance.currentUser?.uid;

  UserDataModel _selectedUser = UserDataModel();
  UserDataModel get selectedUser => _selectedUser;

  UserDataModel _currentUser = UserDataModel();
  UserDataModel get currentUser => _currentUser;

  List<UserDataModel> _allUsers = <UserDataModel>[];
  List<UserDataModel> get allUsers => _allUsers;

  Future getUserById() async {
    try {
      return _userService.getUserById(_firebaseUserId ?? '').then((event) {
        _selectedUser = event;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> returnUserToken(String userId) async {
    try {
      return await _userService.getUserById(userId).then((value) {
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
        ? selectedUser
        : _allUsers.firstWhere((element) => element.id == userId);
    final userName = (user.firstName ?? '') + ' ' + (user.lastName ?? '');
    return userName;
  }

  Future setCurrentUser(bool isLocalAuth) async {
    try {
      _currentUser = await _userService.getUserById(_firebaseUserId ?? '');
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future updateEmail(String newEmail, String userId) async {
    try {
      await _userService.updateEmail(newEmail: newEmail);
    } catch (e) {
      rethrow;
    }
  }

  Future updateUserSettings(String key, dynamic value) async {
    try {
      await _userService.updateUserSettings(key: key, value: value);
      setCurrentUser(false);
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
