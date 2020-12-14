import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SharingSettingsModel {
  final String id;
  final String userId;
  final bool enableSharingViaText;
  final bool enableSharingViaEmail;
  final String churchId;
  final String phone;
  final String status;
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
    @required this.phone,
    @required this.status,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  SharingSettingsModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        userId = snapshot.data()["UserId"],
        enableSharingViaEmail = snapshot.data()["EnableSharingViaEmail"],
        enableSharingViaText = snapshot.data()["EnableSharingViaText"],
        churchId = snapshot.data()["ChurchId"],
        phone = snapshot.data()["Phone"],
        status = snapshot.data()["Status"],
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
      'Phone': phone,
      'Status': status,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
