import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SharingSettingsService {
  final CollectionReference _sharingSettingsCollectionReference =
      Firestore.instance.collection("SharingSettings");

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
