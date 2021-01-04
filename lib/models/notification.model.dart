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

  const NotificationModel({
    this.id,
    @required this.message,
    @required this.messageType,
    @required this.sender,
    @required this.userId,
    @required this.createdBy,
    @required this.createdOn,
  });

  NotificationModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        message = snapshot.data()['Message'],
        messageType = snapshot.data()['MessageType'],
        sender = snapshot.data()['Sender'],
        userId = snapshot.data()['UserId'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = DateTime.fromMillisecondsSinceEpoch(
            snapshot.data()['CreatedOn'] * 1000);

  Map<String, dynamic> toJson() {
    return {
      'Message': message,
      'MessageType': messageType,
      'Sender': sender,
      'UserId': userId,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
    };
  }
}
