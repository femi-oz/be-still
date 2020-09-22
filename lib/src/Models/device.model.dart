import 'package:flutter/foundation.dart';

class DeviceModel {
  final String id;
  final String deviceId;
  final String name;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const DeviceModel(
      {@required this.id,
      @required this.deviceId,
      @required this.name,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});
}
