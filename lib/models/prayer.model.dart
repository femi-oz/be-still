import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrayerModel {
  final String id;
  final String groupId;
  final String userId;
  final String type;
  final String title;
  final String status;
  final String description;
  final bool isAnswer;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const PrayerModel({
    this.id,
    @required this.groupId,
    @required this.userId,
    @required this.type,
    @required this.title,
    @required this.status,
    @required this.description,
    @required this.isAnswer,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  PrayerModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.documentID,
        groupId = snapshot.data['GroupId'],
        userId = snapshot.data['UserId'],
        type = snapshot.data['Type'],
        title = snapshot.data['Title'],
        status = snapshot.data['Status'],
        description = snapshot.data['Description'],
        isAnswer = snapshot.data['IsAnswer'],
        createdBy = snapshot.data['CreatedBy'],
        createdOn = snapshot.data['CreatedOn'].toDate(),
        modifiedBy = snapshot.data['ModifiedBy'],
        modifiedOn = snapshot.data['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'GroupId': groupId,
      'UserId': userId,
      'Type': type,
      'Title': title,
      'Status': status,
      'Description': description,
      'IsAnswer': isAnswer,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}