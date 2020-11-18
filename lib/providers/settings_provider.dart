import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

class SettingsProvider with ChangeNotifier {
  SettingsService _settingsService = locator<SettingsService>();

  SettingsModel _settings;
  SettingsModel get settings => _settings;
  PrayerSettingsModel _prayerSettings;
  PrayerSettingsModel get prayerSetttings => _prayerSettings;
  SharingSettingsModel _sharingSettings;
  SharingSettingsModel get sharingSetttings => _sharingSettings;

  Future setSettings(String userId) async {
    _settingsService
        .fetchSettings(userId)
        .asBroadcastStream()
        .listen((settings) {
      _settings = settings;
      notifyListeners();
    });
  }

  Future setPrayerSettings(String userId) async {
    _settingsService
        .getPrayerSettings(userId)
        .asBroadcastStream()
        .listen((settings) {
      _prayerSettings = settings;
      notifyListeners();
    });
  }

  Future setSharingSettings(String userId) async {
    _settingsService
        .getSharingSettings(userId)
        .asBroadcastStream()
        .listen((settings) {
      _sharingSettings = settings;
      notifyListeners();
    });
  }
}
