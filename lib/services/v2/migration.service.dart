// if user document not found, use v1 service to get user id
// get all user relevant data

import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/update.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MigrationService {
  final _oldUserService = locator<UserService>();
  final _oldSettingsService = locator<SettingsService>();
  final _oldPrayerService = locator<PrayerService>();

  final CollectionReference<Map<String, dynamic>> _userDataCollectionReference =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference<Map<String, dynamic>>
      _prayerDataCollectionReference =
      FirebaseFirestore.instance.collection("prayers");
  Future<void> migrateUserData(String uid) async {
    //old user service
    //set old data
    try {
      UserModel oldUser = await _oldUserService.getCurrentUser(uid);
      SettingsModel oldSettings =
          await _oldSettingsService.getSettings(oldUser.id ?? '');
      PrayerSettingsModel oldPrayerSettings =
          await _oldSettingsService.getPrayerSettings(oldUser.id ?? '');
      SharingSettingsModel oldSharingSettings =
          await _oldSettingsService.getSharingSettings(oldUser.id ?? '');

      final newUser = UserDataModel(
        createdBy: uid,
        createdDate: oldUser.createdOn,
        dateOfBirth: (oldUser.dateOfBirth ?? '').isEmpty
            ? null
            : DateTime.parse(oldUser.dateOfBirth ?? ''),
        defaultSnoozeDuration: oldSettings.defaultSnoozeDuration,
        defaultSnoozeFrequency: oldSettings.defaultSnoozeFrequency,
        devices: [DeviceModel(id: Uuid().v1(), token: oldUser.pushToken)],
        doNotDisturb: oldPrayerSettings.doNotDisturb,
        enableBackgroundMusic: oldPrayerSettings.enableBackgroundMusic,
        enablePushNotification: oldSettings.allowPushNotification,
        enableSharingViaEmail: oldSharingSettings.enableSharingViaEmail,
        enableSharingViaText: oldSharingSettings.enableSharingViaText,
        groups: [],
        id: uid,
        includeAnsweredPrayerAutoDelete:
            oldSettings.includeAnsweredPrayerAutoDelete,
        modifiedBy: uid,
        modifiedDate: DateTime.now(),
        prayers: [],
        enableNotificationsForAllGroups: true,
        status: Status.active,
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
      ).toJson();

      print(newUser);
      _userDataCollectionReference.doc(uid).set(newUser);
      await migrateUserPrayerData(uid, oldUser.id ?? '');
    } catch (e) {
      print(e);
      throw HttpException(e.toString());
    }
  }

  Future<void> migrateUserPrayerData(String uid, String userId) async {
    List<CombinePrayerStream> oldUserPrayers =
        await _oldPrayerService.getPrayers(userId);
    oldUserPrayers =
        oldUserPrayers.where((e) => !(e.prayer?.isGroup ?? false)).toList();
    oldUserPrayers.forEach((e) {
      List<UpdateModel> newPrayerUpdates = [];
      List<TagModel> newPrayerTags = [];
      List<FollowerModel> newPrayerFollowers = [];

      if (e.updates.isNotEmpty)
        newPrayerUpdates = e.updates
            .map((u) => UpdateModel(
                description: u.description,
                id: u.id,
                status: u.deleteStatus == 0 ? Status.deleted : Status.active,
                createdBy: u.createdBy,
                createdDate: u.createdOn,
                modifiedBy: u.modifiedBy,
                modifiedDate: u.modifiedOn))
            .toList();
      if (e.tags.isNotEmpty)
        newPrayerTags = e.tags
            .map((t) => TagModel(
                status: Status.active,
                userId: uid,
                phoneNumber: t.phoneNumber,
                email: t.email,
                displayName: t.displayName,
                contactIdentifier: t.identifier,
                createdBy: t.createdBy,
                createdDate: t.createdOn,
                modifiedBy: t.modifiedBy,
                modifiedDate: t.modifiedOn))
            .toList();

      final newUserPrayer = PrayerDataModel(
              userId: uid,
              description: e.prayer?.description,
              groupId: e.prayer?.groupId == '0' ? '' : e.prayer?.groupId,
              isGroup: e.prayer?.isGroup,
              isAnswered: e.prayer?.isAnswer,
              archivedDate: e.userPrayer?.archivedDate,
              status: e.userPrayer?.deleteStatus == -1
                  ? Status.deleted
                  : e.userPrayer?.isArchived ?? false
                      ? Status.archived
                      : e.userPrayer?.isSnoozed ?? false
                          ? Status.snoozed
                          : e.userPrayer?.status,
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

      _prayerDataCollectionReference.add(newUserPrayer);
    });
  }
}
