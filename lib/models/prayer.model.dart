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
  final bool isInappropriate;
  final bool hideFromMe;
  final bool hideFromAllMembers;
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
    @required this.isInappropriate,
    @required this.hideFromMe,
    @required this.hideFromAllMembers,
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
        isInappropriate = snapshot.data['IsInappropriate'],
        hideFromMe = snapshot.data['HideFromMe'],
        hideFromAllMembers = snapshot.data['HideFromAllMembers'],
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
      'IsInappropriate': isInappropriate,
      'HideFromMe': hideFromMe,
      'HideFromAllMembers': hideFromAllMembers,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class PrayerDisableModel {
  final String prayerId;
  final String userId;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const PrayerDisableModel(
      {@required this.prayerId,
      @required this.userId,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});

  PrayerDisableModel.fromData(DocumentSnapshot snapshot)
      : prayerId = snapshot.documentID,
        userId = snapshot.data['UserId'],
        createdBy = snapshot.data['CreatedBy'],
        createdOn = snapshot.data['CreatedOn'].toDate(),
        modifiedBy = snapshot.data['ModifiedBy'],
        modifiedOn = snapshot.data['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class PrayerUpdateModel {
  final String id;
  final String prayerId;
  final String userId;
  final String title;
  final String description;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const PrayerUpdateModel({
    this.id,
    @required this.prayerId,
    @required this.userId,
    @required this.title,
    @required this.description,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  PrayerUpdateModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.documentID,
        prayerId = snapshot.documentID,
        userId = snapshot.data['UserId'],
        title = snapshot.data['Title'],
        description = snapshot.data['Description'],
        createdBy = snapshot.data['CreatedBy'],
        createdOn = snapshot.data['CreatedOn'].toDate(),
        modifiedBy = snapshot.data['ModifiedBy'],
        modifiedOn = snapshot.data['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'Title': title,
      'Description': description,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class HiddenPrayerModel {
  final String id;
  final String prayerId;
  final String userId;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const HiddenPrayerModel({
    this.id,
    @required this.prayerId,
    @required this.userId,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  HiddenPrayerModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.documentID,
        prayerId = snapshot.data['PrayerId'],
        userId = snapshot.data['UserId'],
        createdBy = snapshot.data['CreatedBy'],
        createdOn = snapshot.data['CreatedOn'].toDate(),
        modifiedBy = snapshot.data['ModifiedBy'],
        modifiedOn = snapshot.data['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
