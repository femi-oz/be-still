import 'package:be_still/models/group_settings_model.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/services/settings_service.dart';
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
  List<GroupSettings> _groupSettings;
  List<GroupSettings> get groupSettings => _groupSettings;
  GroupPreferenceSettings _groupPreferenceSettings;
  GroupPreferenceSettings get groupPreferenceSettings =>
      _groupPreferenceSettings;
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

  Future setGroupSettings(String userId) async {
    _settingsService
        .getGroupSettings(userId)
        .asBroadcastStream()
        .listen((settings) {
      _groupSettings = settings;
      notifyListeners();
    });
  }

  Future setGroupPreferenceSettings(String userId) async {
    _settingsService
        .getGroupPreferenceSettings(userId)
        .asBroadcastStream()
        .listen((settings) {
      _groupPreferenceSettings = settings;
      notifyListeners();
    });
  }

  // Future getGroupSettings(String groupId) async {
  //   _settingsService.getGroupSettings(groupId);
  // }

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

  Future updateGroupSettings(
      {String key, dynamic value, String settingsId}) async {
    await _settingsService.updateGroupSettings(
        key: key, groupSettingsId: settingsId, value: value);
  }

  Future updateGroupPrefenceSettings(
      {String key, dynamic value, String settingsId}) async {
    await _settingsService.updateGroupPreferenceSettings(
        key: key, groupPreferenceSettingsId: settingsId, value: value);
  }
}
