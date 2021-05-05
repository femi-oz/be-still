import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrayerSettingsModel {
  final String id;
  final String userId;
  final String frequency;
  // final DateTime date;
  final String day;
  final String time;
  final bool doNotDisturb;
  final bool allowEmergencyCalls;
  final bool enableBackgroundMusic;
  final bool autoPlayMusic;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const PrayerSettingsModel({
    this.id,
    @required this.userId,
    @required this.frequency,
    // @required this.date,
    @required this.time,
    @required this.day,
    @required this.doNotDisturb,
    @required this.allowEmergencyCalls,
    @required this.autoPlayMusic,
    @required this.enableBackgroundMusic,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  PrayerSettingsModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        userId = snapshot["UserId"],
        frequency = snapshot["Frequency"],
        // date = snapshot["Date"].toDate(),
        day = snapshot["Day"],
        time = snapshot["Time"],
        doNotDisturb = snapshot['DoNotDisturb'],
        allowEmergencyCalls = snapshot['AllowEmergencyCalls'],
        autoPlayMusic = snapshot['AutoPlayMusic'],
        enableBackgroundMusic = snapshot['EnableBackgroundMusic'],
        createdBy = snapshot["CreatedBy"],
        createdOn = snapshot["CreatedOn"].toDate(),
        modifiedBy = snapshot["ModifiedBy"],
        modifiedOn = snapshot["ModifiedOn"].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Frequency': frequency,
      // 'Date': date,
      'Day': day,
      'Time': time,
      'DoNotDisturb': doNotDisturb,
      'AllowEmergencyCalls': allowEmergencyCalls,
      'EnableBackgroundMusic': enableBackgroundMusic,
      'AutoPlayMusic': autoPlayMusic,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn
    };
  }
}
