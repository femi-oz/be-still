import 'dart:async';

import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/services/group_service.dart';
import 'package:flutter/cupertino.dart';

class GroupProvider with ChangeNotifier {
  GroupService _groupService = locator<GroupService>();

  List<CombineGroupUserStream> _userGroups = [];
  List<CombineGroupUserStream> _allGroups = [];
  List<CombineGroupUserStream> _filteredAllGroups = [];
  CombineGroupUserStream _currentGroup;
  List<CombineGroupUserStream> get userGroups => _userGroups;
  List<CombineGroupUserStream> get allGroups => _allGroups;
  List<CombineGroupUserStream> get filteredAllGroups => _filteredAllGroups;
  CombineGroupUserStream get currentGroup => _currentGroup;

  Future setUserGroups(String userId) async {
    _groupService.getUserGroups(userId).asBroadcastStream().listen((groups) {
      _userGroups = groups;
      notifyListeners();
    });
  }

  Future setAllGroups(String userId) async {
    _groupService.getAllGroups(userId).asBroadcastStream().listen((groups) {
      _allGroups = groups;
      _filteredAllGroups = groups;
      notifyListeners();
    });
  }

  Future searchAllGroups(String searchQuery) async {
    List<CombineGroupUserStream> filteredGroups = _allGroups
        .where((CombineGroupUserStream data) =>
            data.group.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    _filteredAllGroups = filteredGroups;
    notifyListeners();
  }

  Future addGroup(GroupModel groupData, String userID, String fullName) async {
    return await _groupService.addGroup(userID, groupData, fullName);
  }

  Future leaveGroup(String userGroupId) async {
    return await _groupService.leaveGroup(userGroupId);
  }

  Future deleteGroup(String userGroupId, String groupId) async {
    return await _groupService.deleteGroup(userGroupId, groupId);
  }

  Future setCurrentGroup(CombineGroupUserStream group) async {
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
    return await _groupService.inviteMember(
        groupName, groupId, email, sender, senderId);
  }

  Future joinRequest(String groupId, String userId, String userName) async {
    return await _groupService.joinRequest(groupId, userId, userName);
  }

  // Future updateMemberType(String userId, String groupId) async {
  //   return await _groupService.updateMemberType(userId, groupId);
  // }

  // Future removeMemberFromGroup(String userId, String groupId) async {
  //   return await _groupService.removeMemberFromGroup(userId, groupId);
  // }

  // Future acceptInvite(String userId, String groupId, String status) async {
  //   return await _groupService.acceptInvite(groupId, userId, status);
  // }
}
