import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future signIn({
    String email,
    String password,
    bool rememberMe,
  }) async {
    try {
      await _firebaseAuth
          .setPersistence(rememberMe ? Persistence.LOCAL : Persistence.NONE);
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw HttpException(e.message);
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
      throw HttpException(e.message);
    }
  }

  // Future<void> sendVerificationEmail(String email) async {
  //   try {
  //     await _firebaseAuth.sendPasswordResetEmail(
  //       email: email,
  //       actionCodeSettings: ActionCodeSettings(
  //         url: "https://example.web.app",
  //         androidPackageName: "org.second.bestill.dev",
  //         androidInstallApp: true,
  //         androidMinimumVersion: '12',
  //         iOSBundleId: "org.second.bestill.dev",
  //         handleCodeInApp: true,
  //       ),
  //     );
  //   } catch (e) {
  //     throw HttpException(e.message);
  //   }
  // }

  // Future<void> confirmToken(String code) async {
  //   try {
  //     await _firebaseAuth.verifyPasswordResetCode(code);
  //   } catch (e) {
  //     throw HttpException(e.message);
  //   }
  // }

  // Future<void> forgotPassword(String code, String newPassword) async {
  //   try {
  //     await _firebaseAuth.confirmPasswordReset(
  //       code: code,
  //       newPassword: newPassword,
  //     );
  //   } catch (e) {
  //     throw HttpException(e.message);
  //   }
  // }

  Future signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      User user = _firebaseAuth.currentUser;
      return user != null;
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
