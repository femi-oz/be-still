import 'package:flutter/foundation.dart';

class ReminderModel {
  final String reminderId;
  final String userId;
  final String frequency;
  final String token;
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String status;
  final String sort;
  final String createdBy;

  const ReminderModel(
      {@required this.reminderId,
      @required this.userId,
      @required this.frequency,
      @required this.token,
      @required this.startDate,
      @required this.endDate,
      @required this.title,
      @required this.status,
      @required this.sort,
      @required this.createdBy});
}
