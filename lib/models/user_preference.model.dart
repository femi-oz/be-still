class UserPreferenceModel {
  final String userId;
  final String prayerTime;
  final String backgroundMusic;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const UserPreferenceModel(
      {required this.userId,
      required this.prayerTime,
      required this.backgroundMusic,
      required this.createdBy,
      required this.createdOn,
      required this.modifiedBy,
      required this.modifiedOn});
}
