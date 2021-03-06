import 'dart:io';

import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/v2/auth_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AuthenticationProviderV2 with ChangeNotifier {
  AuthenticationServiceV2 _authenticationServicev2 =
      locator<AuthenticationServiceV2>();
  bool _needsVerification = false;
  bool get needsVerification => _needsVerification;

  Future<void> signIn({required String email, required String password}) async {
    try {
      UserVerify response = await _authenticationServicev2.signIn(
          email: email, password: password);
      _needsVerification = response.needsVerification;
      if (_needsVerification) {
        final message = StringUtils.generateExceptionMessage('not-verified');
        throw HttpException(message);
      }
      if (response.error != null) {
        final e = response.error;
        final message = StringUtils.generateExceptionMessage(e?.code);
        throw HttpException(message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> biometricSignin() async {
    try {
      return await _authenticationServicev2.biometricAuthentication();
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
      await _authenticationServicev2.registerUser(
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
      await _authenticationServicev2.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authenticationServicev2.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authenticationServicev2.signOut();
      await FirebaseFirestore.instance.terminate();
      await FirebaseFirestore.instance.clearPersistence();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      return await _authenticationServicev2.isUserLoggedIn();
    } catch (e) {
      rethrow;
    }
  }
}
