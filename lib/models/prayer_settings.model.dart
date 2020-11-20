import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrayerSettingsModel {
  final String userId;
  final int frequency;
  final DateTime date;
  final Timestamp time;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const PrayerSettingsModel(
      {@required this.userId,
      @required this.frequency,
      @required this.date,
      @required this.time,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});

  PrayerSettingsModel.fromData(DocumentSnapshot snapshot)
      : userId = snapshot.documentID,
        frequency = snapshot.data["Frequency"],
        date = snapshot.data["Date"].toDate(),
        time = snapshot.data["Time"],
        createdBy = snapshot.data["CreatedBy"],
        createdOn = snapshot.data["CreatedOn"].toDate(),
        modifiedBy = snapshot.data["ModifiedBy"],
        modifiedOn = snapshot.data["ModifiedOn"].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Frequency': frequency,
      'Date': date,
      'Time': time,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn
    };
  }
}
