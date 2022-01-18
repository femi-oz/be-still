import 'package:be_still/locator.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  UserService _userService = locator<UserService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel _currentUser = UserModel.defaultValue();
  UserModel get currentUser => _currentUser;

  UserModel _selectedUser = UserModel.defaultValue();
  UserModel get selectedUser => _selectedUser;

  String _userToken = '';
  String get userToken => _userToken;

  List<UserModel> _allUsers = <UserModel>[];
  List<UserModel> get allUsers => _allUsers;

  Future setCurrentUser(bool isLocalAuth) async {
    try {
      final keyRefernence = _firebaseAuth.currentUser?.uid;
      _currentUser = await _userService.getCurrentUser(keyRefernence ?? '');
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future getUserById(String id) async {
    try {
      return _userService.getUserById(id).then((event) {
        _selectedUser = event;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future returnUserToken(String id) async {
    try {
      return await _userService.getUserByIdFuture(id).then((value) {
        _userToken = value.pushToken ?? '';
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future setAllUsers(String userId) async {
    try {
      _userService.getAllUsers().then((e) {
        _allUsers = e.toList();
        _allUsers = _allUsers.where((e) => e.id != userId).toList();
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  void clearCurrentUser() {
    try {
      _currentUser = UserModel.defaultValue();
    } catch (e) {
      rethrow;
    }
  }

  updateEmail(String newEmail, String userId) async {
    try {
      await _userService.updateEmail(newEmail, userId);
      setCurrentUser(false);
    } catch (e) {
      rethrow;
    }
  }

  updatePassword(String newPassword) async {
    try {
      await _userService.updatePassword(newPassword);
      setCurrentUser(false);
    } catch (e) {
      rethrow;
    }
  }
}
