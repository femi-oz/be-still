import 'package:be_still/locator.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  UserService _userService = locator<UserService>();
  UserModel _currentUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel get currentUser => _currentUser;

  Future setCurrentUser(bool isLocalAuth) async {
    var keyRefernence =
        isLocalAuth ? Settings.userKeyRefernce : _firebaseAuth.currentUser.uid;
    _currentUser = await _userService.getCurrentUser(keyRefernence);
    notifyListeners();
  }

  UserModel get user {
    return _currentUser;
  }

  updateEmail(String newEmail, String userId) async {
    await _userService.updateEmail(newEmail, userId);
    setCurrentUser(false);
  }

  updatePassword(String newPassword) async {
    await _userService.updatePassword(newPassword);
    setCurrentUser(false);
  }
}
