import 'package:be_still/locator.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/user_service.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserService _userService = locator<UserService>();
  UserModel _currentUser;

  UserModel get currentUser => _currentUser;

  Future setCurrentUser() async {
    _currentUser = await _userService.getCurrentUser();
    notifyListeners();
  }

  UserModel get user {
    return _currentUser;
  }

  updateEmail(String newEmail, String userId) async {
    await _userService.updateEmail(newEmail, userId);
    setCurrentUser();
  }

  updatePassword(String newPassword) async {
    await _userService.updatePassword(newPassword);
    setCurrentUser();
  }
}
