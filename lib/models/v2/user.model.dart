import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/followed_prayer.model.dart';
import 'package:flutter/services.dart';

class UserDataModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  DateTime? dateOfBirth;
  List<DeviceModel>? devices;
  List<FollowedPrayer>? prayers;
  List<String>? groups;
  String? churchName;
  String? churchEmail;
  String? churchPhone;
  String? churchWebFormUrl;
  String? defaultSnoozeFrequency;
  int? defaultSnoozeDuration;
  String? archiveSortBy;
  int? archiveAutoDeleteMinutes;
  bool? doNotDisturb;
  bool? enableBackgroundMusic;
  bool? allowEmergencyCalls;
  bool? autoPlayMusic;
  bool? enableSharingViaText;
  bool? enableSharingViaEmail;
  bool? enablePushNotification;
  bool? enableNotificationsForAllGroups;
  bool? includeAnsweredPrayerAutoDelete;
  bool? consentViewed;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  DateTime? prayerModifiedDate;
  String? status;

  UserDataModel(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.dateOfBirth,
      this.devices,
      this.prayers,
      this.groups,
      this.churchName,
      this.churchEmail,
      this.churchPhone,
      this.churchWebFormUrl,
      this.defaultSnoozeFrequency,
      this.enablePushNotification,
      this.defaultSnoozeDuration,
      this.archiveSortBy,
      this.archiveAutoDeleteMinutes,
      this.doNotDisturb,
      this.enableBackgroundMusic,
      this.allowEmergencyCalls,
      this.autoPlayMusic,
      this.enableSharingViaText,
      this.enableSharingViaEmail,
      this.enableNotificationsForAllGroups,
      this.includeAnsweredPrayerAutoDelete,
      this.consentViewed,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.prayerModifiedDate,
      this.status});

  UserDataModel.fromJson(Map<String, dynamic> json, String did) {
    id = did;
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    dateOfBirth = json['dateOfBirth']?.toDate();
    if (json['devices'] != null) {
      devices = <DeviceModel>[];
      json['devices'].forEach((v) {
        devices!.add(new DeviceModel.fromJson(v));
      });
    }
    if (json['prayers'] != null) {
      prayers = <FollowedPrayer>[];
      json['prayers'].forEach((v) {
        prayers!.add(new FollowedPrayer.fromJson(v));
      });
    }
    if (json['groups'] != null) {
      groups = <String>[];
      json['groups'].forEach((v) {
        groups!.add(v);
      });
    }
    churchName = json['churchName'];
    churchEmail = json['churchEmail'];
    churchPhone = json['churchPhone'];
    churchWebFormUrl = json['churchWebFormUrl'];
    defaultSnoozeFrequency = json['defaultSnoozeFrequency'];
    enablePushNotification = json['enablePushNotification'] ?? true;
    defaultSnoozeDuration =
        json['defaultSnoozeDuration'] == 0 ? 1 : json['defaultSnoozeDuration'];
    archiveSortBy = json['archiveSortBy'];
    archiveAutoDeleteMinutes = json['archiveAutoDeleteMinutes'];
    doNotDisturb = json['doNotDisturb'];
    enableBackgroundMusic = json['enableBackgroundMusic'];
    allowEmergencyCalls = json['allowEmergencyCalls'];
    autoPlayMusic = json['autoPlayMusic'];
    enableSharingViaText = json['enableSharingViaText'];
    enableSharingViaEmail = json['enableSharingViaEmail'];
    enableNotificationsForAllGroups = json['enableNotificationsForAllGroups'];
    includeAnsweredPrayerAutoDelete = json['includeAnsweredPrayerAutoDelete'];
    consentViewed = json['consentViewed'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdDate = json['createdDate']?.toDate();
    modifiedDate = json['modifiedDate']?.toDate();
    prayerModifiedDate = json['prayerModifiedDate']?.toDate();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['dateOfBirth'] = this.dateOfBirth;
    if (this.devices != null) {
      data['devices'] = this.devices!.map((v) => v.toJson()).toList();
    }
    if (this.prayers != null) {
      data['prayers'] = this.prayers!.map((v) => v.toJson()).toList();
    }
    if (this.groups != null) {
      data['groups'] = this.groups!.map((v) => v).toList();
    }
    data['churchName'] = this.churchName;
    data['churchEmail'] = this.churchEmail;
    data['churchPhone'] = this.churchPhone;
    data['churchWebFormUrl'] = this.churchWebFormUrl;
    data['defaultSnoozeFrequency'] = this.defaultSnoozeFrequency;
    data['enablePushNotification'] = this.enablePushNotification;
    data['defaultSnoozeDuration'] = this.defaultSnoozeDuration;
    data['archiveSortBy'] = this.archiveSortBy;
    data['archiveAutoDeleteMinutes'] = this.archiveAutoDeleteMinutes;
    data['doNotDisturb'] = this.doNotDisturb;
    data['enableBackgroundMusic'] = this.enableBackgroundMusic;
    data['allowEmergencyCalls'] = this.allowEmergencyCalls;
    data['autoPlayMusic'] = this.autoPlayMusic;
    data['enableSharingViaText'] = this.enableSharingViaText;
    data['enableSharingViaEmail'] = this.enableSharingViaEmail;
    data['enableNotificationsForAllGroups'] =
        this.enableNotificationsForAllGroups;
    data['includeAnsweredPrayerAutoDelete'] =
        this.includeAnsweredPrayerAutoDelete;
    data['consentViewed'] = this.consentViewed;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['prayerModifiedDate'] = this.prayerModifiedDate;
    data['status'] = this.status;
    return data;
  }

  Map<String, dynamic> toJson2() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    return data;
  }
}

class UserVerify {
  final PlatformException? error;
  final bool needsVerification;
  UserVerify({required this.error, required this.needsVerification});
}
