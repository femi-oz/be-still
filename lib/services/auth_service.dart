import 'package:be_still/locator.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/prayer_settings_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/services/sharing_service.dart';
import 'package:be_still/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

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
      // if (user.isEmailVerified) return user.uid;
      // return null;
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
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
        // user.sendEmailVerification();
        FirebaseUser user = value.user;
        // Save user information in firestore
        await locator<UserService>().addUserData(userData, user.uid);
        await locator<SettingsService>().addSettings(userData, settingsData);
        await locator<SharingSettingsService>()
            .addSharingSetting(userData, sharingSettingsData);
        await locator<PrayerSettingsService>()
            .addPrayerSettings(userData, prayerSettingsData);
        return user != null;
      });
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
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
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future<bool> isUserLoggedIn() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null;
  }
}
