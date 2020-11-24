import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsModel {
  final String userId;
  final String deviceId;
  final String appearance;
  final String defaultSortBy;
  final String defaultSnoozeDuration;
  final String archiveSortBy;
  final String archiveAutoDelete;
  final bool includeAnsweredPrayerAutoDelete;
  final bool allowPushNotification;
  final bool allowTextNotification;
  final bool allowAlexaReadPrayer;
  final bool emailUpdateNotification;
  final bool emailUpdateFrequency;
  final bool notifyMeSomeoneSharePrayerWithMe;
  final bool notifyMeSomeonePostOnGroup;
  final bool allowPrayerTimeNotification;
  final bool syncAlexa;
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
      @required this.archiveSortBy,
      @required this.archiveAutoDelete,
      @required this.includeAnsweredPrayerAutoDelete,
      @required this.allowPushNotification,
      @required this.allowTextNotification,
      @required this.allowAlexaReadPrayer,
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
        archiveSortBy = snapShot.data['ArchiveSortBy'],
        archiveAutoDelete = snapShot.data['ArchiveAutoDelete'],
        includeAnsweredPrayerAutoDelete =
            snapShot.data['IncludeAnsweredPrayerAutoDelete'],
        allowPushNotification = snapShot.data['AllowPushNotification'],
        allowTextNotification = snapShot.data['AllowTextNotification'],
        allowAlexaReadPrayer = snapShot.data['AllowAlexaReadPrayer'],
        emailUpdateFrequency = snapShot.data['EmailUpdateFrequency'],
        emailUpdateNotification = snapShot.data['EmailUpdateNotification'],
        notifyMeSomeonePostOnGroup =
            snapShot.data['NotifyMeSomeonePostOnGroup'],
        notifyMeSomeoneSharePrayerWithMe =
            snapShot.data['NotifyMeSomeoneSharePrayerWithMe'],
        syncAlexa = snapShot.data['SyncAlexa'],
        allowPrayerTimeNotification =
            snapShot.data['AllowPrayerTimeNotification'],
        status = snapShot.data['Status'],
        createdBy = snapShot.data['CreatedBy'],
        createdOn = snapShot.data['CreatedOn'].toDate(),
        modifiedBy = snapShot.data['ModifiedBy'],
        modifiedOn = snapShot.data['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'DeviceId': deviceId,
      'Appearance': appearance,
      'DefaultSortBy': defaultSortBy,
      'DefaultSnoozeDuration': defaultSnoozeDuration,
      'ArchiveSortBy': archiveSortBy,
      'ArchiveAutoDelete': archiveAutoDelete,
      'IncludeAnsweredPrayerAutoDelete': includeAnsweredPrayerAutoDelete,
      'AllowAlexaReadPrayer': allowAlexaReadPrayer,
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

class CombineSettingsStream {
  final SettingsModel settings;
  final SharingSettingsModel sharingSettings;
  final PrayerSettingsModel prayerSettings;

  CombineSettingsStream(
      this.settings, this.sharingSettings, this.prayerSettings);
}
