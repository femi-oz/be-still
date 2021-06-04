import 'dart:async';

import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/services/group_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class GroupProvider with ChangeNotifier {
  GroupService _groupService = locator<GroupService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<CombineGroupUserStream> _userGroups = [];
  List<CombineGroupUserStream> _allGroups = [];
  List<CombineGroupUserStream> _filteredAllGroups = [];
  CombineGroupUserStream _currentGroup;
  List<CombineGroupUserStream> get userGroups => _userGroups;
  List<CombineGroupUserStream> get allGroups => _allGroups;
  List<CombineGroupUserStream> get filteredAllGroups => _filteredAllGroups;
  CombineGroupUserStream get currentGroup => _currentGroup;

  Future setUserGroups(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    _groupService.getUserGroups(userId).asBroadcastStream().listen((groups) {
      _userGroups = groups;
      notifyListeners();
    });
  }

  Future setAllGroups(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    _groupService.getAllGroups(userId).asBroadcastStream().listen((groups) {
      _allGroups = groups;
      _filteredAllGroups = groups;
      notifyListeners();
    });
  }

  Future searchAllGroups(String searchQuery) async {
    if (_firebaseAuth.currentUser == null) return null;
    List<CombineGroupUserStream> filteredGroups = _allGroups
        .where((CombineGroupUserStream data) =>
            data.group.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    _filteredAllGroups = filteredGroups;
    notifyListeners();
  }

  Future addGroup(GroupModel groupData, String userID, String fullName,
      String email) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.addGroup(userID, groupData, fullName, email);
  }

  Future leaveGroup(String userGroupId) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.leaveGroup(userGroupId);
  }

  Future deleteGroup(String userGroupId, String groupId) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.deleteGroup(userGroupId, groupId);
  }

  Future setCurrentGroup(CombineGroupUserStream group) async {
    if (_firebaseAuth.currentUser == null) return null;
    _currentGroup = group;
    notifyListeners();
  }

  Future inviteMember(
    String groupName,
    String groupId,
    String email,
    String sender,
    String senderId,
  ) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.inviteMember(
        groupName, groupId, email, sender, senderId);
  }

  Future joinRequest(String groupId, String userId, String userName) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.joinRequest(groupId, userId, userName);
  }
}
