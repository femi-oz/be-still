import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
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
        title = snapshot['Title'],
        tokens = snapshot['Tokens'],
        message = snapshot['Message'],
        messageType = snapshot['MessageType'] ?? NotificationType.prayer,
        isSent = snapshot['IsSent'],
        status = snapshot['Status'],
        recieverId = snapshot['RecieverId'],
        entityId = snapshot['EntityId'],
        sender = snapshot['Sender'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

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
    @required this.notificationText,
    @required this.localNotificationId,
    @required this.selectedDay,
    @required this.period,
    @required this.selectedHour,
    @required this.selectedMinute,
  });
  LocalNotificationModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        userId = snapshot['UserId'],
        entityId = snapshot['EntityId'],
        description = snapshot['Description'],
        scheduledDate = snapshot['ScheduledDate'].toDate(),
        title = snapshot['Title'],
        type = snapshot['Type'],
        frequency = snapshot['Frequency'],
        payload = snapshot['Payload'],
        notificationText = snapshot['NotificationText'],
        localNotificationId = snapshot['LocalNotificationId'],
        selectedDay = snapshot['SelectedDay'] != ''
            ? snapshot['SelectedDay']
            : DaysOfWeek.wed,
        period = snapshot['Period'] != '' ? snapshot['Period'] : 'pm',
        selectedHour =
            snapshot['SelectedHour'] != '' ? snapshot['SelectedHour'] : '06',
        selectedMinute = snapshot['SelectedMinute'] != ''
            ? snapshot['SelectedMinute']
            : '40';

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
        title = snapshot['Title'],
        message = snapshot['Message'],
        isSent = snapshot['IsSent'],
        sender = snapshot['Sender'],
        country = snapshot['Country'],
        subject = snapshot['Subject'],
        receiver = snapshot['Receiver'],
        phoneNumber = snapshot['PhoneNumber'],
        email = snapshot['Email'],
        senderId = snapshot['SenderId'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

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

class NotificationMessage {
  final String entityId;
  final String type;

  const NotificationMessage({
    @required this.entityId,
    @required this.type,
  });

  NotificationMessage.fromData(Map<String, dynamic> data)
      : entityId = data['entityId'],
        type = data['type'];

  Map<String, dynamic> toJson() {
    return {
      'entityId': entityId,
      'type': type,
    };
  }
}
