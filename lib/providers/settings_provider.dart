import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/utils/prefs.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

class SettingsProvider with ChangeNotifier {
  SettingsService _settingsService = locator<SettingsService>();
  SettingsPrefrences _settingsPrefs = SettingsPrefrences();

  SettingsModel _settings;
  SettingsModel get settings => _settings;
  PrayerSettingsModel _prayerSettings;
  PrayerSettingsModel get prayerSetttings => _prayerSettings;
  SharingSettingsModel _sharingSettings;
  SharingSettingsModel get sharingSetttings => _sharingSettings;
  bool _isFaceIdEnabled = false;
  bool get isFaceIdEnabled => _isFaceIdEnabled;
  bool _hasAccessToContact = false;
  bool get hasAccessToContact => _hasAccessToContact;

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

  Future setDefaultSettings() async {
    _isFaceIdEnabled = await _settingsPrefs.getFaceIdSetting();
    _hasAccessToContact = await _settingsPrefs.getContactAccessSetting();
    notifyListeners();
  }

  Future setFaceIdSetting(bool value) async {
    await _settingsPrefs.setFaceIdSetting(value);
    _isFaceIdEnabled = value;
    notifyListeners();
  }

  Future grantAccessToContact(bool value) async {
    await _settingsPrefs.grantAccessToContacts(value);
    _hasAccessToContact = value;
    notifyListeners();
  }

  Future updateSettings({String key, dynamic value, String settingsId}) async {
    await _settingsService.updateSettings(
        key: key, settingsId: settingsId, value: value);
  }

  Future updatePrayerSettings(
      {String key, dynamic value, String settingsId}) async {
    await _settingsService.updatePrayerSettings(
        key: key, settingsId: settingsId, value: value);
  }

  Future updateSharingSettings(
      {String key, dynamic value, String settingsId}) async {
    await _settingsService.updateSharingSettings(
        key: key, settingsId: settingsId, value: value);
  }
}
