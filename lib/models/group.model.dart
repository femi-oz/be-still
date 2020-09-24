import 'package:flutter/material.dart';

class GroupModel {
  final String groupId;
  final String name;
  final String status;
  final String description;
  final String organization;
  final String location;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupModel({
    @required this.groupId,
    @required this.name,
    @required this.status,
    @required this.description,
    @required this.organization,
    @required this.location,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });
}

class GroupInviteModel {
  final String groupInviteId;
  final String userId;
  final String groupId;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupInviteModel({
    @required this.groupInviteId,
    @required this.userId,
    @required this.groupId,
    @required this.status,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });
}

class GroupPrayerModel {
  final String groupId;
  final String prayerId;
  final String sequence;
  final String isFavourite;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupPrayerModel(
      {@required this.groupId,
      @required this.prayerId,
      @required this.sequence,
      @required this.isFavourite,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});
}

class GroupUserModel {
  final String groupId;
  final String userId;
  final String isAdmin;
  final String isModerator;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupUserModel(
      {@required this.groupId,
      @required this.userId,
      @required this.isAdmin,
      @required this.isModerator,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});
}
