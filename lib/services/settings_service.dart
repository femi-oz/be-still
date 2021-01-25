import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/models/group_settings_model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
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
        allowAlexaReadPrayer: false,
        archiveSortBy: SortType.date,
        userId: userId,
        deviceId: deviceId,
        appearance: '',
        defaultSortBy: SortType.date,
        defaultSnoozeDuration: IntervalRange.thirtyDays,
        archiveAutoDelete: IntervalRange.oneYear,
        includeAnsweredPrayerAutoDelete: false,
        allowPushNotification: false,
        allowTextNotification: false,
        pauseInterval: SecondsInterval.ten,
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
        phone: '',
        status: Status.active,
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
      var batch = FirebaseFirestore.instance.batch();
      // return FirebaseFirestore.instance.runTransaction(
      //   (transaction) async {
      // store settings
      batch.set(_settingsCollectionReference.doc(settingsId),
          populateSettings(deviceId, userId, email).toJson());

      //store sharing settings
      batch.set(_sharingSettingsCollectionReference.doc(sharingSettingsId),
          populateSharingSettings(userId, email).toJson());

      //store prayer settings
      batch.set(_prayerSettingsCollectionReference.doc(prayerSettingsId),
          populatePrayerSettings(userId, email).toJson());
      //   },
      // ).then((val) {
      //   return true;
      // }).catchError((e) {
      //   throw HttpException(e.message);
      // });
      await batch.commit();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future addGroupSettings(String userId, String email, String groupId) async {
    final groupSettingsId = Uuid().v1();

    try {
      var batch = FirebaseFirestore.instance.batch();
      // return FirebaseFirestore.instance.runTransaction(
      //   (transaction) async {
      batch.set(_groupSettingsCollectionReference.doc(groupSettingsId),
          populateGroupSettings(userId, email, groupId).toJson());
      //   },
      // ).then((val) {
      //   return true;
      // }).catchError((e) {
      //   throw HttpException(e.message);
      // });
      await batch.commit();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  addGroupPreferenceSettings(String userId) async {
    final groupPreferenceSettingsId = Uuid().v1();
    try {
      var batch = FirebaseFirestore.instance.batch();
      // return FirebaseFirestore.instance.runTransaction(
      //   (transaction) async {
      batch.set(
          _groupPrefernceSettingsCollectionReference
              .doc(groupPreferenceSettingsId),
          populateGroupPreferenceSettings(userId).toJson());
      //   },
      // ).then((val) {
      //   return true;
      // }).catchError((e) {
      //   throw HttpException(e.message);
      // });
      await batch.commit();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<SettingsModel> fetchSettings(String userId) {
    try {
      return _settingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((doc) =>
              doc.docs.map((e) => SettingsModel.fromData(e)).toList()[0]);
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<PrayerSettingsModel> getPrayerSettings(String userId) {
    try {
      return _prayerSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((doc) =>
              doc.docs.map((e) => PrayerSettingsModel.fromData(e)).toList()[0]);
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<SharingSettingsModel> getSharingSettings(String userId) {
    try {
      print('----------------');
      print(userId);
      print('----------------');
      return _sharingSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((doc) => doc.docs
              .map((e) => SharingSettingsModel.fromData(e))
              .toList()[0]);
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<List<GroupSettings>> getGroupSettings(String userId) {
    try {
      return _groupSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .asyncMap(
              (e) => e.docs.map((doc) => GroupSettings.fromData(doc)).toList());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<GroupPreferenceSettings> getGroupPreferenceSettings(String userId) {
    try {
      return _groupPrefernceSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .asyncMap((e) => e.docs
              .map((doc) => GroupPreferenceSettings.fromData(doc))
              .toList()[0]);
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future updateSettings({String key, dynamic value, String settingsId}) async {
    try {
      _settingsCollectionReference.doc(settingsId).update(
        {key: value},
      );
    } catch (e) {
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
      throw HttpException(e.message);
    }
  }
}
