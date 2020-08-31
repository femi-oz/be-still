
import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String password;
  final String email;
  final List<String> archivedPrayers;
  final List<String> prayerList;
  final List<String> answeredPrayers;
  final List<String> groups; 
  final DateTime dob;

  const UserModel({
    @required this.id,
    @required this.name,
    @required this.username,
    @required this.password,
    @required this.email,
    @required this.archivedPrayers,
    @required this.prayerList,
    @required this.answeredPrayers,
    @required this.groups,
    @required this.dob,
  });
}