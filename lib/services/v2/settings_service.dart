import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsServiceV2 {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> updateSettings({
    required DocumentReference userReference,
    required String firstName,
    required String lastName,
    required String email,
    required String churchEmail,
    required String churchName,
    required String churchPhone,
    required String churchWebFormUrl,
    required bool allowEmergencyCalls,
    required int archiveAutoDeleteMinutes,
    required String defaultSnoozeFrequency,
    required bool includeAnsweredPrayerAutoDelete,
    required String archiveSortBy,
    required bool autoPlayMusic,
    required bool enableBackgroundMusic,
    required bool doNotDisturb,
  }) async {
    try {
      await userReference.update({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'churchEmail': churchEmail,
        'churchName': churchName,
        'churchPhone': churchPhone,
        'churchWebFormUrl': churchWebFormUrl,
        'allowEmergencyCalls': allowEmergencyCalls,
        'archiveAutoDeleteMinutes': archiveAutoDeleteMinutes,
        'defaultSnoozeFrequency': defaultSnoozeFrequency,
        'includeAnsweredPrayerAutoDelete': includeAnsweredPrayerAutoDelete,
        'archiveSortBy': archiveSortBy,
        'autoPlayMusic': autoPlayMusic,
        'enableBackgroundMusic': enableBackgroundMusic,
        'doNotDisturb': doNotDisturb,
        'modifiedBy': _firebaseAuth.currentUser?.uid,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> updateSharingSettings(
      {required DocumentReference userReference,
      required bool enableSharingViaEmail,
      required bool enableSharingViaText}) async {
    try {
      userReference.update({
        'enableSharingViaEmail': enableSharingViaEmail,
        'enableSharingViaText': enableSharingViaText,
        'modifiedBy': _firebaseAuth.currentUser?.uid,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }
}
