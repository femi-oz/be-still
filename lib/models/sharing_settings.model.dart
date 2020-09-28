import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SharingSettingsModel {
  final String userId;
  final String enableSharingViaText;
  final String enableSharingViaEmail;
  final String churchId;
  final String phone;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const SharingSettingsModel(
      {@required this.userId,
      @required this.enableSharingViaEmail,
      @required this.enableSharingViaText,
      @required this.churchId,
      @required this.phone,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});

  SharingSettingsModel.fromData(DocumentSnapshot snapShot)
      : userId = snapShot.documentID,
        enableSharingViaEmail = snapShot.data["EnableSharingViaEmail"],
        enableSharingViaText = snapShot.data["EnableSharingViaText"],
        churchId = snapShot.data["ChurchId"],
        phone = snapShot.data["Phone"],
        status = snapShot.data["Status"],
        createdBy = snapShot.data["CreatedBy"],
        createdOn = snapShot.data["CreatedOn"],
        modifiedBy = snapShot.data["ModifiedBy"],
        modifiedOn = snapShot.data["ModifiedOn"];

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