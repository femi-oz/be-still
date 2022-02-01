import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/auth_service.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider with ChangeNotifier {
  AuthenticationService _authService = locator<AuthenticationService>();
  bool _needsVerification = false;
  bool get needsVerification => _needsVerification;

  Future<void> signIn({required String email, required String password}) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> biometricSignin() async {
    try {
      return await _authService.biometricAuthentication();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dob,
  }) async {
    try {
      await _authService.registerUser(
        email,
        password,
        firstName,
        lastName,
        dob,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      return await _authService.isUserLoggedIn();
    } catch (e) {
      rethrow;
    }
  }
}
