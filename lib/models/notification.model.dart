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
  final String entityId;
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
    @required this.entityId,
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
        entityId = snapshot.data()['EntityId'],
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
      'EntityId': entityId,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class LocalNotificationModel {
  final String id;
  final String userId;
  final String entityId;
  final String description;
  final DateTime scheduledDate;
  final String frequency;
  final String title;
  final String fallbackRoute;
  final String payload;
  final String type;
  final String notificationText;
  final int localNotificationId;
  final String selectedDay;
  final String period;
  final String selectedHour;
  final String selectedMinute;

  const LocalNotificationModel({
    this.id,
    @required this.userId,
    @required this.entityId,
    @required this.payload,
    @required this.title,
    @required this.description,
    @required this.frequency,
    @required this.type,
    @required this.scheduledDate,
    @required this.fallbackRoute,
    @required this.notificationText,
    @required this.localNotificationId,
    @required this.selectedDay,
    @required this.period,
    @required this.selectedHour,
    @required this.selectedMinute,
  });
  LocalNotificationModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        userId = snapshot.data()['UserId'],
        entityId = snapshot.data()['EntityId'],
        description = snapshot.data()['Description'],
        scheduledDate = snapshot.data()['ScheduledDate'].toDate(),
        title = snapshot.data()['Title'],
        type = snapshot.data()['Type'],
        frequency = snapshot.data()['Frequency'],
        payload = snapshot.data()['Payload'],
        fallbackRoute = snapshot.data()['FallbackRoute'],
        notificationText = snapshot.data()['NotificationText'],
        localNotificationId = snapshot.data()['LocalNotificationId'],
        selectedDay = snapshot.data()['SelectedDay'] ?? '',
        period = snapshot.data()['Period'] ?? '',
        selectedHour = snapshot.data()['SelectedHour'] ?? '',
        selectedMinute = snapshot.data()['SelectedMinute'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'EntityId': entityId,
      'Title': title,
      'Description': description,
      'Frequency': frequency,
      'ScheduledDate': scheduledDate,
      'Type': type,
      'Payload': payload,
      'FallbackRoute': fallbackRoute,
      'NotificationText': notificationText,
      'LocalNotificationId': localNotificationId,
      'SelectedDay': selectedDay,
      'Period': period,
      'SelectedHour': selectedHour,
      'SelectedMinute': selectedMinute,
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
