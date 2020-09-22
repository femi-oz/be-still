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
  final String description;
  final String organization;
  final String status;
  final String location;
  final String createdBy;

<<<<<<< HEAD:lib/src/Models/group.model.dart
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
=======
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
>>>>>>> 2a9c55534236874c9b1a8b5bdbae02139a004fcb:lib/models/group.model.dart
}
