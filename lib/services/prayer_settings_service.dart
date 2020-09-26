import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerSettingsService {
  final CollectionReference _prayerSettingsCollectionReference =
      Firestore.instance.collection("PrayerSettings");

  setPrayerSettings(
      UserModel userData, PrayerSettingsModel prayerSettingsData) {
    PrayerSettingsModel prayerSettings = PrayerSettingsModel(
        userId: '',
        frequency: '0',
        date: DateTime.now(),
        time: Timestamp.now(),
        createdBy: '${userData.firstName}${userData.lastName}',
        createdOn: DateTime.now(),
        modifiedBy: '${userData.firstName}${userData.lastName}',
        modifiedOn: DateTime.now());
    return prayerSettings;
  }

  Future addPrayerSettings(
      UserModel userData, PrayerSettingsModel prayerSettingsData) async {
    try {
      //store prayer settings
      Firestore.instance.runTransaction((transaction) async {
        await _prayerSettingsCollectionReference
            .add(setPrayerSettings(userData, prayerSettingsData).toJson());
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future getPrayerSettings(String userId) async {
    try {
      final prayerSettingsRes = await _prayerSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .limit(1)
          .getDocuments();
      return PrayerSettingsModel.fromData(prayerSettingsRes.documents[0]);
    } catch (e) {
      return null;
    }
  }
}
