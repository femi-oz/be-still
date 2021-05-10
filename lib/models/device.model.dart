import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeviceModel {
  final String id;
  final String deviceId;
  final String name;
  final String status;
  final String model;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const DeviceModel({
    this.id,
    @required this.deviceId,
    @required this.name,
    @required this.status,
    @required this.model,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  DeviceModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        deviceId = snapshot.data()['DeviceId'],
        name = snapshot.data()['Name'],
        model = snapshot.data()['Model'],
        status = snapshot.data()['Status'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'DeviceId': deviceId,
      'Name': name,
      'Status': status,
      'Model': model,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
