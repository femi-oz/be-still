import 'package:be_still/models/models/device.model.dart';

class UserDataModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  DateTime? dateOfBirth;
  List<DeviceModel>? devices;
  String? churchName;
  String? churchEmail;
  String? churchPhone;
  String? churchWebFormUrl;
  String? defaultSnoozeFrequency;
  String? archiveSortBy;
  int? archiveAutoDeleteMinutes;
  bool? doNotDisturb;
  bool? enableBackgroundMusic;
  bool? allowEmergencyCalls;
  bool? autoPlayMusic;
  bool? enableSharingViaText;
  bool? enableSharingViaEmail;
  bool? includeAnsweredPrayerAutoDelete;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? status;

  UserDataModel(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.dateOfBirth,
      this.devices,
      this.churchName,
      this.churchEmail,
      this.churchPhone,
      this.churchWebFormUrl,
      this.defaultSnoozeFrequency,
      this.archiveSortBy,
      this.archiveAutoDeleteMinutes,
      this.doNotDisturb,
      this.enableBackgroundMusic,
      this.allowEmergencyCalls,
      this.autoPlayMusic,
      this.enableSharingViaText,
      this.enableSharingViaEmail,
      this.includeAnsweredPrayerAutoDelete,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  UserDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    dateOfBirth = json['dateOfBirth'];
    if (json['devices'] != null) {
      devices = <DeviceModel>[];
      json['devices'].forEach((v) {
        devices!.add(new DeviceModel.fromJson(v));
      });
    }
    churchName = json['churchName'];
    churchEmail = json['churchEmail'];
    churchPhone = json['churchPhone'];
    churchWebFormUrl = json['churchWebFormUrl'];
    defaultSnoozeFrequency = json['defaultSnoozeFrequency'];
    archiveSortBy = json['archiveSortBy'];
    archiveAutoDeleteMinutes = json['archiveAutoDeleteMinutes'];
    doNotDisturb = json['doNotDisturb'];
    enableBackgroundMusic = json['enableBackgroundMusic'];
    allowEmergencyCalls = json['allowEmergencyCalls'];
    autoPlayMusic = json['autoPlayMusic'];
    enableSharingViaText = json['enableSharingViaText'];
    enableSharingViaEmail = json['enableSharingViaEmail'];
    includeAnsweredPrayerAutoDelete = json['includeAnsweredPrayerAutoDelete'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdDate = json['createdDate'];
    modifiedDate = json['modifiedDate'];
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
    data['churchName'] = this.churchName;
    data['churchEmail'] = this.churchEmail;
    data['churchPhone'] = this.churchPhone;
    data['churchWebFormUrl'] = this.churchWebFormUrl;
    data['defaultSnoozeFrequency'] = this.defaultSnoozeFrequency;
    data['archiveSortBy'] = this.archiveSortBy;
    data['archiveAutoDeleteMinutes'] = this.archiveAutoDeleteMinutes;
    data['doNotDisturb'] = this.doNotDisturb;
    data['enableBackgroundMusic'] = this.enableBackgroundMusic;
    data['allowEmergencyCalls'] = this.allowEmergencyCalls;
    data['autoPlayMusic'] = this.autoPlayMusic;
    data['enableSharingViaText'] = this.enableSharingViaText;
    data['enableSharingViaEmail'] = this.enableSharingViaEmail;
    data['includeAnsweredPrayerAutoDelete'] =
        this.includeAnsweredPrayerAutoDelete;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
