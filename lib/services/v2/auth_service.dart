import 'package:be_still/flavor_config.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationServiceV2 {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _localAuth = LocalAuthentication();

  Future<bool> biometricAuthentication() async {
    if (Settings.enableLocalAuth) {
      try {
        final isAuthenticated = await _localAuth.authenticate(
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

      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);

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
        final message = StringUtils.generateExceptionMessage(e.code);
        throw HttpException(message);
      }
      return UserVerify(error: null, needsVerification: needsVerification);
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);

      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      throw HttpException(message);
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

      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);

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
      await locator<UserServiceV2>().createUser(
          uid: user?.uid ?? '',
          email: email,
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dob);
      await sendEmailVerification();
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);

      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      throw HttpException(message);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);
      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      throw HttpException(message);
    }
  }

  Future signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);
      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      throw HttpException(message);
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      User? user = _firebaseAuth.currentUser;
      return user != null;
    } on FirebaseException catch (e) {
      final message = StringUtils.generateExceptionMessage(e.code);
      throw HttpException(message);
    } catch (e) {
      final message = StringUtils.getErrorMessage(e);
      throw HttpException(message);
    }
  }
}
