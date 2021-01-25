import 'package:be_still/locator.dart';
import 'package:be_still/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider with ChangeNotifier {
  AuthenticationService _authService = locator<AuthenticationService>();

  Future<void> signIn({String email, String password}) async {
    await _authService.signIn(email: email, password: password);
  }

  Future<void> registerUser({
    String email,
    String password,
    String firstName,
    String lastName,
    DateTime dob,
  }) async {
    await _authService.registerUser(
      email,
      password,
      firstName,
      lastName,
      dob,
    );
  }

  // sendVerificationEmail(String email) async {
  //   return await _authService.sendVerificationEmail(email);
  // }

  // confirmToken(String code) async {
  //   return await _authService.confirmToken(code);
  // }

  // changePassword(String code, String newPassword) async {
  //   return await _authService.forgotPassword(code, newPassword);
  // }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> isUserLoggedIn() async {
    return await _authService.isUserLoggedIn();
  }
}
