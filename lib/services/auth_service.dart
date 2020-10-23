import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future signIn({
    String email,
    String password,
  }) async {
    try {
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return user != null;
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future registerUser({
    UserModel userData,
    SettingsModel settingsData,
    SharingSettingsModel sharingSettingsData,
    PrayerSettingsModel prayerSettingsData,
    String password,
  }) async {
    try {
      return await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: userData.email,
        password: password,
      )
          .then((value) async {
        FirebaseUser user = value.user;
        await locator<UserService>()
            .addUserData(userData, settingsData, user.uid);
        return user != null;
      });
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future signOut() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      FirebaseUser user = await _firebaseAuth.currentUser();
      return user != null;
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
