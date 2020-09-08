import 'package:flutter/foundation.dart';

class GroupModel {
  final String id;
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

  const GroupModel({
    @required this.id,
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
  });
}
