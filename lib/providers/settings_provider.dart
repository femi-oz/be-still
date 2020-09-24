import 'package:be_still/services/settings_service.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

class SettingsProvider with ChangeNotifier {
  SettingsService _settings = locator<SettingsService>();

  getSettings({String userId}) async {
    return await _settings.getSettingsData(userId);
  }
}
