import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String message;
  final String messageType;
  final String sender;
  final String userId;
  final String createdBy;
  final DateTime createdOn;
  final String extra1;
  final String extra2;
  final String extra3;

  const NotificationModel({
    this.id,
    @required this.message,
    @required this.messageType,
    @required this.sender,
    @required this.userId,
    @required this.createdBy,
    @required this.createdOn,
    @required this.extra1,
    @required this.extra2,
    @required this.extra3,
  });
  NotificationModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        message = snapshot.data()['Message'],
        messageType = snapshot.data()['MessageType'],
        sender = snapshot.data()['Sender'],
        userId = snapshot.data()['UserId'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = DateTime.fromMillisecondsSinceEpoch(
            snapshot.data()['CreatedOn'] * 1000),
        extra1 = snapshot.data()['Extra1'],
        extra2 = snapshot.data()['Extra2'],
        extra3 = snapshot.data()['Extra3'];

  Map<String, dynamic> toJson() {
    return {
      'Message': message,
      'MessageType': messageType,
      'Sender': sender,
      'UserId': userId,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'Extra1': extra1,
      'Extra2': extra2,
      'Extra3': extra3,
    };
  }
}

class LocalNotificationModel {
  final String id;
  final String deviceId;
  final String entityId;
  final int localNotificationId;

  const LocalNotificationModel({
    this.id,
    @required this.deviceId,
    @required this.entityId,
    @required this.localNotificationId,
  });
  LocalNotificationModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        deviceId = snapshot.data()['DeviceId'],
        entityId = snapshot.data()['EntityId'],
        localNotificationId = snapshot.data()['LocalNotificationId'];

  Map<String, dynamic> toJson() {
    return {
      'DeviceId': deviceId,
      'EntityId': entityId,
      'LocalNotificationId': localNotificationId,
    };
  }
}
