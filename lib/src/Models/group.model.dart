import 'package:flutter/foundation.dart';

class GroupModel {
  final String id;
  final String name;
  final String admin;
  final List<String> prayerList;
  final List<String> members;
  final List<String> moderators;

  const GroupModel({
    @required this.id,
    @required this.name,
    @required this.admin,
    @required this.members,
    @required this.prayerList,
    @required this.moderators,
  });
}