import 'package:be_still/models/user.model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel _currentUser;

  UserModel get currentUser => _currentUser;

  void setCurrentUser(FirebaseUser user) {
    //Fetch USer from Firestore
  }

  UserModel get user {
    return _currentUser;
  }
}
