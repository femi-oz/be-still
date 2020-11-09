import 'dart:async';

import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/services/group_service.dart';
import 'package:flutter/cupertino.dart';

class GroupProvider with ChangeNotifier {
  GroupService _groupService = locator<GroupService>();

  List<CombineGroupUserStream> _groups = [];
  List<GroupUserModel> _currentGroupUsers = [];
  GroupModel _currentGroup;
  List<CombineGroupUserStream> get groups => _groups;
  List<GroupUserModel> get currentGroupUsers => _currentGroupUsers;
  GroupModel get currentGroup => _currentGroup;

  Future setGroups(String userId) async {
    _groupService.getGroups(userId).asBroadcastStream().listen((groups) {
      _groups = groups;
      notifyListeners();
    });
  }

  Future setGroupUsers(String groupId) async {
    _groupService.getGroupUsers(groupId).asBroadcastStream().listen((users) {
      _currentGroupUsers =
          users.documents.map((user) => GroupUserModel.fromData(user)).toList();
      notifyListeners();
    });
  }

  Future addGroup(GroupModel groupData, String _userID) async {
    return await _groupService.addGroup(_userID, groupData);
  }

  Future setCurrentGroup(GroupModel group) async {
    _currentGroup = group;
    notifyListeners();
  }

  // Future inviteMember(GroupInviteModel groupInvite, String userId,
  //     String groupId, UserModel userData) async {
  //   return await _groupService.inviteMember(
  //       groupInvite, userId, groupId, userData);
  // }

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
