import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/models/device.model.dart';
import 'package:be_still/models/models/user.model.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference<Map<String, dynamic>> _userDataCollectionReference =
      FirebaseFirestore.instance.collection("users_v2");

  Stream<List<UserDataModel>> getAllUsers() {
    try {
      return _userDataCollectionReference.snapshots().map((event) =>
          event.docs.map((e) => UserDataModel.fromJson(e.data())).toList());
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
    }
  }

  Future<void> createUser({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    required String token,
    required String deviceId,
  }) async {
    try {
      final doc = UserDataModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        dateOfBirth: dateOfBirth,
        allowEmergencyCalls: true,
        archiveAutoDeleteMinutes: 0,
        defaultSnoozeFrequency: IntervalRange.thirtyMinutes,
        includeAnsweredPrayerAutoDelete: false,
        archiveSortBy: SortType.date,
        autoPlayMusic: true,
        churchEmail: '',
        churchName: '',
        churchPhone: '',
        churchWebFormUrl: '',
        devices: [
          DeviceModel(id: deviceId, token: token)
        ], // update token on login where deviceId == deviceId
        enableBackgroundMusic: true,
        enableSharingViaEmail: true,
        enableSharingViaText: true,
        doNotDisturb: true,
        createdBy: uid,
        modifiedBy: uid,
        createdDate: DateTime.now(), modifiedDate: DateTime.now(),
        status: Status.active,
      ).toJson();
      _userDataCollectionReference.doc(uid).set(doc);
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

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

  Future<void> deletePushToken(
      {required DocumentReference userReference,
      required String deviceId,
      required String userId,
      required List<DeviceModel> devices}) async {
    try {
      devices.removeWhere((element) => element.id == deviceId);
      userReference.update({
        'devices': devices,
        'modifiedBy': userId,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }
}
