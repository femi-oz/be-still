import 'package:flutter/foundation.dart';

class UserPrayerModel {
  final String groupId;
  final String prayerId;
  final String userId;
  final String sequence;
  final bool isFavorite;
  final String type;
  final String title;
  final String description;
  final String isAnswer;
  final String sort;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const UserPrayerModel(
      {@required this.groupId,
      @required this.prayerId,
      @required this.userId,
      @required this.sequence,
      @required this.isAnswer,
      @required this.isFavorite,
      @required this.title,
      @required this.type,
      @required this.description,
      @required this.sort,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});
}
