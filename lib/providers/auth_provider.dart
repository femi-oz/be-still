import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/auth_service.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider with ChangeNotifier {
  AuthenticationService _authService = locator<AuthenticationService>();
  bool _needsVerification = false;
  bool get needsVerification => _needsVerification;

  Future<void> signIn({required String email, required String password}) async {
    UserVerify response =
        await _authService.signIn(email: email, password: password);
    _needsVerification = response.needsVerification;
    if (_needsVerification) {
      final message = StringUtils.generateExceptionMessage('not-verified');
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/signIn');
      throw HttpException(message);
    }
    if (response.error != null) {
      final e = response.error;
      final message = StringUtils.generateExceptionMessage(e?.code);
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/signIn');
      throw HttpException(message);
    }
  }

  Future<bool> biometricSignin(String email) async {
    return await _authService.biometricAuthentication(email);
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dob,
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
