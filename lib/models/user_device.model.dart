import 'package:be_still/models/device.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDeviceModel {
  final String id;
  final String deviceId;
  final String userId;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const UserDeviceModel({
    this.id,
    @required this.deviceId,
    @required this.userId,
    @required this.status,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  UserDeviceModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        deviceId = snapshot['DeviceId'],
        userId = snapshot['UserId'],
        status = snapshot['Status'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'DeviceId': deviceId,
      'UserId': userId,
      'Status': status,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class CombineDeviceStream {
  final UserDeviceModel userDevice;
  final DeviceModel device;

  CombineDeviceStream(this.userDevice, this.device);
}
