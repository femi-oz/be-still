import 'package:be_still/models/group_settings_model.dart';
import 'package:be_still/models/prayer.model.dart';

class GroupModel {
  final String? id;
  final String? name;
  final String? status;
  final String? description;
  final String? organization;
  final String? location;
  final bool? isPrivate;
  final bool? isFeed;
  final String? createdBy;
  final DateTime? createdOn;
  final String? modifiedBy;
  final DateTime? modifiedOn;

  const GroupModel({
    this.id,
    this.name,
    this.status,
    this.description,
    this.organization,
    this.location,
    this.isPrivate,
    this.isFeed,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });

  GroupModel.defaultValue()
      : id = '',
        name = '',
        description = '',
        status = '',
        organization = '',
        location = '',
        isPrivate = false,
        isFeed = false,
        createdBy = '',
        createdOn = DateTime.now(),
        modifiedBy = '',
        modifiedOn = DateTime.now();

  GroupModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        name = snapshot['Name'] ?? 'N/A',
        description = snapshot['Description'] ?? 'N/A',
        status = snapshot['Status'] ?? 'N/A',
        organization = snapshot['Organization'] ?? 'N/A',
        location = snapshot['Location'] ?? '',
        isPrivate = snapshot['IsPrivate'] ?? false,
        isFeed = snapshot['IsFeed'] ?? false,
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate() ?? DateTime.now();

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
  final String? id;
  final String? groupId;
  final String? userId;
  final String? status;
  final String? createdBy;
  final DateTime? createdOn;

  const GroupRequestModel(
      {this.id,
      this.userId,
      this.groupId,
      this.status,
      this.createdBy,
      this.createdOn});
  GroupRequestModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        userId = snapshot['UserId'] ?? '',
        groupId = snapshot['GroupId'] ?? '',
        status = snapshot['Status'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now();
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
  final String? groupName;
  final String? groupId;
  final String? email;
  final String? sender;
  final String? senderId;
  final String? id;
  final String? createdBy;
  final DateTime? createdOn;
  final String? modifiedBy;
  final DateTime? modifiedOn;

  const GroupInviteModel({
    this.id,
    this.groupName,
    this.groupId,
    this.email,
    this.sender,
    this.senderId,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });

  GroupInviteModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        groupName = snapshot['GroupName'] ?? '',
        groupId = snapshot['GroupId'] ?? '',
        email = snapshot['Email'] ?? '',
        sender = snapshot['Sender'] ?? '',
        senderId = snapshot['SenderId'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate() ?? DateTime.now();

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
  String? id;
  String? groupId;
  String? prayerId;
  String? sequence;
  bool? isFavorite;
  String? status;
  String? createdBy;
  bool? isArchived;
  bool? isSnoozed;
  DateTime? snoozeEndDate;
  DateTime? archivedDate;
  int? snoozeDuration;
  String? snoozeFrequency;
  int? deleteStatus;
  DateTime? createdOn;
  String? modifiedBy;
  DateTime? modifiedOn;

  GroupPrayerModel(
      {this.id,
      this.groupId,
      this.prayerId,
      this.sequence,
      this.isFavorite,
      this.status,
      this.createdBy,
      this.createdOn,
      this.modifiedBy,
      this.modifiedOn,
      this.deleteStatus,
      this.isSnoozed,
      this.isArchived,
      this.snoozeEndDate,
      this.archivedDate,
      this.snoozeDuration,
      this.snoozeFrequency});

  factory GroupPrayerModel.defaultValue() => GroupPrayerModel(
      createdOn: DateTime.now(),
      modifiedOn: DateTime.now(),
      id: '',
      groupId: '',
      prayerId: '',
      sequence: '',
      isFavorite: false,
      status: '',
      deleteStatus: 0,
      isSnoozed: false,
      isArchived: false,
      snoozeEndDate: DateTime.now(),
      archivedDate: DateTime.now(),
      snoozeDuration: 0,
      snoozeFrequency: '',
      createdBy: '',
      modifiedBy: '');

  GroupPrayerModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        prayerId = snapshot['PrayerId'] ?? '',
        groupId = snapshot['GroupId'] ?? '',
        sequence = snapshot['Sequence'] ?? '',
        isFavorite = snapshot['IsFavourite'] ?? false,
        status = snapshot['Status'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate(),
        isSnoozed = snapshot['IsSnoozed'] ?? false,
        isArchived = snapshot['IsArchived'] ?? false,
        snoozeDuration = snapshot['SnoozeDuration'] ?? 0,
        snoozeFrequency = snapshot['SnoozeFrequency'] ?? '',
        snoozeEndDate = snapshot['SnoozeEndDate']?.toDate() ?? DateTime.now(),
        archivedDate = snapshot['ArchivedDate']?.toDate() ?? DateTime.now(),
        deleteStatus = snapshot['DeleteStatus'] ?? 0;

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
  String? id;
  String? groupId;
  String? userId;
  //  String? email;
  String? fullName;
  String? status;
  String? role;
  String? createdBy;
  DateTime? createdOn;
  String? modifiedBy;
  DateTime? modifiedOn;

  GroupUserModel({
    this.id,
    this.groupId,
    this.userId,
    this.fullName,
    this.status,
    this.role,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });

  factory GroupUserModel.defaultValue() => GroupUserModel(
        id: '',
        groupId: '',
        userId: '',
        role: '',
        status: '',
        fullName: '',
        createdOn: DateTime.now(),
        modifiedOn: DateTime.now(),
        createdBy: '',
        modifiedBy: '',
      );

  GroupUserModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        userId = snapshot['UserId'] ?? '',
        groupId = snapshot['GroupId'] ?? '',
        fullName = snapshot['FullName'] ?? '',
        // email = snapshot['Email'],
        status = snapshot['Status'] ?? '',
        role = snapshot['Role'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate() ?? DateTime.now();

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
  final String? id;
  final String? groupId;
  final String? userId;
  final String? status;
  final String? role;
  final String? createdBy;
  final DateTime? createdOn;
  final String? modifiedBy;
  final DateTime? modifiedOn;

  const UserGroupModel({
    this.id,
    this.groupId,
    this.userId,
    this.status,
    this.role,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });

  UserGroupModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        userId = snapshot['UserId'] ?? '',
        groupId = snapshot['GroupId'] ?? '',
        status = snapshot['Status'] ?? '',
        role = snapshot['Role'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate() ?? DateTime.now();

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
  final String? id;
  final String? userId;
  final String? groupId;

  const GroupUserReferenceModel({
    this.id,
    this.userId,
    this.groupId,
  });

  GroupUserReferenceModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        userId = snapshot['UserId'] ?? '',
        groupId = snapshot['GroupId'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'GroupId': groupId,
    };
  }
}

class CombineGroupUserStream {
  List<GroupUserModel>? groupUsers;
  final List<GroupRequestModel>? groupRequests;
  final GroupModel? group;
  final GroupSettings? groupSettings;

  CombineGroupUserStream({
    this.groupUsers = const [],
    this.group,
    this.groupRequests = const [],
    this.groupSettings,
  });
  factory CombineGroupUserStream.defaultValue() => CombineGroupUserStream(
      group: GroupModel.defaultValue(),
      groupRequests: [],
      groupUsers: [],
      groupSettings: GroupSettings.defaultValue());
}

class CombineGroupPrayerStream {
  // final String? id;
  GroupPrayerModel? groupPrayer;

  PrayerModel? prayer;

  List<PrayerTagModel>? tags;

  List<PrayerUpdateModel>? updates;

  CombineGroupPrayerStream({
    this.groupPrayer,
    this.prayer,
    this.tags,
    this.updates,
  });
  factory CombineGroupPrayerStream.defaultValue() => CombineGroupPrayerStream(
      groupPrayer: GroupPrayerModel.defaultValue(),
      prayer: PrayerModel.defaultValue(),
      tags: [],
      updates: []);
}

class CombineGroupInviteStream {
  final GroupModel group;
  final GroupInviteModel invite;

  CombineGroupInviteStream(this.invite, this.group);
}
