import 'package:flutter/material.dart';

class UserDeviceModel {
  final String userId;
  final String deviceId;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const UserDeviceModel(
      {@required this.userId,
      @required this.deviceId,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});
}
