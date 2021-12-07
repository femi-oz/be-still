import 'package:be_still/locator.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  UserService _userService = locator<UserService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel _currentUser;
  UserModel get currentUser => _currentUser;

  UserModel _selectedUser;
  UserModel get selectedUser => _selectedUser;

  List<UserModel> _allUsers;
  List<UserModel> get allUsers => _allUsers;

  Future setCurrentUser(bool isLocalAuth) async {
    var keyRefernence = _firebaseAuth.currentUser.uid;
    _currentUser = await _userService.getCurrentUser(keyRefernence);
    notifyListeners();
  }

  Future<UserModel> getUserById(String id) async {
    return _userService.getUserById(id).then((event) {
      _selectedUser = event;
      notifyListeners();
      return _selectedUser;
    });
  }

  Future<String> returnUserToken(String id) async {
    final user = await _userService.getUserByIdFuture(id);
    return user.pushToken;
  }

  Future setAllUsers(String userId) async {
    _userService.getAllUsers().then((e) {
      _allUsers =
          e.where((e) => e.firstName != null || e.lastName != null).toList();
      _allUsers = _allUsers.where((e) => e.id != userId).toList();
      notifyListeners();
    });
  }

  Future<void> clearCurrentUser() => _currentUser = null;

  updateEmail(String newEmail, String userId) async {
    await _userService.updateEmail(newEmail, userId);
    setCurrentUser(false);
  }

  updatePassword(String newPassword) async {
    await _userService.updatePassword(newPassword);
    setCurrentUser(false);
  }
}
