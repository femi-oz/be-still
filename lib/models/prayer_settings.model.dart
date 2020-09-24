import 'package:flutter/material.dart';

class PrayerSettingsModel {
  final String userId;
  final String frequency;
  final DateTime date;
  final DateTime time;
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
}
