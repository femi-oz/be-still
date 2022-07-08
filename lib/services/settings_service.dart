import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/group_settings_model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/services/log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../utils/string_utils.dart';

class SettingsService {
  final CollectionReference<Map<String, dynamic>> _settingsCollectionReference =
      FirebaseFirestore.instance.collection("Setting");
  final CollectionReference<Map<String, dynamic>>
      _prayerSettingsCollectionReference =
      FirebaseFirestore.instance.collection("PrayerSetting");
  final CollectionReference<Map<String, dynamic>>
      _sharingSettingsCollectionReference =
      FirebaseFirestore.instance.collection("SharingSetting");

  final CollectionReference<Map<String, dynamic>>
      _groupPrefernceSettingsCollectionReference =
      FirebaseFirestore.instance.collection("GroupPreferenceSettings");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>>
      _groupSettingsCollectionReference =
      FirebaseFirestore.instance.collection("GroupSettings");

  populateSettings(String deviceId, String userId, String email, String id) {
    SettingsModel settings = SettingsModel(
        id: id,
        archiveAutoDeleteMins: 0,
        allowAlexaReadPrayer: false,
        archiveSortBy: SortType.date,
        userId: userId,
        deviceId: deviceId,
        appearance: '',
        defaultSortBy: SortType.date,
        defaultSnoozeDuration: 15,
        defaultSnoozeFrequency: IntervalRange.thirtyMinutes,
        archiveAutoDelete: IntervalRange.oneYear,
        includeAnsweredPrayerAutoDelete: false,
        allowPushNotification: false,
        allowTextNotification: false,
        pauseInterval: '10s',
        emailUpdateFrequencyMins: 1440,
        emailUpdateNotification: false,
        notifyMeSomeonePostOnGroup: false,
        notifyMeSomeoneSharePrayerWithMe: false,
        allowPrayerTimeNotification: false,
        syncAlexa: false,
        status: Status.active,
        createdBy: email,
        createdOn: DateTime.now(),
        modifiedBy: email,
        modifiedOn: DateTime.now());
    return settings;
  }

  populatePrayerSettings(String userId, String email, String id) {
    PrayerSettingsModel prayerSettings = PrayerSettingsModel(
        id: id,
        allowEmergencyCalls: false,
        autoPlayMusic: false,
        doNotDisturb: false,
        enableBackgroundMusic: false,
        userId: userId,
        frequency: Frequency.m_w_f,
        time: DateFormat('hh:mma').format(DateTime.now()),
        day: DateFormat('ddd').format(DateTime.now()),
        createdBy: email,
        createdOn: DateTime.now(),
        modifiedBy: email,
        modifiedOn: DateTime.now());
    return prayerSettings;
  }

  populateGroupPreferenceSettings(String userId, String id) {
    GroupPreferenceSettings groupPreferenceSettings = GroupPreferenceSettings(
        id: id, userId: userId, enableNotificationForAllGroups: false);
    return groupPreferenceSettings;
  }

  populateSharingSettings(String userId, String email, String id) {
    SharingSettingsModel sharingSettings = SharingSettingsModel(
        id: id,
        userId: userId,
        enableSharingViaEmail: true,
        enableSharingViaText: true,
        churchId: '',
        churchName: '',
        churchPhone: '',
        webFormlink: '',
        churchEmail: '',
        createdBy: email,
        createdOn: DateTime.now(),
        modifiedBy: email,
        modifiedOn: DateTime.now());
    return sharingSettings;
  }

  Future addSettings(String deviceId, String userId, String email) async {
    // Generate uuid

    final settingsId = Uuid().v1();
    final sharingSettingsId = Uuid().v1();
    final prayerSettingsId = Uuid().v1();

    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      // store settings
      await _settingsCollectionReference
          .doc(settingsId)
          .set(populateSettings(deviceId, userId, email, settingsId).toJson());

      //store sharing settings
      await _sharingSettingsCollectionReference.doc(sharingSettingsId).set(
          populateSharingSettings(userId, email, sharingSettingsId).toJson());

      //store prayer settings
      await _prayerSettingsCollectionReference.doc(prayerSettingsId).set(
          populatePrayerSettings(userId, email, prayerSettingsId).toJson());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'SETTINGS/service/addSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  addGroupPreferenceSettings(String userId) async {
    final groupPreferenceSettingsId = Uuid().v1();
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      await _groupPrefernceSettingsCollectionReference
          .doc(groupPreferenceSettingsId)
          .set(
              populateGroupPreferenceSettings(userId, groupPreferenceSettingsId)
                  .toJson());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'SETTINGS/service/addGroupPreferenceSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<SettingsModel> getSettings(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      var settings = await _settingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .get();
      return SettingsModel.fromData(
          settings.docs.toList()[0].data(), settings.docs.toList()[0].id);
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'SETTINGS/service/fetchSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<PrayerSettingsModel> getPrayerSettings(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      var settings = await _prayerSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .get();
      return settings.docs
          .map((e) => PrayerSettingsModel.fromData(e.data(), e.id))
          .toList()[0];
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'SETTINGS/service/getPrayerSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<SharingSettingsModel> getSharingSettings(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      var settings = await _sharingSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .get();
      return settings.docs
          .map((e) => SharingSettingsModel.fromData(e.data(), e.id))
          .toList()[0];
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'SETTINGS/service/getSharingSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<GroupSettings> getGroupSettings(String userId, String groupId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final settings = await _groupSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .where('GroupId', isEqualTo: groupId)
          .get();
      if (settings.docs.length < 1) {
        await addGroupSettings(userId, groupId, false);
        return GroupSettings.defaultValue();
      } else {
        return settings.docs
            .map((e) => GroupSettings.fromData(e.data(), e.id))
            .toList()[0];
      }
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'SETTINGS/service/getGroupSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  populateGroupSettings(
      String userId, String groupId, bool requireAdminApproval, String id) {
    GroupSettings groupsSettings = GroupSettings(
        id: id,
        requireAdminApproval: requireAdminApproval,
        groupId: groupId,
        userId: userId,
        enableNotificationFormNewPrayers: false,
        enableNotificationForUpdates: false,
        notifyOfMembershipRequest: false,
        notifyMeofFlaggedPrayers: false,
        notifyWhenNewMemberJoins: false,
        createdBy: userId,
        createdOn: DateTime.now(),
        modifiedBy: userId,
        modifiedOn: DateTime.now());
    return groupsSettings;
  }

  Future<bool> addGroupSettings(
      String userId, String groupId, bool requireAdminApproval) async {
    final groupSettingsId = Uuid().v1();

    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      _groupSettingsCollectionReference.doc(groupSettingsId).set(
          populateGroupSettings(
                  userId, groupId, requireAdminApproval, groupSettingsId)
              .toJson());
      return true;
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'SETTINGS/service/addGroupSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<GroupPreferenceSettings> getGroupPreferenceSettings(
      String userId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      var settings = await _groupPrefernceSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .get();
      if (settings.docs.length < 1) {
        await addGroupPreferenceSettings(userId);
        settings = await _groupPrefernceSettingsCollectionReference
            .where('UserId', isEqualTo: userId)
            .get();
      }
      return settings.docs
          .map((e) => GroupPreferenceSettings.fromData(e.data(), e.id))
          .toList()[0];
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'SETTINGS/service/getGroupPreferenceSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future updateSettings(
      {required String key,
      required dynamic value,
      required String settingsId}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _settingsCollectionReference.doc(settingsId).update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          settingsId, 'SETTINGS/service/updateSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future updatePrayerSettings(
      {required String key,
      required dynamic value,
      required String settingsId}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _prayerSettingsCollectionReference.doc(settingsId).update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          settingsId, 'SETTINGS/service/updatePrayerSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future updateSharingSettings(
      {required String key,
      required dynamic value,
      required String settingsId}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _sharingSettingsCollectionReference.doc(settingsId).update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          settingsId, 'SETTINGS/service/updateSharingSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future updateGroupPreferenceSettings(
      {required String key,
      required dynamic value,
      required String groupPreferenceSettingsId}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _groupPrefernceSettingsCollectionReference
          .doc(groupPreferenceSettingsId)
          .update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e),
          groupPreferenceSettingsId,
          'SETTINGS/service/updateGroupPreferenceSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }
}
