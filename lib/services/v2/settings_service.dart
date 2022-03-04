import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService {
  Future<void> updateSettings(
      {required DocumentReference userReference,
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
      required bool userId}) async {
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
        'modifiedBy': userId,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> updateSharingSettings(
      {required DocumentReference userReference,
      required bool enableSharingViaEmail,
      required bool enableSharingViaText,
      required bool userId}) async {
    try {
      await userReference.update({
        'enableSharingViaEmail': enableSharingViaEmail,
        'enableSharingViaText': enableSharingViaText,
        'modifiedBy': userId,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }
}
