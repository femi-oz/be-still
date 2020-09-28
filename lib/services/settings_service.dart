import 'package:be_still/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:uuid/uuid.dart';

class SettingsService {
  final CollectionReference _settingsCollectionReference =
      Firestore.instance.collection("Settings");

  setSettings(String userId, UserModel userData) {
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

  Future addSettings(String userId, UserModel userData) async {
    try {
      //store settings
      final settingsId = Uuid().v1();
      print('settings data $userData');
      await _settingsCollectionReference
          .document(settingsId)
          .setData(setSettings(userId, userData).toJson());
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Stream<QuerySnapshot> getSettingsData(String userId) {
    try {
      return _settingsCollectionReference
          .where('UserId', isEqualTo: userId)
          // .limit(1)
          .snapshots();
    } catch (e) {
      return null;
    }
  }
}
