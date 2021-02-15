import 'package:be_still/locator.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  UserService _userService = locator<UserService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel _currentUser;
  UserModel get currentUser => _currentUser;

  List<UserModel> _allUsers;
  List<UserModel> get allUsers => _allUsers;

  Future setCurrentUser(bool isLocalAuth) async {
    var keyRefernence =
        isLocalAuth ? Settings.userKeyRefernce : _firebaseAuth.currentUser.uid;
    _currentUser = await _userService.getCurrentUser(keyRefernence);
    notifyListeners();
  }

  Future setAllUsers() async {
    _userService
        .getAllUsers()
        .asBroadcastStream()
        .listen((docs) => _allUsers = docs);
    notifyListeners();
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
