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
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SettingsService {
  final CollectionReference _settingsCollectionReference =
      FirebaseFirestore.instance.collection("Setting");
  final CollectionReference _prayerSettingsCollectionReference =
      FirebaseFirestore.instance.collection("PrayerSetting");
  final CollectionReference _sharingSettingsCollectionReference =
      FirebaseFirestore.instance.collection("SharingSetting");
  final CollectionReference _groupSettingsCollectionReference =
      FirebaseFirestore.instance.collection("GroupSettings");
  final CollectionReference _groupPrefernceSettingsCollectionReference =
      FirebaseFirestore.instance.collection("GroupPreferenceSettings");

  populateSettings(String deviceId, String userId, email) {
    SettingsModel settings = SettingsModel(
        archiveAutoDeleteMins: 43200,
        defaultSnoozeDurationMins: 30,
        allowAlexaReadPrayer: false,
        archiveSortBy: SortType.date,
        userId: userId,
        deviceId: deviceId,
        appearance: '',
        defaultSortBy: SortType.date,
        defaultSnoozeDuration: IntervalRange.thirtyMinutes,
        archiveAutoDelete: IntervalRange.oneYear,
        includeAnsweredPrayerAutoDelete: false,
        allowPushNotification: false,
        allowTextNotification: false,
        pauseInterval: '10s',
        emailUpdateFrequency: Frequency.daily,
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

  populatePrayerSettings(String userId, String email) {
    PrayerSettingsModel prayerSettings = PrayerSettingsModel(
        allowEmergencyCalls: false,
        autoPlayMusic: false,
        doNotDisturb: false,
        enableBackgroundMusic: false,
        userId: userId,
        frequency: Frequency.m_w_f,
        // date: DateTime.now(),
        time: DateFormat('hh:mma').format(DateTime.now()),
        day: DateFormat('ddd').format(DateTime.now()),
        createdBy: email,
        createdOn: DateTime.now(),
        modifiedBy: email,
        modifiedOn: DateTime.now());
    return prayerSettings;
  }

  populateGroupPreferenceSettings(String userId) {
    GroupPreferenceSettings groupPreferenceSettings = GroupPreferenceSettings(
        userId: userId, enableNotificationForAllGroups: false);
    return groupPreferenceSettings;
  }

  populateGroupSettings(String userId, String email, String groupId) {
    GroupSettings groupsSettings = GroupSettings(
        userId: userId,
        groupId: groupId,
        enableNotificationFormNewPrayers: false,
        enableNotificationForUpdates: false,
        notifyOfMembershipRequest: false,
        notifyMeofFlaggedPrayers: false,
        notifyWhenNewMemberJoins: false,
        createdBy: email,
        createdOn: DateTime.now(),
        modifiedBy: email,
        modifiedOn: DateTime.now());
    return groupsSettings;
  }

  populateSharingSettings(String userId, String email) {
    SharingSettingsModel sharingSettings = SharingSettingsModel(
        userId: userId,
        enableSharingViaEmail: false,
        enableSharingViaText: false,
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
      // store settings
      await _settingsCollectionReference
          .doc(settingsId)
          .set(populateSettings(deviceId, userId, email).toJson());

      //store sharing settings
      await _sharingSettingsCollectionReference
          .doc(sharingSettingsId)
          .set(populateSharingSettings(userId, email).toJson());

      //store prayer settings
      await _prayerSettingsCollectionReference
          .doc(prayerSettingsId)
          .set(populatePrayerSettings(userId, email).toJson());
    } catch (e) {
      locator<LogService>()
          .createLog(e.message, userId, 'SETTINGS/service/addSettings');
      throw HttpException(e.message);
    }
  }

  Future addGroupSettings(String userId, String email, String groupId) async {
    final groupSettingsId = Uuid().v1();

    try {
      await _groupSettingsCollectionReference
          .doc(groupSettingsId)
          .set(populateGroupSettings(userId, email, groupId).toJson());
    } catch (e) {
      locator<LogService>()
          .createLog(e.message, userId, 'SETTINGS/service/addGroupSettings');
      throw HttpException(e.message);
    }
  }

  addGroupPreferenceSettings(String userId) async {
    final groupPreferenceSettingsId = Uuid().v1();
    try {
      await _groupPrefernceSettingsCollectionReference
          .doc(groupPreferenceSettingsId)
          .set(populateGroupPreferenceSettings(userId).toJson());
    } catch (e) {
      locator<LogService>().createLog(
          e.message, userId, 'SETTINGS/service/addGroupPreferenceSettings');
      throw HttpException(e.message);
    }
  }

  Future<SettingsModel> getSettings(String userId) async {
    try {
      var settings = await _settingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .get();
      return SettingsModel.fromData(settings.docs.toList()[0]);
    } catch (e) {
      locator<LogService>()
          .createLog(e.message, userId, 'SETTINGS/service/fetchSettings');
      throw HttpException(e.message);
    }
  }

  Future<PrayerSettingsModel> getPrayerSettings(String userId) async {
    try {
      var settings = await _prayerSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .get();
      return settings.docs
          .map((e) => PrayerSettingsModel.fromData(e))
          .toList()[0];
    } catch (e) {
      locator<LogService>()
          .createLog(e.message, userId, 'SETTINGS/service/getPrayerSettings');
      throw HttpException(e.message);
    }
  }

  Future<SharingSettingsModel> getSharingSettings(String userId) async {
    try {
      var settings = await _sharingSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .get();
      return settings.docs
          .map((e) => SharingSettingsModel.fromData(e))
          .toList()[0];
    } catch (e) {
      locator<LogService>()
          .createLog(e.message, userId, 'SETTINGS/service/getSharingSettings');
      throw HttpException(e.message);
    }
  }

  Future<List<GroupSettings>> getGroupSettings(String userId) async {
    try {
      var settings = await _sharingSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .get();
      return settings.docs.map((e) => GroupSettings.fromData(e)).toList();
    } catch (e) {
      locator<LogService>()
          .createLog(e.message, userId, 'SETTINGS/service/getGroupSettings');
      throw HttpException(e.message);
    }
  }

  Future<GroupPreferenceSettings> getGroupPreferenceSettings(
      String userId) async {
    try {
      var settings = await _groupPrefernceSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .get();
      return settings.docs
          .map((e) => GroupPreferenceSettings.fromData(e))
          .toList()[0];
    } catch (e) {
      locator<LogService>().createLog(
          e.message, userId, 'SETTINGS/service/getGroupPreferenceSettings');
      throw HttpException(e.message);
    }
  }

  Future updateSettings({String key, dynamic value, String settingsId}) async {
    print(value);
    try {
      _settingsCollectionReference.doc(settingsId).update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>()
          .createLog(e.message, settingsId, 'SETTINGS/service/updateSettings');
      throw HttpException(e.message);
    }
  }

  Future updatePrayerSettings(
      {String key, dynamic value, String settingsId}) async {
    try {
      _prayerSettingsCollectionReference.doc(settingsId).update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message, settingsId, 'SETTINGS/service/updatePrayerSettings');
      throw HttpException(e.message);
    }
  }

  Future updateSharingSettings(
      {String key, dynamic value, String settingsId}) async {
    try {
      _sharingSettingsCollectionReference.doc(settingsId).update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message, settingsId, 'SETTINGS/service/updateSharingSettings');
      throw HttpException(e.message);
    }
  }

  Future updateGroupSettings(
      {String key, dynamic value, String groupSettingsId}) async {
    try {
      _groupSettingsCollectionReference.doc(groupSettingsId).update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message, groupSettingsId, 'SETTINGS/service/updateGroupSettings');
      throw HttpException(e.message);
    }
  }

  Future updateGroupPreferenceSettings(
      {String key, dynamic value, String groupPreferenceSettingsId}) async {
    try {
      _groupPrefernceSettingsCollectionReference
          .doc(groupPreferenceSettingsId)
          .update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>().createLog(e.message, groupPreferenceSettingsId,
          'SETTINGS/service/updateGroupPreferenceSettings');
      throw HttpException(e.message);
    }
  }
}
