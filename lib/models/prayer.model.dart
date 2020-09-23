import 'package:flutter/material.dart';

class PrayerModel {
  final String id;
  final String title;
  final String content;
  final String user;
  final List<String> tags;
  final String status; //active, snoozed, archived
  // final bool isAnswered;
  final bool isAddedFromGroup;
  final bool hasReminder;
  // final bool isGroupAdmin;
  final DateTime date;
  // final String time;
  final String reminder;
  final List<PrayerUpdateModel> updates;

  const PrayerModel({
    @required this.id,
    @required this.title,
    @required this.content,
    @required this.user,
    @required this.status,
    // @required this.isAnswered,
    @required this.hasReminder,
    // @required this.isGroupAdmin,
    @required this.isAddedFromGroup,
    // @required this.date,
    this.date,
    // @required this.time,
    @required this.tags,
    @required this.reminder,
    @required this.updates,
  });
}

class PrayerUpdateModel {
  final String id;
  final DateTime date;
  final String content;
  final List<String> tags;

  const PrayerUpdateModel({
    @required this.id,
    @required this.date,
    @required this.content,
    @required this.tags,
  });
}
