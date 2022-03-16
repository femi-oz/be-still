// if user document not found, use v1 service to get user id
// get all user relevant data

import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/update.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MigrationService {
  final _oldUserService = locator<UserService>();
  final _oldSettingsService = locator<SettingsService>();
  final _oldprayerService = locator<PrayerService>();

  final CollectionReference<Map<String, dynamic>>
      _prayerDataCollectionReference =
      FirebaseFirestore.instance.collection('prayers');

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

    Stream<List<CombinePrayerStream>> oldUserPrayers =
        _oldprayerService.getPrayers(oldUser.id ?? '');

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

    oldUserPrayers.forEach((element) {
      List<UpdateModel> newPrayerUpdates = [];
      List<TagModel> newPrayerTags = [];
      List<FollowerModel> newPrayerFollowers = [];

      element.forEach((e) {
        if (e.updates.isNotEmpty)
          e.updates.forEach((u) {
            newPrayerUpdates.add(UpdateModel(
                description: u.description,
                id: u.id,
                status: u.deleteStatus == 0 ? Status.deleted : Status.active,
                createdBy: u.createdBy,
                createdDate: u.createdOn,
                modifiedBy: u.modifiedBy,
                modifiedDate: u.modifiedOn));
          });
        if (e.tags.isNotEmpty)
          e.tags.forEach((t) {
            newPrayerTags.add(TagModel(
                userId: t.userId,
                phoneNumber: t.phoneNumber,
                email: t.email,
                displayName: t.displayName,
                contactIdentifier: t.identifier,
                createdBy: t.createdBy,
                createdDate: t.createdOn,
                modifiedBy: t.modifiedBy,
                modifiedDate: t.modifiedOn));
          });

        final newUserPrayer = PrayerDataModel(
                userId: oldUser.id,
                description: e.prayer?.description,
                groupId: e.prayer?.groupId,
                isGroup: e.prayer?.isGroup,
                isAnswered: e.prayer?.isAnswer,
                status: e.prayer?.status,
                isFavorite: e.userPrayer?.isFavorite,
                isInappropriate: e.prayer?.isInappropriate,
                snoozeEndDate: e.userPrayer?.snoozeEndDate,
                snoozeDuration: e.userPrayer?.snoozeDuration,
                snoozeFrequency: e.userPrayer?.snoozeFrequency,
                createdBy: e.prayer?.createdBy,
                createdDate: e.prayer?.createdOn,
                creatorName: e.prayer?.creatorName,
                modifiedBy: e.prayer?.modifiedBy,
                modifiedDate: e.prayer?.modifiedOn,
                updates: newPrayerUpdates,
                tags: newPrayerTags,
                followers: newPrayerFollowers)
            .toJson();

        print(newUserPrayer);

        // _prayerDataCollectionReference.add(newUserPrayer).then((value) {});
      });
    });
  }
}
