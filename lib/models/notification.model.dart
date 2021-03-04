import 'package:be_still/enums/notification_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PushNotificationModel {
  final String id;
  final String title;
  final List<dynamic> tokens;
  final String messageType;
  final String message;
  final String sender;
  final String recieverId;
  final String status;
  final int isSent;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const PushNotificationModel({
    this.id,
    @required this.title,
    @required this.messageType,
    @required this.tokens,
    @required this.message,
    @required this.status,
    @required this.sender,
    @required this.recieverId,
    @required this.isSent,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });
  PushNotificationModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        title = snapshot.data()['Title'],
        tokens = snapshot.data()['Tokens'],
        message = snapshot.data()['Message'],
        messageType = snapshot.data()['MessageType'] ?? NotificationType.prayer,
        isSent = snapshot.data()['IsSent'],
        status = snapshot.data()['Status'],
        recieverId = snapshot.data()['RecieverId'],
        sender = snapshot.data()['Sender'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Message': message,
      'MessageType': messageType,
      'Tokens': tokens,
      'Sender': sender,
      'IsSent': isSent,
      'Status': status,
      'RecieverId': recieverId,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
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

class MessageModel {
  final String id;
  final String title;
  final String message;
  final String subject;
  final String phoneNumber;
  final String email;
  final String sender;
  final String country;
  final String receiver;
  final String senderId;
  final int isSent;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const MessageModel({
    this.id,
    @required this.title,
    @required this.message,
    @required this.sender,
    @required this.subject,
    @required this.receiver,
    @required this.country,
    @required this.phoneNumber,
    @required this.email,
    @required this.senderId,
    @required this.isSent,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });
  MessageModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        title = snapshot.data()['Title'],
        message = snapshot.data()['Message'],
        isSent = snapshot.data()['IsSent'],
        sender = snapshot.data()['Sender'],
        country = snapshot.data()['Country'],
        subject = snapshot.data()['Subject'],
        receiver = snapshot.data()['Receiver'],
        phoneNumber = snapshot.data()['PhoneNumber'],
        email = snapshot.data()['Email'],
        senderId = snapshot.data()['SenderId'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Message': message,
      'SenderId': senderId,
      'Sender': sender,
      'Subject': subject,
      'Country': country,
      'PhoneNumber': phoneNumber,
      'Receiver': receiver,
      'Email': email,
      'IsSent': isSent,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
