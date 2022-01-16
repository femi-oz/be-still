import 'package:be_still/flavor_config.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
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
        final message = StringUtils.generateExceptionMessage(e.code);
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
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/forgotPassword');
      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/forgotPassword');
      throw HttpException(message);
    }
  }

  Future<UserVerify> signIn({
    required String email,
    required String password,
  }) async {
    var needsVerification = false;
    try {
      final user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!(user.user?.emailVerified ?? false)) {
        needsVerification = true;
        var e = FirebaseAuthException(
            code: 'not-verified', message: 'not-verified');
        signOut();
        throw HttpException(e.code);
      }
      return UserVerify(
          error: null,
          needsVerification:
              needsVerification); //{'error': '', 'needsVerification': needsVerification};
    } on FirebaseException catch (e) {
      return UserVerify(
          error: PlatformException(code: e.code, message: e.message),
          needsVerification:
              needsVerification); // {'error': e, 'needsVerification': needsVerification};

    } catch (e) {
      return UserVerify(
          error: e as PlatformException,
          needsVerification:
              needsVerification); // {'error': e, 'needsVerification': needsVerification};
    }
  }

  Future sendEmailVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        var actionCodeSettings = ActionCodeSettings(
          url: FlavorConfig.instance.values.appUrl,
          dynamicLinkDomain: FlavorConfig.instance.values.dynamicLink,
          androidPackageName: FlavorConfig.instance.values.packageName,
          androidInstallApp: true,
          androidMinimumVersion: '1',
          iOSBundleId: FlavorConfig.instance.values.packageName,
          handleCodeInApp: true,
        );

        await user.sendEmailVerification(actionCodeSettings);
        signOut();
      }
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);
      await locator<LogService>().createLog(
          message,
          _firebaseAuth.currentUser?.email ?? '',
          'AUTHENTICATION/service/sendEmailVerification');
      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      await locator<LogService>().createLog(
          message,
          _firebaseAuth.currentUser?.email ?? '',
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
      User? user = _firebaseAuth.currentUser;
      await locator<UserService>().addUserData(
        user?.uid ?? '',
        email,
        password,
        firstName,
        lastName,
        dob,
      );
      await sendEmailVerification();
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/registerUser');
      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      await locator<LogService>()
          .createLog(message, email, 'AUTHENTICATION/service/registerUser');
      throw HttpException(message);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);
      await locator<LogService>().createLog(
          message, email, 'AUTHENTICATION/service/sendPasswordResetEmail');
      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      await locator<LogService>().createLog(
          message, email, 'AUTHENTICATION/service/sendPasswordResetEmail');
      throw HttpException(message);
    }
  }

  Future signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);
      await locator<LogService>().createLog(
          message,
          _firebaseAuth.currentUser?.email ?? '',
          'AUTHENTICATION/service/signOut');
      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      await locator<LogService>().createLog(
          message,
          _firebaseAuth.currentUser?.email ?? '',
          'AUTHENTICATION/service/signOut');
      throw HttpException(message);
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      User? user = _firebaseAuth.currentUser;
      return user != null;
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);
      await locator<LogService>().createLog(
          message,
          _firebaseAuth.currentUser?.email ?? '',
          'AUTHENTICATION/service/isUserLoggedIn');
      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      await locator<LogService>().createLog(
          message,
          _firebaseAuth.currentUser?.email ?? '',
          'AUTHENTICATION/service/isUserLoggedIn');
      throw HttpException(message);
    }
  }
}
