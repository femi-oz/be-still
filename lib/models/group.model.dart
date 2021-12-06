import 'package:be_still/models/group_settings_model.dart';
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

  GroupModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        name = snapshot.data()['Name'],
        description = snapshot.data()['Description'] ?? 'N/A',
        status = snapshot.data()['Status'] ?? 'N/A',
        organization = snapshot.data()['Organization'] ?? 'N/A',
        location = snapshot.data()['Location'],
        isPrivate = snapshot.data()['IsPrivate'],
        isFeed = snapshot.data()['IsFeed'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
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

class GroupRequestModel {
  final String id;
  final String groupId;
  final String userId;
  final String status;
  final String createdBy;
  final DateTime createdOn;

  const GroupRequestModel(
      {this.id,
      @required this.userId,
      @required this.groupId,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn});
  GroupRequestModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()['UserId'],
        groupId = snapshot.data()['GroupId'],
        status = snapshot.data()['Status'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate();
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'UserId': userId,
      'GroupId': groupId,
      'Status': status,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn
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
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupInviteModel({
    this.id,
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

  GroupInviteModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        groupName = snapshot.data()['GroupName'],
        groupId = snapshot.data()['GroupId'],
        email = snapshot.data()['Email'],
        sender = snapshot.data()['Sender'],
        senderId = snapshot.data()['SenderId'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

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
  final bool isArchived;
  final bool isSnoozed;
  final DateTime snoozeEndDate;
  final DateTime archivedDate;
  final int snoozeDuration;
  final String snoozeFrequency;
  final int deleteStatus;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupPrayerModel(
      {this.id,
      @required this.groupId,
      @required this.prayerId,
      @required this.sequence,
      @required this.isFavorite,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn,
      @required this.deleteStatus,
      @required this.isSnoozed,
      @required this.isArchived,
      @required this.snoozeEndDate,
      @required this.archivedDate,
      @required this.snoozeDuration,
      @required this.snoozeFrequency});

  GroupPrayerModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        prayerId = snapshot.data()['PrayerId'],
        groupId = snapshot.data()['GroupId'],
        sequence = snapshot.data()['Sequence'],
        isFavorite = snapshot.data()['IsFavourite'],
        status = snapshot.data()['Status'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate(),
        isSnoozed = snapshot.data()['IsSnoozed'] ?? false,
        isArchived = snapshot.data()['IsArchived'] ?? false,
        snoozeDuration = snapshot.data()['SnoozeDuration'] ?? 0,
        snoozeFrequency = snapshot.data()['SnoozeFrequency'] ?? '',
        snoozeEndDate =
            snapshot.data()['SnoozeEndDate']?.toDate() ?? DateTime.now(),
        archivedDate =
            snapshot.data()['ArchivedDate']?.toDate() ?? DateTime.now(),
        deleteStatus = snapshot.data()['DeleteStatus'] ?? 0;

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
      'DeleteStatus': deleteStatus,
      'IsSnoozed': isSnoozed,
      'IsArchived': isArchived,
      'SnoozeFrequency': snoozeFrequency,
      'SnoozeDuration': snoozeDuration,
      'SnoozeEndDate': snoozeEndDate,
      'ArchivedDate': archivedDate,
    };
  }
}

class GroupUserRole {
  static String admin = 'admin';
  static String moderator = 'moderator';
  static String member = 'member';
}

class GroupUserModel {
  final String id;
  final String groupId;
  final String userId;
  // final String email;
  final String fullName;
  final String status;
  final String role;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupUserModel({
    this.id,
    @required this.groupId,
    @required this.userId,
    @required this.fullName,
    // @required this.email,
    @required this.status,
    @required this.role,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  GroupUserModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()['UserId'],
        groupId = snapshot.data()['GroupId'],
        fullName = snapshot.data()['FullName'] ?? '',
        // email = snapshot.data()['Email'],
        status = snapshot.data()['Status'],
        role = snapshot.data()['Role'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'GroupId': groupId,
      'FullName': fullName,
      // 'Email': email,
      'Status': status,
      'Role': role,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class UserGroupModel {
  final String id;
  final String groupId;
  final String userId;
  final String status;
  final String role;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const UserGroupModel({
    this.id,
    @required this.groupId,
    @required this.userId,
    @required this.status,
    @required this.role,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  UserGroupModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()['UserId'],
        groupId = snapshot.data()['GroupId'],
        status = snapshot.data()['Status'],
        role = snapshot.data()['Role'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'GroupId': groupId,
      // 'FullName': fullName,
      'Status': status,
      'Role': role,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class GroupUserReferenceModel {
  final String id;
  final String userId;
  final String groupId;

  const GroupUserReferenceModel(
      {this.id, @required this.userId, @required this.groupId});

  GroupUserReferenceModel.fromData(
      DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()['UserId'],
        groupId = snapshot.data()['GroupId'];

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'GroupId': groupId,
    };
  }
}

class CombineGroupUserStream {
  List<GroupUserModel> groupUsers;
  final List<GroupRequestModel> groupRequests;
  final GroupModel group;
  final GroupSettings groupSettings;
  // final UserModel admin;

  CombineGroupUserStream({
    @required this.groupUsers,
    @required this.group,
    @required this.groupRequests,
    @required this.groupSettings,
  }
      // this.admin,
      );
}

class CombineGroupPrayerStream {
  final String id;
  final GroupPrayerModel groupPrayer;
  @required
  final PrayerModel prayer;
  @required
  final List<PrayerTagModel> tags;
  @required
  final List<PrayerUpdateModel> updates;

  CombineGroupPrayerStream({
    this.id,
    this.groupPrayer,
    this.prayer,
    this.tags,
    this.updates,
  });
}

class CombineGroupInviteStream {
  final GroupModel group;
  final GroupInviteModel invite;

  CombineGroupInviteStream(this.invite, this.group);
}
