import 'package:flutter/material.dart';

class GroupPrayerModel {
  final String groupId;
  final String prayerId;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupPrayerModel(
      {@required this.groupId,
      @required this.prayerId,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});
}
