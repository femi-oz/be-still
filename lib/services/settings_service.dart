import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SettingsService {
  final CollectionReference _settingsCollectionReference =
      Firestore.instance.collection("Setting");
  final CollectionReference _prayerSettingsCollectionReference =
      Firestore.instance.collection("PrayerSetting");
  final CollectionReference _sharingSettingsCollectionReference =
      Firestore.instance.collection("SharingSetting");

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
      return Firestore.instance.runTransaction(
        (transaction) async {
          // store settings
          await transaction.set(
              _settingsCollectionReference.document(settingsId),
              populateSettings(deviceId, userId, email).toJson());

          //store sharing settings
          await transaction.set(
              _sharingSettingsCollectionReference.document(sharingSettingsId),
              populateSharingSettings(userId, email).toJson());

          //store prayer settings
          await transaction.set(
              _prayerSettingsCollectionReference.document(prayerSettingsId),
              populatePrayerSettings(userId, email).toJson());
        },
      ).then((val) {
        return true;
      }).catchError((e) {
        throw HttpException(e.message);
      });
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
              doc.documents.map((e) => SettingsModel.fromData(e)).toList()[0]);
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<PrayerSettingsModel> getPrayerSettings(String userId) {
    try {
      return _prayerSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((doc) => doc.documents
              .map((e) => PrayerSettingsModel.fromData(e))
              .toList()[0]);
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<SharingSettingsModel> getSharingSettings(String userId) {
    try {
      return _sharingSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((doc) => doc.documents
              .map((e) => SharingSettingsModel.fromData(e))
              .toList()[0]);
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future updateSettings({String key, dynamic value, String settingsId}) async {
    try {
      _settingsCollectionReference.document(settingsId).updateData(
        {key: value},
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future updatePrayerSettings(
      {String key, dynamic value, String settingsId}) async {
    try {
      _prayerSettingsCollectionReference.document(settingsId).updateData(
        {key: value},
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future updateSharingSettings(
      {String key, dynamic value, String settingsId}) async {
    try {
      _sharingSettingsCollectionReference.document(settingsId).updateData(
        {key: value},
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
