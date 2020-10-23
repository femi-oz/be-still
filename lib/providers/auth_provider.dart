import 'package:be_still/locator.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider with ChangeNotifier {
  AuthenticationService _authService = locator<AuthenticationService>();

  login({String email, String password, BuildContext context}) async {
    return await _authService.signIn(email: email, password: password);
  }

  registerUser({String password, UserModel userData}) async {
    return await _authService.registerUser(
        password: password, userData: userData);
  }

  forgotPassword({String email}) async {
    return await _authService.forgotPassword(email);
  }

  void logout() async {
    await _authService.signOut();
  }

  Future<bool> isLoggedIn() async {
    return await _authService.isUserLoggedIn();
  }
}
