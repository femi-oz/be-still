import 'package:be_still/locator.dart';
import 'package:be_still/services/log_service.dart';
import 'package:flutter/material.dart';

class LogProvider with ChangeNotifier {
  Future<void> setErrorLog(
      String code, String message, String userId, String location) async {
    await locator<LogService>().createLog(code, message, userId, location);
  }
}
