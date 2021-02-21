import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String message;
  final String messageType;
  final String sender;
  final String status;
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
    @required this.status,
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
        status = snapshot.data()['Status'],
        createdBy = snapshot.data()['CreatedBy'],
        // createdOn = DateTime.fromMillisecondsSinceEpoch(
        //     snapshot.data()['CreatedOn'] * 1000),
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        extra1 = snapshot.data()['Extra1'],
        extra2 = snapshot.data()['Extra2'],
        extra3 = snapshot.data()['Extra3'];

  Map<String, dynamic> toJson() {
    return {
      'Message': message,
      'MessageType': messageType,
      'Sender': sender,
      'Status': status,
      'UserId': userId,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'Extra1': extra1,
      'Extra2': extra2,
      'Extra3': extra3,
    };
  }
}

class PushNotificationModel {
  final String id;
  final String title;
  final List<String> tokens;
  final String message;
  final String sender;

  const PushNotificationModel({
    this.id,
    @required this.title,
    @required this.tokens,
    @required this.message,
    @required this.sender,
  });
  PushNotificationModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        title = snapshot.data()['title'],
        tokens = snapshot.data()['tokens'],
        message = snapshot.data()['message'],
        sender = snapshot.data()['sender'];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'tokens': tokens,
      'sender': sender,
    };
  }
}

class LocalNotificationModel {
  final String id;
  final String deviceId;
  final String entityId;
  final String notificationText;
  final int localNotificationId;

  const LocalNotificationModel({
    this.id,
    @required this.deviceId,
    @required this.entityId,
    @required this.notificationText,
    @required this.localNotificationId,
  });
  LocalNotificationModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        deviceId = snapshot.data()['DeviceId'],
        entityId = snapshot.data()['EntityId'],
        notificationText = snapshot.data()['NotificationText'],
        localNotificationId = snapshot.data()['LocalNotificationId'];

  Map<String, dynamic> toJson() {
    return {
      'DeviceId': deviceId,
      'EntityId': entityId,
      'NotificationText': notificationText,
      'LocalNotificationId': localNotificationId,
    };
  }
}
