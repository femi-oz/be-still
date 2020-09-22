import 'package:flutter/foundation.dart';

class GroupModel {
  final String id;
  final String name;
  final String admin;
  final List<String> prayerList;
  final List<String> members;
  final List<String> moderators;
  final String description;
  final String organization;
  final String status;
  final String location;
  final String createdBy;

  const GroupModel(
      {@required this.id,
      @required this.name,
      @required this.admin,
      @required this.members,
      @required this.prayerList,
      @required this.moderators,
      @required this.description,
      @required this.organization,
      @required this.status,
      @required this.location,
      @required this.createdBy});
}
