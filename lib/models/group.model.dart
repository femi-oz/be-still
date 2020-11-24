import 'package:be_still/models/prayer.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupModel {
  final String id;
  final String name;
  final String status;
  final String description;
  final String organization;
  final String location;
  final bool isPrivate;
  final bool isFeed;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupModel({
    this.id,
    @required this.name,
    @required this.status,
    @required this.description,
    @required this.organization,
    @required this.location,
    @required this.isPrivate,
    @required this.isFeed,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  GroupModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.documentID,
        name = snapshot.data['Name'],
        description = snapshot.data['Description'],
        status = snapshot.data['Status'],
        organization = snapshot.data['Organization'],
        location = snapshot.data['Location'],
        isPrivate = snapshot.data['IsPrivate'],
        isFeed = snapshot.data['IsFeed'],
        createdBy = snapshot.data['CreatedBy'],
        createdOn = snapshot.data['CreatedOn'].toDate(),
        modifiedBy = snapshot.data['ModifiedBy'],
        modifiedOn = snapshot.data['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Description': description,
      'Status': status,
      'Organization': organization,
      'Location': location,
      'IsPrivate': isPrivate,
      'IsFeed': isFeed,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class GroupInviteModel {
  final String id;
  final String userId;
  final String groupId;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupInviteModel({
    this.id,
    @required this.userId,
    @required this.groupId,
    @required this.status,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  GroupInviteModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.documentID,
        userId = snapshot.data['UserId'],
        groupId = snapshot.data['GroupId'],
        status = snapshot.data['Status'],
        createdBy = snapshot.data['CreatedBy'],
        createdOn = snapshot.data['CreatedOn'].toDate(),
        modifiedBy = snapshot.data['ModifiedBy'],
        modifiedOn = snapshot.data['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'GroupId': groupId,
      'Status': status,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class GroupPrayerModel {
  final id;
  final String groupId;
  final String prayerId;
  final String sequence;
  final bool isFavorite;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupPrayerModel({
    this.id,
    @required this.groupId,
    @required this.prayerId,
    @required this.sequence,
    @required this.isFavorite,
    @required this.status,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  GroupPrayerModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.documentID,
        prayerId = snapshot.data['PrayerId'],
        groupId = snapshot.data['GroupId'],
        sequence = snapshot.data['Sequence'],
        isFavorite = snapshot.data['IsFavourite'],
        status = snapshot.data['Status'],
        createdBy = snapshot.data['CreatedBy'],
        createdOn = snapshot.data['CreatedOn'].toDate(),
        modifiedBy = snapshot.data['ModifiedBy'],
        modifiedOn = snapshot.data['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'GroupId': groupId,
      'Sequence': sequence,
      'IsFavourite': isFavorite,
      'Status': status,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class GroupUserModel {
  final String id;
  final String groupId;
  final String userId;
  final bool isAdmin;
  final bool isModerator;
  final String fullName;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupUserModel({
    this.id,
    @required this.groupId,
    @required this.userId,
    @required this.isAdmin,
    @required this.isModerator,
    @required this.fullName,
    @required this.status,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  GroupUserModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.documentID,
        userId = snapshot.data['UserId'],
        groupId = snapshot.data['GroupId'],
        isAdmin = snapshot.data['IsAdmin'],
        isModerator = snapshot.data['IsModerator'],
        fullName = snapshot.data['FullName'],
        status = snapshot.data['Status'],
        createdBy = snapshot.data['CreatedBy'],
        createdOn = snapshot.data['CreatedOn'].toDate(),
        modifiedBy = snapshot.data['ModifiedBy'],
        modifiedOn = snapshot.data['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'GroupId': groupId,
      'IsAdmin': isAdmin,
      'IsModerator': isModerator,
      'FullName': fullName,
      'Status': status,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class CombineGroupUserStream {
  final List<GroupUserModel> groupUsers;
  final GroupModel group;

  CombineGroupUserStream(this.groupUsers, this.group);
}

class CombineGroupPrayerStream {
  final PrayerModel prayer;
  final GroupPrayerModel groupPrayer;

  CombineGroupPrayerStream(this.prayer, this.groupPrayer);
}

class CombineGroupInviteStream {
  final GroupModel group;
  final GroupInviteModel invite;

  CombineGroupInviteStream(this.invite, this.group);
}
