import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SharingSettingsModel {
  final String id;
  final String userId;
  final bool enableSharingViaText;
  final bool enableSharingViaEmail;
  final String churchId;
  final String churchName;
  final String churchPhone;
  final String churchEmail;
  final String webFormlink;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const SharingSettingsModel({
    this.id,
    @required this.userId,
    @required this.enableSharingViaEmail,
    @required this.enableSharingViaText,
    @required this.churchId,
    @required this.churchName,
    @required this.churchPhone,
    @required this.churchEmail,
    @required this.webFormlink,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  SharingSettingsModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        userId = snapshot["UserId"],
        enableSharingViaEmail = snapshot["EnableSharingViaEmail"],
        enableSharingViaText = snapshot["EnableSharingViaText"],
        churchId = snapshot["ChurchId"],
        churchName = snapshot["ChurchName"] ?? '',
        churchPhone = snapshot["ChurchPhone"] ?? '',
        churchEmail = snapshot["ChurchEmail"] ?? '',
        webFormlink = snapshot["WebFormLink"] ?? '',
        createdBy = snapshot["CreatedBy"],
        createdOn = snapshot["CreatedOn"].toDate(),
        modifiedBy = snapshot["ModifiedBy"],
        modifiedOn = snapshot["ModifiedOn"].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'EnableSharingViaEmail': enableSharingViaEmail,
      'EnableSharingViaText': enableSharingViaText,
      'ChurchId': churchId,
      'ChurchName': churchName,
      'ChurchPhone': churchPhone,
      'ChurchEmail': churchEmail,
      'WebFormLink': webFormlink,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
