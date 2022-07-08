class ReminderModel {
  final String? reminderId;
  final String? userId;
  final String? frequency;
  final String? token;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? title;
  final String? status;
  final String? sort;
  final String? createdBy;

  const ReminderModel(
      {this.reminderId,
      this.userId,
      this.frequency,
      this.token,
      this.startDate,
      this.endDate,
      this.title,
      this.status,
      this.sort,
      this.createdBy});
}
