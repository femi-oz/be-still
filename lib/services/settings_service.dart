import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class SettingsService {
  final CollectionReference _settingsCollectionReference =
      Firestore.instance.collection("Settings");
  final CollectionReference _prayerSettingsCollectionReference =
      Firestore.instance.collection("PrayerSettings");
  final CollectionReference _sharingSettingsCollectionReference =
      Firestore.instance.collection("SharingSettings");

  Stream<CombineSettingsStream> _combineStream;
  Stream<CombineSettingsStream> fetchSettings(String userId) {
    try {
      _combineStream = _settingsCollectionReference
          .where(userId, isEqualTo: userId)
          .snapshots()
          .map((convert) {
        return convert.documents.map((e) {
          Stream<SettingsModel> settings = Stream.value(e).map<SettingsModel>(
              (document) => SettingsModel.fromData(document));

          Stream<SharingSettingsModel> sharingSettings =
              _sharingSettingsCollectionReference
                  .document(e.data['UserId'])
                  .snapshots()
                  .map<SharingSettingsModel>(
                      (document) => SharingSettingsModel.fromData(document));

          Stream<PrayerSettingsModel> prayerSettings =
              _prayerSettingsCollectionReference
                  .document(e.data['UserId'])
                  .snapshots()
                  .map<PrayerSettingsModel>(
                      (document) => PrayerSettingsModel.fromData(document));

          return Rx.combineLatest3(settings, sharingSettings, prayerSettings,
              (s, ss, ps) => CombineSettingsStream(s, ss, ps));
        });
      }).switchMap((observables) {
        return observables.length > 0
            ? Rx.combineLatestList(observables)
            : Stream.value(null);
      });
      return _combineStream;
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  populateSettings(
      SettingsModel settingsData, String userId, UserModel userData) {
    SettingsModel settings = SettingsModel(
        userId: userId,
        deviceId: '',
        appearance: '',
        defaultSortBy: '',
        defaultSnoozeDuration: '0',
        archiveAutoDelete: 'false',
        includeAnsweredPrayerAutoDelete: 'false',
        allowPushNotification: 'false',
        allowTextNotification: 'false',
        emailUpdateFrequency: 'false',
        emailUpdateNotification: '',
        notifyMeSomeonePostOnGroup: 'false',
        notifyMeSomeoneSharePrayerWithMe: 'false',
        allowPrayerTimeNotification: 'false',
        syncAlexa: 'false',
        status: 'Active',
        createdBy: '${userData.firstName}${userData.lastName}',
        createdOn: DateTime.now(),
        modifiedBy: '${userData.firstName}${userData.lastName}',
        modifiedOn: DateTime.now());
    return settings;
  }

  Future addSettings(
      SettingsModel settingsData, String userId, UserModel userData) async {
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
              settingsData.toJson());

          //store sharing settings
          await transaction.set(
              _sharingSettingsCollectionReference.document(sharingSettingsId),
              populateSettings(settingsData, userId, userData).toJson());

          //store prayer settings
          await transaction.set(
              _prayerSettingsCollectionReference.document(prayerSettingsId),
              populateSettings(settingsData, userId, userData));
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

  // Future addSettings(String userId, UserModel userData) async {
  //   try {
  //     //store settings
  //     final settingsId = Uuid().v1();
  //     print('settings data $userData');
  //     await _settingsCollectionReference
  //         .document(settingsId)
  //         .setData(setSettings(userId, userData).toJson());
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  // Stream<QuerySnapshot> getSettingsData(String userId) {
  //   try {
  //     return _settingsCollectionReference
  //         .where('UserId', isEqualTo: userId)
  //         .limit(1)
  //         .snapshots();
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // Stream<DocumentSnapshot> fetchSetting(String settingsId) {
  //   try {
  //     return _settingsCollectionReference.document(settingsId).snapshots();
  //   } catch (e) {
  //     return null;
  //   }
  // }
  setPrayerSettings(String userId, UserModel userData) {
    PrayerSettingsModel prayerSettings = PrayerSettingsModel(
        userId: userId,
        frequency: '0',
        date: DateTime.now(),
        time: Timestamp.now(),
        createdBy: '${userData.firstName}${userData.lastName}',
        createdOn: DateTime.now(),
        modifiedBy: '${userData.firstName}${userData.lastName}',
        modifiedOn: DateTime.now());
    return prayerSettings;
  }

  Future addPrayerSettings(String userId, UserModel userData) async {
    try {
      //store prayer settings
      final prayerSettingsId = Uuid().v1();
      print('prayer settings data $userData');

      await _prayerSettingsCollectionReference
          .document(prayerSettingsId)
          .setData(setPrayerSettings(userId, userData).toJson());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<QuerySnapshot> getPrayerSettings(String userId) {
    try {
      return _prayerSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .limit(1)
          .snapshots();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  setSharingSettings(String userId, UserModel userData) {
    SharingSettingsModel sharingSettings = SharingSettingsModel(
        userId: userId,
        enableSharingViaEmail: 'false',
        enableSharingViaText: 'false',
        churchId: '',
        phone: '${userData.phone}',
        status: 'Active',
        createdBy: '${userData.firstName}${userData.lastName}',
        createdOn: DateTime.now(),
        modifiedBy: '${userData.firstName}${userData.lastName}',
        modifiedOn: DateTime.now());
    return sharingSettings;
  }

  Future addSharingSetting(String userId, UserModel userData) async {
    try {
      //store share settings
      final shareSettingsId = Uuid().v1();
      await _sharingSettingsCollectionReference
          .document(shareSettingsId)
          .setData(setSharingSettings(userId, userData).toJson());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<QuerySnapshot> getSharingSettings(String userId) {
    try {
      return _sharingSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .limit(1)
          .snapshots();
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
