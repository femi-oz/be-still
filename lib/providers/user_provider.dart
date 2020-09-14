import 'package:be_still/models/user.model.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel _user;
  void setCurrentUser(UserModel user) {
    _user = user;
  }

  UserModel get user {
    return _user;
  }
}
