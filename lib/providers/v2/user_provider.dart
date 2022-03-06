import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserProviderV2 with ChangeNotifier {
  UserServiceV2 _userService = locator<UserServiceV2>();
  final userId = FirebaseAuth.instance.currentUser?.uid;

  UserDataModel _selectedUser = UserDataModel();
  UserDataModel get selectedUser => _selectedUser;

  String _userToken = '';
  String get userToken => _userToken;

  List<UserDataModel> _allUsers = <UserDataModel>[];
  List<UserDataModel> get allUsers => _allUsers;

  Future getUserById() async {
    try {
      return _userService.getUserById(userId ?? '').then((event) {
        _selectedUser = event;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future returnUserToken(String deviceId) async {
    try {
      await _userService.getUserById(userId ?? '').then((value) {
        _userToken = (value.devices ?? <DeviceModel>[])
                .firstWhere((element) => element.id == deviceId)
                .token ??
            '';
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future setAllUsers() async {
    try {
      _userService.getAllUsers().asBroadcastStream().listen((users) {
        _allUsers = users.where((e) => e.id != userId).toList();
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future setCurrentUser(bool isLocalAuth) async {
    try {
      _selectedUser = await _userService.getUserById(userId ?? '');
      notifyListeners();
    } catch (e) {
      rethrow;
    }
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
