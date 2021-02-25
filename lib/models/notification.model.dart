import 'package:be_still/enums/status.dart';
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
        status = snapshot.data()['Status'] ?? Status.active,
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
