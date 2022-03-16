// if user document not found, use v1 service to get user id
// get all user relevant data

import 'package:be_still/locator.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/services/user_service.dart';

class MigrationService {
  final _oldUserService = locator<UserService>();
  final _oldSettingsService = locator<SettingsService>();

  UserModel oldUser = UserModel();
  SettingsModel oldSettings = SettingsModel();
  PrayerSettingsModel oldPrayerSettings = PrayerSettingsModel();
  SharingSettingsModel oldSharingSettings = SharingSettingsModel();

  // final GroupSettings groupSettingsSettings = GroupSettings();
  // GroupPreferenceSettings oldGroupPrefSettings = GroupPreferenceSettings();

  Future<void> migrateUserData(String uid) async {
    //old user service
    //set old data
    oldUser = await _oldUserService.getUserById(uid);
    oldSettings = await _oldSettingsService.getSettings(oldUser.id ?? '');
    oldPrayerSettings =
        await _oldSettingsService.getPrayerSettings(oldUser.id ?? '');
    oldSharingSettings =
        await _oldSettingsService.getSharingSettings(oldUser.id ?? '');

    final UserDataModel newUser = UserDataModel(
      email: oldUser.email,
      firstName: oldUser.firstName,
      lastName: oldUser.lastName,
      churchEmail: oldSharingSettings.churchEmail,
      churchName: oldSharingSettings.churchName,
      churchPhone: oldSharingSettings.churchPhone,
      archiveAutoDeleteMinutes: oldSettings.archiveAutoDeleteMins,
      archiveSortBy: oldSettings.archiveSortBy,
      autoPlayMusic: oldPrayerSettings.autoPlayMusic,
      churchWebFormUrl: oldSharingSettings.webFormlink,
      allowEmergencyCalls: oldPrayerSettings.allowEmergencyCalls,
    );
  }
}
