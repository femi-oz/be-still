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
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.appearance,
    required this.defaultSortBy,
    required this.defaultSnoozeFrequency,
    required this.defaultSnoozeDuration,
    required this.pauseInterval,
    required this.archiveSortBy,
    required this.archiveAutoDelete,
    required this.archiveAutoDeleteMins,
    required this.includeAnsweredPrayerAutoDelete,
    required this.allowPushNotification,
    required this.allowTextNotification,
    required this.allowAlexaReadPrayer,
    required this.emailUpdateFrequencyMins,
    required this.emailUpdateNotification,
    required this.notifyMeSomeonePostOnGroup,
    required this.notifyMeSomeoneSharePrayerWithMe,
    required this.allowPrayerTimeNotification,
    required this.syncAlexa,
    required this.status,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
  });

  factory SettingsModel.defaultValue() => SettingsModel(
      id: '',
      userId: '',
      deviceId: '',
      appearance: '',
      defaultSortBy: '',
      defaultSnoozeFrequency: '',
      defaultSnoozeDuration: 0,
      pauseInterval: '',
      archiveSortBy: '',
      archiveAutoDelete: '',
      archiveAutoDeleteMins: 0,
      includeAnsweredPrayerAutoDelete: false,
      allowPushNotification: false,
      allowTextNotification: false,
      allowAlexaReadPrayer: false,
      emailUpdateFrequencyMins: 0,
      emailUpdateNotification: false,
      notifyMeSomeonePostOnGroup: false,
      notifyMeSomeoneSharePrayerWithMe: false,
      allowPrayerTimeNotification: false,
      syncAlexa: false,
      status: '',
      createdBy: '',
      createdOn: DateTime.now(),
      modifiedBy: '',
      modifiedOn: DateTime.now());

  factory SettingsModel.fromData(Map<String, dynamic> data, String did) {
    final String id = did;
    final String userId = data['UserId'] ?? '';
    final String deviceId = data['DeviceId'] ?? '';
    final String appearance = data['Appearance'] ?? '';
    final String pauseInterval = data['PauseInterval'] ?? '';
    final String defaultSortBy = data['DefaultSortBy'] ?? '';
    final String defaultSnoozeFrequency = data['DefaultSnoozeFrequency'] ?? '';
    final String archiveSortBy = data['ArchiveSortBy'] ?? '';
    final String archiveAutoDelete = data['ArchiveAutoDelete'] ?? '';
    final String modifiedBy = data['ModifiedBy'] ?? '';
    final String status = data['Status'] ?? '';
    final String createdBy = data['CreatedBy'] ?? '';
    final bool includeAnsweredPrayerAutoDelete =
        data['IncludeAnsweredPrayerAutoDelete'] ?? false;
    final bool allowPushNotification = data['AllowPushNotification'] ?? false;
    final bool allowTextNotification = data['AllowTextNotification'] ?? false;
    final bool allowAlexaReadPrayer = data['AllowAlexaReadPrayer'] ?? false;
    final bool emailUpdateNotification =
        data['EmailUpdateNotification'] ?? false;
    final bool notifyMeSomeonePostOnGroup =
        data['NotifyMeSomeonePostOnGroup'] ?? false;
    final bool notifyMeSomeoneSharePrayerWithMe =
        data['NotifyMeSomeoneSharePrayerWithMe'] ?? false;
    final bool syncAlexa = data['SyncAlexa'] ?? false;
    final bool allowPrayerTimeNotification =
        data['AllowPrayerTimeNotification'] ?? false;
    final int emailUpdateFrequencyMins = data['EmailUpdateFrequencySecs'] ?? 0;
    final int archiveAutoDeleteMins = data['ArchiveAutoDeleteMins'] ?? 30;
    final int defaultSnoozeDuration = data['DefaultSnoozeDurationValue'] ?? 15;
    final DateTime createdOn = data['CreatedOn'].toDate() ?? DateTime.now();
    final DateTime modifiedOn = data['ModifiedOn'].toDate() ?? DateTime.now();
    return SettingsModel(
        id: id,
        userId: userId,
        deviceId: deviceId,
        appearance: appearance,
        defaultSortBy: defaultSortBy,
        defaultSnoozeFrequency: defaultSnoozeFrequency,
        defaultSnoozeDuration: defaultSnoozeDuration,
        pauseInterval: pauseInterval,
        archiveSortBy: archiveSortBy,
        archiveAutoDelete: archiveAutoDelete,
        archiveAutoDeleteMins: archiveAutoDeleteMins,
        includeAnsweredPrayerAutoDelete: includeAnsweredPrayerAutoDelete,
        allowPushNotification: allowPushNotification,
        allowTextNotification: allowTextNotification,
        allowAlexaReadPrayer: allowAlexaReadPrayer,
        emailUpdateFrequencyMins: emailUpdateFrequencyMins,
        emailUpdateNotification: emailUpdateNotification,
        notifyMeSomeonePostOnGroup: notifyMeSomeonePostOnGroup,
        notifyMeSomeoneSharePrayerWithMe: notifyMeSomeoneSharePrayerWithMe,
        allowPrayerTimeNotification: allowPrayerTimeNotification,
        syncAlexa: syncAlexa,
        status: status,
        createdBy: createdBy,
        createdOn: createdOn,
        modifiedBy: modifiedBy,
        modifiedOn: modifiedOn);
  }

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
