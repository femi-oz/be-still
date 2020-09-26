import 'package:be_still/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:be_still/models/settings.model.dart';

class SettingsService {
  final CollectionReference _settingsCollectionReference =
      Firestore.instance.collection("Settings");

  setSettings(UserModel userData, SettingsModel settingsData) {
    SettingsModel settings = SettingsModel(
      userId: '',
      deviceId: '',
      appearance: '',
      defaultSortBy: '',
      defaultSnoozeDuration: '',
      archiveAutoDelete: '',
      includeAnsweredPrayerAutoDelete: '',
      allowPushNotification: '',
      allowTextNotification: '',
      emailUpdateFrequency: '',
      emailUpdateNotification: '',
      notifyMeSomeonePostOnGroup: '',
      notifyMeSomeoneSharePrayerWithMe: '',
      allowPrayerTimeNotification: '',
      syncAlexa: '',
      status: '',
      createdBy: '${userData.firstName}${userData.lastName}',
      createdOn: DateTime.now(),
      modifiedBy: '${userData.firstName}${userData.lastName}',
      modifiedOn: DateTime.now(),
    );

    return settings;
  }

  Future addSettings(
    UserModel userData,
    SettingsModel settingsData,
  ) async {
    try {
      //store settings
      Firestore.instance.runTransaction((transaction) async {
        await _settingsCollectionReference
            .add(setSettings(userData, settingsData).toJson());
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future getSettingsData(String userId) async {
    try {
      final settingRes = await _settingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .limit(1)
          .getDocuments();
      return SettingsModel.fromData(settingRes.documents[0]);
    } catch (e) {
      return null;
    }
  }
}
