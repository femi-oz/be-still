import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/reminder.dart';
import 'package:be_still/enums/sortBy.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:uuid/uuid.dart';

class SettingsService {
  final CollectionReference _settingsCollectionReference =
      Firestore.instance.collection("Setting");
  final CollectionReference _prayerSettingsCollectionReference =
      Firestore.instance.collection("PrayerSetting");
  final CollectionReference _sharingSettingsCollectionReference =
      Firestore.instance.collection("SharingSetting");

  populateSettings(String deviceId, String userId, UserModel userData) {
    SettingsModel settings = SettingsModel(
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
        emailUpdateFrequency: false,
        emailUpdateNotification: false,
        notifyMeSomeonePostOnGroup: false,
        notifyMeSomeoneSharePrayerWithMe: false,
        allowPrayerTimeNotification: false,
        syncAlexa: false,
        status: 'Active',
        createdBy: userData.createdBy,
        createdOn: DateTime.now(),
        modifiedBy: userData.createdBy,
        modifiedOn: DateTime.now());
    return settings;
  }

  populatePrayerSettings(String userId, UserModel userData) {
    PrayerSettingsModel prayerSettings = PrayerSettingsModel(
        allowEmergencyCalls: false,
        autoPlayMusic: false,
        doNotDisturb: false,
        enableBackgroundMusic: false,
        userId: userId,
        frequency: ReminderFrequency.m_w_f,
        date: DateTime.now(),
        time: Timestamp.now(),
        createdBy: userData.createdBy,
        createdOn: DateTime.now(),
        modifiedBy: userData.createdBy,
        modifiedOn: DateTime.now());
    return prayerSettings;
  }

  populateSharingSettings(String userId, UserModel userData) {
    SharingSettingsModel sharingSettings = SharingSettingsModel(
        userId: userId,
        enableSharingViaEmail: false,
        enableSharingViaText: false,
        churchId: '',
        phone: '${userData.phone}',
        status: 'Active',
        createdBy: userData.createdBy,
        createdOn: DateTime.now(),
        modifiedBy: userData.createdBy,
        modifiedOn: DateTime.now());
    return sharingSettings;
  }

  Future addSettings(String deviceId, String userId, UserModel userData) async {
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
              populateSettings(deviceId, userId, userData).toJson());

          //store sharing settings
          await transaction.set(
              _sharingSettingsCollectionReference.document(sharingSettingsId),
              populateSharingSettings(userId, userData).toJson());

          //store prayer settings
          await transaction.set(
              _prayerSettingsCollectionReference.document(prayerSettingsId),
              populatePrayerSettings(userId, userData).toJson());
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
}
