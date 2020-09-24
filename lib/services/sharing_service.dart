import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SharingSettingsService {
  final CollectionReference _sharingSettingsCollectionReference =
      Firestore.instance.collection("SharingSettings");

  setSharingSettings(
      UserModel userData, SharingSettingsModel sharingSettingsData) {
    SharingSettingsModel sharingSettings = SharingSettingsModel(
        userId: '',
        enableSharingViaEmail: 'false',
        enableSharingViaText: 'false',
        churchId: '',
        phone: '',
        status: 'Active',
        createdBy: '${userData.firstName}${userData.lastName}',
        createdOn: DateTime.now(),
        modifiedBy: '${userData.firstName}${userData.lastName}',
        modifiedOn: DateTime.now());
    return sharingSettings;
  }

  Future addSharingSetting(
      UserModel userData, SharingSettingsModel sharingSettingsData) async {
    try {
      //store share settings
      Firestore.instance.runTransaction((transaction) async {
        await _sharingSettingsCollectionReference
            .add(setSharingSettings(userData, sharingSettingsData).toJson());
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future getSharingSettings(String userId) async {
    try {
      final sharingSettingsRes = await _sharingSettingsCollectionReference
          .where('UserId', isEqualTo: userId)
          .limit(1)
          .getDocuments();
      return SharingSettingsModel.fromData(sharingSettingsRes.documents[0]);
    } catch (e) {
      return null;
    }
  }
}
