import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/user_service.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _localAuth = LocalAuthentication();
  bool isAuthenticated = false;

  Future<bool> biometricAuthentication(String email) async {
    if (Settings.enableLocalAuth) {
      try {
        isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'authenticate to access',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        );
        if (!isAuthenticated) {
          _localAuth.stopAuthentication();
          signOut();
          return false;
        } else
          return true;
      } on PlatformException catch (e) {
        _localAuth.stopAuthentication();
        signOut();
        final message = StringUtils.generateExceptionMessage(e.code ?? null);
        await locator<LogService>().createLog(
            message, email, 'AUTHENTICATION/service/biometricAuthentication');
        throw HttpException(message);
      }
    } else
      return false;
  }

  Future forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code ?? null);
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/forgotPassword');
      throw HttpException(message);
    }
  }

  Future<Map<String, Object>> signIn({
    String email,
    String password,
  }) async {
    var needsVerification = false;
    try {
      final user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!user.user.emailVerified) {
        needsVerification = true;
        var e = FirebaseAuthException(
            code: 'not-verified', message: 'not-verified');
        throw HttpException(e.code);
      }
      return {'error': null, 'needsVerification': needsVerification};
    } catch (e) {
      return {'error': e, 'needsVerification': needsVerification};
    }
  }

  Future sendEmailVerification() async {
    try {
      User user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        var actionCodeSettings = ActionCodeSettings(
          url: 'https://bestill.page.link/?email=${user.email}',
          dynamicLinkDomain: 'bestill.page.link',
          androidPackageName: 'org.second.bestill.dev',
          androidInstallApp: true,
          androidMinimumVersion: '1',
          iOSBundleId: 'org.second.bestill.dev',
          handleCodeInApp: true,
        );

        await user.sendEmailVerification(actionCodeSettings);
      }
    } catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code ?? null);
      await locator<LogService>().createLog(
          message,
          _firebaseAuth.currentUser.email,
          'AUTHENTICATION/service/sendEmailVerification');
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
      await sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      final message = StringUtils.generateExceptionMessage(e?.code ?? null);
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/registerUser');
      throw HttpException(message);
    } catch (e) {
      final message =
          StringUtils.generateExceptionMessage(e?.toString() ?? null);
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/registerUser');
      throw HttpException(message);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code ?? null);
      await locator<LogService>().createLog(
          message, email, 'AUTHENTICATION/service/sendPasswordResetEmail');
      throw HttpException(message);
    }
  }

  Future signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code ?? null);
      await locator<LogService>().createLog(message,
          _firebaseAuth.currentUser.email, 'AUTHENTICATION/service/signOut');
      throw HttpException(message);
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      User user = _firebaseAuth.currentUser;
      return user != null;
    } catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code ?? null);
      await locator<LogService>().createLog(
          message,
          _firebaseAuth.currentUser.email,
          'AUTHENTICATION/service/isUserLoggedIn');
      throw HttpException(message);
    }
  }
}
