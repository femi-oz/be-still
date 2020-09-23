import 'package:flutter/material.dart';

class SettingsModel {
  final String userId;
  final String deviceId;
  final String appearance;
  final String defaultSortBy;
  final String defaultSnoozeDuration;
  final String archiveAutoDelete;
  final String includeAnsweredPrayerAutoDelete;
  final String allowPushNotification;
  final String allowTextNotification;
  final String emailUpdateNotification;
  final String emailUpdateFrequency;
  final String notifyMeSomeoneSharePrayerWithMe;
  final String notifyMeSomeonePostOnGroup;
  final String allowPrayerTimeNotification;
  final String syncAlexa;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const SettingsModel(
      {@required this.userId,
      @required this.deviceId,
      @required this.appearance,
      @required this.defaultSortBy,
      @required this.defaultSnoozeDuration,
      @required this.archiveAutoDelete,
      @required this.includeAnsweredPrayerAutoDelete,
      @required this.allowPushNotification,
      @required this.allowTextNotification,
      @required this.emailUpdateFrequency,
      @required this.emailUpdateNotification,
      @required this.notifyMeSomeonePostOnGroup,
      @required this.notifyMeSomeoneSharePrayerWithMe,
      @required this.allowPrayerTimeNotification,
      @required this.syncAlexa,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});
}
