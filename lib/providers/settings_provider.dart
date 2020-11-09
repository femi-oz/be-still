import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

class SettingsProvider with ChangeNotifier {
  SettingsService _settings = locator<SettingsService>();

  Stream<CombineSettingsStream> getSettings(String userId) {
    return _settings.fetchSettings(userId);
  }

  Future addSettings(
      SettingsModel settingsData, String userId, UserModel userData) async {
    return await _settings.addSettings(settingsData, userId, userData);
  }

  // Stream<DocumentSnapshot> fetchSetting(String id) {
  //   return _settings.fetchSetting(id);
  // }

  // getPrayerSettings({String userId}) async {
  //   return await _prayerSettings.getPrayerSettings(userId);
  // }

  Stream<QuerySnapshot> getPrayerSettings(String userId) {
    return _settings.getPrayerSettings(userId);
  }

  // getSharingSettings({String userId}) async {
  //   return await _sharingSettings.getSharingSettings(userId);
  // }

  Stream<QuerySnapshot> getSharingSettings(String userId) {
    return _settings.getSharingSettings(userId);
  }
}
