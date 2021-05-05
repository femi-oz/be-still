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

  SharingSettingsModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()["UserId"],
        enableSharingViaEmail = snapshot.data()["EnableSharingViaEmail"],
        enableSharingViaText = snapshot.data()["EnableSharingViaText"],
        churchId = snapshot.data()["ChurchId"],
        churchName = snapshot.data()["ChurchName"] ?? '',
        churchPhone = snapshot.data()["ChurchPhone"] ?? '',
        churchEmail = snapshot.data()["ChurchEmail"] ?? '',
        webFormlink = snapshot.data()["WebFormLink"] ?? '',
        createdBy = snapshot.data()["CreatedBy"],
        createdOn = snapshot.data()["CreatedOn"].toDate(),
        modifiedBy = snapshot.data()["ModifiedBy"],
        modifiedOn = snapshot.data()["ModifiedOn"].toDate();

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
