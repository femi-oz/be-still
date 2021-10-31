import 'package:be_still/models/group_settings_model.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

class SettingsProvider with ChangeNotifier {
  SettingsService _settingsService = locator<SettingsService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  SettingsModel _settings;
  SettingsModel get settings => _settings;
  PrayerSettingsModel _prayerSettings;
  PrayerSettingsModel get prayerSetttings => _prayerSettings;
  SharingSettingsModel _sharingSettings;
  SharingSettingsModel get sharingSettings => _sharingSettings;
  GroupSettings _groupSettings;
  GroupSettings get groupSettings => _groupSettings;
  GroupPreferenceSettings _groupPreferenceSettings;
  GroupPreferenceSettings get groupPreferenceSettings =>
      _groupPreferenceSettings;

  Future setSettings(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    var settings = await _settingsService.getSettings(userId);
    _settings = settings;
    notifyListeners();
  }

  Future setPrayerSettings(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    var settings = await _settingsService.getPrayerSettings(userId);
    _prayerSettings = settings;
    notifyListeners();
  }

  Future setSharingSettings(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    var settings = await _settingsService.getSharingSettings(userId);
    _sharingSettings = settings;
    notifyListeners();
  }

  Future setGroupSettings(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    var settings = await _settingsService.getGroupSettings(userId);
    _groupSettings = settings;
    notifyListeners();
  }

  Future setGroupPreferenceSettings(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    var settings = await _settingsService.getGroupPreferenceSettings(userId);
    _groupPreferenceSettings = settings;
    notifyListeners();
  }

  Future updateSettings(
    String userId, {
    String key,
    dynamic value,
    String settingsId,
  }) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _settingsService.updateSettings(
        key: key, settingsId: settingsId, value: value);
    await setSettings(userId);
  }

  Future updatePrayerSettings(String userId,
      {String key, dynamic value, String settingsId}) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _settingsService.updatePrayerSettings(
        key: key, settingsId: settingsId, value: value);
    await setPrayerSettings(userId);
  }

  Future updateSharingSettings(String userId,
      {String key, dynamic value, String settingsId}) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _settingsService.updateSharingSettings(
        key: key, settingsId: settingsId, value: value);
    await setSharingSettings(userId);
  }

  Future updateGroupSettings(String userId,
      {String key, dynamic value, String settingsId}) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _settingsService.updateGroupSettings(
        key: key, groupSettingsId: settingsId, value: value);
    await setGroupSettings(userId);
  }

  Future updateGroupPrefenceSettings(String userId,
      {String key, dynamic value, String settingsId}) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _settingsService.updateGroupPreferenceSettings(
        key: key, groupPreferenceSettingsId: settingsId, value: value);
    await setGroupPreferenceSettings(userId);
  }
}
