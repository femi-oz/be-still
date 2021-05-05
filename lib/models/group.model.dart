import 'package:be_still/models/prayer.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupModel {
  final String id;
  final String name;
  final String status;
  final String email;
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
    @required this.email,
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
      : id = snapshot.id,
        name = snapshot['Name'],
        description = snapshot['Description'],
        status = snapshot['Status'],
        email = snapshot['Email'],
        organization = snapshot['Organization'],
        location = snapshot['Location'],
        isPrivate = snapshot['IsPrivate'],
        isFeed = snapshot['IsFeed'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Description': description,
      'Status': status,
      'Email': email,
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
  final String groupName;
  final String groupId;
  final String email;
  final String sender;
  final String senderId;
  final String id;
  // final String userId;
  // final String groupId;
  // final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupInviteModel({
    this.id,
    // @required this.userId,
    // @required this.groupId,
    // @required this.status,
    @required this.groupName,
    @required this.groupId,
    @required this.email,
    @required this.sender,
    @required this.senderId,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  GroupInviteModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        groupName = snapshot['GroupName'],
        groupId = snapshot['GroupId'],
        email = snapshot['Email'],
        sender = snapshot['Sender'],
        senderId = snapshot['SenderId'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'GroupName': groupName,
      'GroupId': groupId,
      'Email': email,
      'Sender': sender,
      'SenderId': senderId,
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
      : id = snapshot.id,
        prayerId = snapshot['PrayerId'],
        groupId = snapshot['GroupId'],
        sequence = snapshot['Sequence'],
        isFavorite = snapshot['IsFavourite'],
        status = snapshot['Status'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

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
      : id = snapshot.id,
        userId = snapshot['UserId'],
        groupId = snapshot['GroupId'],
        isAdmin = snapshot['IsAdmin'],
        isModerator = snapshot['IsModerator'],
        fullName = snapshot['FullName'],
        status = snapshot['Status'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

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
