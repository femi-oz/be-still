import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/user_service.dart';
import 'package:be_still/utils/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _localAuth = LocalAuthentication();
  bool isAuthenticated = false;

  Future<void> biometricAuthentication() async {
    if (Settings.enableLocalAuth) {
      try {
        isAuthenticated = await _localAuth.authenticateWithBiometrics(
          localizedReason: 'authenticate to access',
          useErrorDialogs: true,
          stickyAuth: true,
        );
        if (!isAuthenticated) {
          _localAuth.stopAuthentication();
          await locator<LogService>().createLog(
              'Authentication Cancelled',
              _firebaseAuth.currentUser.email,
              'AUTHENTICATION/service/biometricAuthentication');
          throw HttpException('Authentication Cancelled');
        }
      } on PlatformException catch (e) {
        _localAuth.stopAuthentication();
        await locator<LogService>().createLog(
            e.message,
            _firebaseAuth.currentUser.email,
            'AUTHENTICATION/service/biometricAuthentication');
        throw HttpException(e.message);
      }
    }
  }

  Future forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      await locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          email,
          'AUTHENTICATION/service/forgotPassword');
      throw HttpException(e.message);
    }
  }

  Future signIn({
    String email,
    String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      var message = e.code == 'wrong-password'
          ? 'Username / Password is incorrect'
          : e.code == 'invalid-email'
              ? 'Email format is wrong'
              : e.code == 'user-not-found'
                  ? 'Username / Password is incorrect'
                  : 'An error occured. Please try again';
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/signIn');
      throw HttpException(message);
    }
  }

  Future registerUser(
    String email,
    String password,
    String firstName,
    String lastName,
    DateTime dob,
  ) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = _firebaseAuth.currentUser;
      await locator<UserService>().addUserData(
        user.uid,
        email,
        password,
        firstName,
        lastName,
        dob,
      );
    } catch (e) {
      await locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          email,
          'AUTHENTICATION/service/registerUser');
      throw HttpException(e.message);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      await locator<LogService>().createLog(
          e.message, email, 'AUTHENTICATION/service/sendPasswordResetEmail');
      throw HttpException(e.message);
    }
  }

  Future signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      await locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          _firebaseAuth.currentUser.email,
          'AUTHENTICATION/service/signOut');
      throw HttpException(e.message);
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      User user = _firebaseAuth.currentUser;
      return user != null;
    } catch (e) {
      await locator<LogService>().createLog(
          e.message,
          _firebaseAuth.currentUser.email,
          'AUTHENTICATION/service/isUserLoggedIn');
      throw HttpException(e.message);
    }
  }
}
