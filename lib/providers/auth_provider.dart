import 'package:be_still/locator.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthenticationProvider with ChangeNotifier {
  AuthenticationService _authService = locator<AuthenticationService>();

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  void login({String email, String password, BuildContext context}) async {
    final result = await _authService.signIn(email: email, password: password);
    if (result == null || result is String) {
      _isAuthenticated = false;
      Provider.of<UserProvider>(context).setCurrentUser(result);
    } else {
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  registerUser({String password, UserModel userData}) async {
    return await _authService.registerUser(
        password: password, userData: userData);
  }

  void logout() async {
    final result = await _authService.signOut();
    if (result == true) {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<bool> handleStartUpLogic() async {
    return await _authService.isUserLoggedIn();
  }
}
