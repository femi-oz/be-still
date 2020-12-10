import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future signIn({
    String email,
    String password,
  }) async {
    try {
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
      FirebaseUser user = await _firebaseAuth.currentUser();
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

  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future signOut() async {
    try {
      await _firebaseAuth.signOut();
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
