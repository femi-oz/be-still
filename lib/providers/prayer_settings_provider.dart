import 'package:be_still/services/prayer_settings_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

class PrayerSettingsProvider with ChangeNotifier {
  PrayerSettingsService _prayerSettings = locator<PrayerSettingsService>();

  // getPrayerSettings({String userId}) async {
  //   return await _prayerSettings.getPrayerSettings(userId);
  // }

  Stream<QuerySnapshot> getPrayerSettings(String userId) {
    return _prayerSettings.getPrayerSettings(userId);
  }
}
