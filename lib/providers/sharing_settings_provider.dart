import 'package:be_still/services/sharing_service.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

class SharingSettingsProvider with ChangeNotifier {
  SharingSettingsService _sharingSettings = locator<SharingSettingsService>();

  getSharingSettings({String userId}) async {
    return await _sharingSettings.getSharingSettings(userId);
  }
}
