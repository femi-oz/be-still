import 'package:flutter/foundation.dart';

class GroupModel {
  final String groupId;
  final String userId;
  final String name;
  final String admin;
  final String city;
  final String state;
  final String church;
  final String description;
  final String type;
  final List<String> prayerList;
  final List<String> members;
  final List<String> moderators;
  final String organization;
  final String status;
  final String location;
  final String createdBy;

  const GroupModel({
    @required this.groupId,
    @required this.userId,
    @required this.name,
    @required this.admin,
    @required this.city,
    @required this.type,
    @required this.state,
    @required this.church,
    @required this.description,
    @required this.members,
    @required this.prayerList,
    @required this.moderators,
    @required this.organization,
    @required this.status,
    @required this.location,
    @required this.createdBy,
  });
}
