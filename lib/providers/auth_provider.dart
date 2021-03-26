import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/auth_service.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider with ChangeNotifier {
  AuthenticationService _authService = locator<AuthenticationService>();
  bool _needsVerification = false;
  bool get needsVerification => _needsVerification;

  Future<void> signIn({String email, String password}) async {
    Map<String, Object> response =
        await _authService.signIn(email: email, password: password);
    _needsVerification = response['needsVerification'];
    if (_needsVerification) {
      final message = StringUtils.generateExceptionMessage('not-verified');
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/signIn');
      throw HttpException(message);
    }
    if (response['error'] != null) {
      var e = response['error'] as FirebaseAuthException;
      final message = StringUtils.generateExceptionMessage(e.code ?? null);
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/signIn');
      throw HttpException(message);
    }
  }

  Future<void> biometricSignin() async {
    await _authService.biometricAuthentication();
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

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> sendEmailVerification() async =>
      await _authService.sendEmailVerification();

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> isUserLoggedIn() async {
    return await _authService.isUserLoggedIn();
  }
}
