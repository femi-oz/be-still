import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PrayerSettingsService {
  final CollectionReference _prayerSettingsCollectionReference =
      Firestore.instance.collection("PrayerSettings");

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
      print(e.toString());
      return null;
    }
  }

  Stream<QuerySnapshot> getPrayerSettings(String userId) {
    try {
      return _prayerSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .limit(1)
          .snapshots();
    } catch (e) {
      return null;
    }
  }
}
