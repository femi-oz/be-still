import 'package:cloud_firestore/cloud_firestore.dart';
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

  SettingsModel.fromData(DocumentSnapshot snapShot)
      : userId = snapShot.documentID,
        deviceId = snapShot.data['DeviceId'],
        appearance = snapShot.data['Appearance'],
        defaultSortBy = snapShot.data['DefaultSortBy'],
        defaultSnoozeDuration = snapShot.data['DefaultSnoozeDuration'],
        archiveAutoDelete = snapShot.data['ArchiveAutoDelete'],
        includeAnsweredPrayerAutoDelete =
            snapShot.data['IncludeAnsweredPrayerAutoDelete'],
        allowPushNotification = snapShot.data['AllowPushNotification'],
        allowTextNotification = snapShot.data['AllowTextNotification'],
        emailUpdateFrequency = snapShot.data['EmailUpdateFrequency'],
        emailUpdateNotification = snapShot.data['EmailUpdateNotification'],
        notifyMeSomeonePostOnGroup =
            snapShot.data['NotifyMeSomeonePostOnGroup'],
        notifyMeSomeoneSharePrayerWithMe =
            snapShot.data['NotifyMeSomeoneSharePrayerWithMe'],
        allowPrayerTimeNotification =
            snapShot.data['AllowPrayerTimeNotification'],
        syncAlexa = snapShot.data['SyncAlexa'],
        status = snapShot.data['Status'],
        createdBy = snapShot.data['CreatedBy'],
        createdOn = snapShot.data['CreatedOn'],
        modifiedBy = snapShot.data['ModifiedBy'],
        modifiedOn = snapShot.data['ModifiedOn'];

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'DeviceId': deviceId,
      'Appearance': appearance,
      'DefaultSortBy': defaultSortBy,
      'DefaultSnoozeDuration': defaultSnoozeDuration,
      'ArchiveAutoDelete': archiveAutoDelete,
      'IncludeAnsweredPrayerAutoDelete': includeAnsweredPrayerAutoDelete,
      'AllowPushNotification': allowPushNotification,
      'AllowTextNotification': allowTextNotification,
      'EmailUpdateNotification': emailUpdateNotification,
      'EmailUpdateFrequency': emailUpdateFrequency,
      'NotifyMeSomeonePostOnGroup': notifyMeSomeonePostOnGroup,
      'NotifyMeSomeoneSharePrayerWithMe': notifyMeSomeoneSharePrayerWithMe,
      'AllowPrayerTimeNotification': allowPrayerTimeNotification,
      'SyncAlexa': syncAlexa,
      'Status': status,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
