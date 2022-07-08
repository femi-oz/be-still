// import 'package:be_still/models/group_settings_model.dart';
// import 'package:be_still/models/prayer_settings.model.dart';
// import 'package:be_still/models/settings.model.dart';
// import 'package:be_still/models/sharing_settings.model.dart';
// import 'package:be_still/services/settings_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';

// import '../locator.dart';

// class SettingsProvider with ChangeNotifier {
//   SettingsService _settingsService = locator<SettingsService>();
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//   SettingsModel _settings = SettingsModel.defaultValue();
//   SettingsModel get settings => _settings;
//   PrayerSettingsModel _prayerSettings = PrayerSettingsModel.defaultValue();
//   PrayerSettingsModel get prayerSetttings => _prayerSettings;
//   SharingSettingsModel _sharingSettings = SharingSettingsModel.defaultValue();
//   SharingSettingsModel get sharingSettings => _sharingSettings;
//   GroupSettings _groupSettings = GroupSettings.defaultValue();
//   GroupSettings get groupSettings => _groupSettings;
//   GroupPreferenceSettings _groupPreferenceSettings =
//       GroupPreferenceSettings.defaultValue();
//   GroupPreferenceSettings get groupPreferenceSettings =>
//       _groupPreferenceSettings;

//   Future setSettings(String userId) async {
//     try {
//       if (_firebaseAuth.currentUser == null) return null;
//       var settings = await _settingsService.getSettings(userId);
//       _settings = settings;
//       notifyListeners();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future setPrayerSettings(String userId) async {
//     try {
//       if (_firebaseAuth.currentUser == null) return null;
//       var settings = await _settingsService.getPrayerSettings(userId);
//       _prayerSettings = settings;
//       notifyListeners();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future setSharingSettings(String userId) async {
//     try {
//       if (_firebaseAuth.currentUser == null) return null;
//       var settings = await _settingsService.getSharingSettings(userId);
//       _sharingSettings = settings;
//       notifyListeners();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future setGroupPreferenceSettings(String userId) async {
//     try {
//       if (_firebaseAuth.currentUser == null) return null;
//       var settings = await _settingsService.getGroupPreferenceSettings(userId);
//       _groupPreferenceSettings = settings;
//       notifyListeners();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future updateSettings(
//     String userId, {
//     required String key,
//     required dynamic value,
//     required String settingsId,
//   }) async {
//     try {
//       if (_firebaseAuth.currentUser == null) return null;
//       await _settingsService.updateSettings(
//           key: key, settingsId: settingsId, value: value);
//       await setSettings(userId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future updatePrayerSettings(String userId,
//       {required String key,
//       required dynamic value,
//       required String settingsId}) async {
//     try {
//       if (_firebaseAuth.currentUser == null) return null;
//       await _settingsService.updatePrayerSettings(
//           key: key, settingsId: settingsId, value: value);
//       await setPrayerSettings(userId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future updateSharingSettings(String userId,
//       {required String key,
//       required dynamic value,
//       required String settingsId}) async {
//     try {
//       if (_firebaseAuth.currentUser == null) return null;
//       await _settingsService.updateSharingSettings(
//           key: key, settingsId: settingsId, value: value);
//       await setSharingSettings(userId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future updateGroupPrefenceSettings(String userId,
//       {required String key,
//       required dynamic value,
//       required String settingsId}) async {
//     try {
//       if (_firebaseAuth.currentUser == null) return null;
//       await _settingsService.updateGroupPreferenceSettings(
//           key: key, groupPreferenceSettingsId: settingsId, value: value);
//       await setGroupPreferenceSettings(userId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<GroupSettings> getGroupSettings(String userId, String groupId) async {
//     try {
//       return _settingsService.getGroupSettings(userId, groupId);
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
