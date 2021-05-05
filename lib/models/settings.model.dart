import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsModel {
  final String id;
  final String userId;
  final String deviceId;
  final String appearance;
  final String defaultSortBy;
  final String defaultSnoozeDuration;
  final int defaultSnoozeDurationMins;
  final String archiveSortBy;
  final String archiveAutoDelete;
  final int archiveAutoDeleteMins;
  final String pauseInterval;
  final bool includeAnsweredPrayerAutoDelete;
  final bool allowPushNotification;
  final bool allowTextNotification;
  final bool allowAlexaReadPrayer;
  final bool emailUpdateNotification;
  // final String emailUpdateFrequency;
  final int emailUpdateFrequencyMins;
  final bool notifyMeSomeoneSharePrayerWithMe;
  final bool notifyMeSomeonePostOnGroup;
  final bool allowPrayerTimeNotification;
  final bool syncAlexa;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const SettingsModel({
    this.id,
    @required this.userId,
    @required this.deviceId,
    @required this.appearance,
    @required this.defaultSortBy,
    @required this.defaultSnoozeDuration,
    @required this.defaultSnoozeDurationMins,
    @required this.pauseInterval,
    @required this.archiveSortBy,
    @required this.archiveAutoDelete,
    @required this.archiveAutoDeleteMins,
    @required this.includeAnsweredPrayerAutoDelete,
    @required this.allowPushNotification,
    @required this.allowTextNotification,
    @required this.allowAlexaReadPrayer,
    // @required this.emailUpdateFrequency,
    @required this.emailUpdateFrequencyMins,
    @required this.emailUpdateNotification,
    @required this.notifyMeSomeonePostOnGroup,
    @required this.notifyMeSomeoneSharePrayerWithMe,
    @required this.allowPrayerTimeNotification,
    @required this.syncAlexa,
    @required this.status,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  SettingsModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        userId = snapshot['UserId'],
        deviceId = snapshot['DeviceId'],
        appearance = snapshot['Appearance'],
        pauseInterval = snapshot['PauseInterval'],
        defaultSortBy = snapshot['DefaultSortBy'],
        defaultSnoozeDuration = snapshot['DefaultSnoozeDuration'],
        defaultSnoozeDurationMins = snapshot['DefaultSnoozeDurationMins'] ?? 30,
        archiveSortBy = snapshot['ArchiveSortBy'],
        archiveAutoDelete = snapshot['ArchiveAutoDelete'],
        archiveAutoDeleteMins = snapshot['ArchiveAutoDeleteMins'] ?? 30,
        includeAnsweredPrayerAutoDelete =
            snapshot['IncludeAnsweredPrayerAutoDelete'],
        allowPushNotification = snapshot['AllowPushNotification'],
        allowTextNotification = snapshot['AllowTextNotification'],
        allowAlexaReadPrayer = snapshot['AllowAlexaReadPrayer'],
        // emailUpdateFrequency = snapshot['EmailUpdateFrequency'],
        emailUpdateFrequencyMins = snapshot['EmailUpdateFrequencySecs'],
        emailUpdateNotification = snapshot['EmailUpdateNotification'],
        notifyMeSomeonePostOnGroup = snapshot['NotifyMeSomeonePostOnGroup'],
        notifyMeSomeoneSharePrayerWithMe =
            snapshot['NotifyMeSomeoneSharePrayerWithMe'],
        syncAlexa = snapshot['SyncAlexa'],
        allowPrayerTimeNotification = snapshot['AllowPrayerTimeNotification'],
        status = snapshot['Status'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'DeviceId': deviceId,
      'Appearance': appearance,
      'DefaultSortBy': defaultSortBy,
      'PauseInterval': pauseInterval,
      'DefaultSnoozeDuration': defaultSnoozeDuration,
      'DefaultSnoozeDurationMins': defaultSnoozeDurationMins,
      'ArchiveSortBy': archiveSortBy,
      'ArchiveAutoDelete': archiveAutoDelete,
      'ArchiveAutoDeleteMins': archiveAutoDeleteMins,
      'IncludeAnsweredPrayerAutoDelete': includeAnsweredPrayerAutoDelete,
      'AllowAlexaReadPrayer': allowAlexaReadPrayer,
      'AllowPushNotification': allowPushNotification,
      'AllowTextNotification': allowTextNotification,
      'EmailUpdateNotification': emailUpdateNotification,
      // 'EmailUpdateFrequency': emailUpdateFrequency,
      'EmailUpdateFrequencySecs': emailUpdateFrequencyMins,
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
