class UserPreferenceModel {
  final String? userId;
  final String? prayerTime;
  final String? backgroundMusic;
  final String? createdBy;
  final DateTime? createdOn;
  final String? modifiedBy;
  final DateTime? modifiedOn;

  const UserPreferenceModel(
      {this.userId,
      this.prayerTime,
      this.backgroundMusic,
      this.createdBy,
      this.createdOn,
      this.modifiedBy,
      this.modifiedOn});
}
