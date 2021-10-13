import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsModel {
  final String id;
  final String userId;
  final String deviceId;
  final String appearance;
  final String defaultSortBy;
  final String defaultSnoozeFrequency;
  final int defaultSnoozeDuration;
  final String archiveSortBy;
  final String archiveAutoDelete;
  final int archiveAutoDeleteMins;
  final String pauseInterval;
  final bool includeAnsweredPrayerAutoDelete;
  final bool allowPushNotification;
  final bool allowTextNotification;
  final bool allowAlexaReadPrayer;
  final bool emailUpdateNotification;
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
    @required this.defaultSnoozeFrequency,
    @required this.defaultSnoozeDuration,
    @required this.pauseInterval,
    @required this.archiveSortBy,
    @required this.archiveAutoDelete,
    @required this.archiveAutoDeleteMins,
    @required this.includeAnsweredPrayerAutoDelete,
    @required this.allowPushNotification,
    @required this.allowTextNotification,
    @required this.allowAlexaReadPrayer,
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

  SettingsModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()['UserId'],
        deviceId = snapshot.data()['DeviceId'],
        appearance = snapshot.data()['Appearance'],
        pauseInterval = snapshot.data()['PauseInterval'],
        defaultSortBy = snapshot.data()['DefaultSortBy'],
        defaultSnoozeFrequency = snapshot.data()['DefaultSnoozeFrequency'],
        defaultSnoozeDuration =
            snapshot.data()['DefaultSnoozeDurationValue'] ?? 15,
        archiveSortBy = snapshot.data()['ArchiveSortBy'],
        archiveAutoDelete = snapshot.data()['ArchiveAutoDelete'],
        archiveAutoDeleteMins = snapshot.data()['ArchiveAutoDeleteMins'] ?? 30,
        includeAnsweredPrayerAutoDelete =
            snapshot.data()['IncludeAnsweredPrayerAutoDelete'],
        allowPushNotification = snapshot.data()['AllowPushNotification'],
        allowTextNotification = snapshot.data()['AllowTextNotification'],
        allowAlexaReadPrayer = snapshot.data()['AllowAlexaReadPrayer'],
        emailUpdateFrequencyMins = snapshot.data()['EmailUpdateFrequencySecs'],
        emailUpdateNotification = snapshot.data()['EmailUpdateNotification'],
        notifyMeSomeonePostOnGroup =
            snapshot.data()['NotifyMeSomeonePostOnGroup'],
        notifyMeSomeoneSharePrayerWithMe =
            snapshot.data()['NotifyMeSomeoneSharePrayerWithMe'],
        syncAlexa = snapshot.data()['SyncAlexa'],
        allowPrayerTimeNotification =
            snapshot.data()['AllowPrayerTimeNotification'],
        status = snapshot.data()['Status'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'DeviceId': deviceId,
      'Appearance': appearance,
      'DefaultSortBy': defaultSortBy,
      'PauseInterval': pauseInterval,
      'DefaultSnoozeFrequency': defaultSnoozeFrequency,
      'DefaultSnoozeDurationValue': defaultSnoozeDuration,
      'ArchiveSortBy': archiveSortBy,
      'ArchiveAutoDelete': archiveAutoDelete,
      'ArchiveAutoDeleteMins': archiveAutoDeleteMins,
      'IncludeAnsweredPrayerAutoDelete': includeAnsweredPrayerAutoDelete,
      'AllowAlexaReadPrayer': allowAlexaReadPrayer,
      'AllowPushNotification': allowPushNotification,
      'AllowTextNotification': allowTextNotification,
      'EmailUpdateNotification': emailUpdateNotification,
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
