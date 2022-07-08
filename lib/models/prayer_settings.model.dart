class PrayerSettingsModel {
  final String? id;
  final String? userId;
  final String? frequency;
  final String? day;
  final String? time;
  final bool? doNotDisturb;
  final bool? allowEmergencyCalls;
  final bool? enableBackgroundMusic;
  final bool? autoPlayMusic;
  final String? createdBy;
  final DateTime? createdOn;
  final String? modifiedBy;
  final DateTime? modifiedOn;

  const PrayerSettingsModel({
    this.id,
    this.userId,
    this.frequency,
    this.time,
    this.day,
    this.doNotDisturb,
    this.allowEmergencyCalls,
    this.autoPlayMusic,
    this.enableBackgroundMusic,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });

  factory PrayerSettingsModel.defaultValue() => PrayerSettingsModel(
      id: '',
      userId: '',
      frequency: '',
      time: '',
      day: '',
      doNotDisturb: false,
      allowEmergencyCalls: false,
      autoPlayMusic: false,
      enableBackgroundMusic: false,
      createdBy: '',
      createdOn: DateTime.now(),
      modifiedBy: '',
      modifiedOn: DateTime.now());

  factory PrayerSettingsModel.fromData(
      Map<String, dynamic> snapshot, String did) {
    final String id = did;
    final String userId = snapshot["UserId"] ?? '';
    final String frequency = snapshot["Frequency"] ?? '';
    final String day = snapshot["Day"] ?? '';
    final String time = snapshot["Time"] ?? '';
    final bool doNotDisturb = snapshot['DoNotDisturb'] ?? false;
    final bool allowEmergencyCalls = snapshot['AllowEmergencyCalls'] ?? false;
    final bool autoPlayMusic = snapshot['AutoPlayMusic'] ?? false;
    final bool enableBackgroundMusic =
        snapshot['EnableBackgroundMusic'] ?? false;
    final String createdBy = snapshot["CreatedBy"] ?? '';
    final DateTime createdOn =
        snapshot["CreatedOn"]?.toDate() ?? DateTime.now();
    final String modifiedBy = snapshot["ModifiedBy"] ?? '';
    final DateTime modifiedOn =
        snapshot["ModifiedOn"]?.toDate() ?? DateTime.now();
    return PrayerSettingsModel(
        id: id,
        userId: userId,
        frequency: frequency,
        time: time,
        day: day,
        doNotDisturb: doNotDisturb,
        allowEmergencyCalls: allowEmergencyCalls,
        autoPlayMusic: autoPlayMusic,
        enableBackgroundMusic: enableBackgroundMusic,
        createdBy: createdBy,
        createdOn: createdOn,
        modifiedBy: modifiedBy,
        modifiedOn: modifiedOn);
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Frequency': frequency,
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
