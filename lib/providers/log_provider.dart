import 'package:be_still/locator.dart';
import 'package:be_still/services/log_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<void> setErrorLog(
      String message, String userId, String location) async {
    if (_firebaseAuth.currentUser == null) return null;
    await locator<LogService>().createLog(message, userId, location);
  }
}
