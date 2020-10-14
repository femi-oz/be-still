import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/group_service.dart';
import 'package:flutter/cupertino.dart';

class GroupProvider with ChangeNotifier {
  GroupService _groupService = locator<GroupService>();
  Stream<List<CombineGroupUserStream>> getGroups(String userId) {
    return _groupService.fetchGroups(userId);
  }

  Future<List<GroupUserModel>> getGroupUsers(String groupId) async {
    return await _groupService.fetchGroupUsers(groupId).then(
        (e) => e.documents.map((e) => GroupUserModel.fromData(e)).toList());
  }

  Future addGroup(GroupModel groupData, String _userID) async {
    return await _groupService.addGroup(_userID, groupData);
  }

  Future addGroupPrayer(GroupPrayerModel groupPrayerData, String _userID,
      String groupId, UserModel userData) async {
    return await _groupService.addPrayerGroup(
        _userID, userData, groupPrayerData);
  }

  Future inviteMember(GroupInviteModel groupInvite, String userId,
      String groupId, UserModel userData) async {
    return await _groupService.inviteMember(
        groupInvite, userId, groupId, userData);
  }

  Future updateMemberType(String userId, String groupId) async {
    return await _groupService.updateMemberType(userId, groupId);
  }

  Future removeMemberFromGroup(String userId, String groupId) async {
    return await _groupService.removeMemberFromGroup(userId, groupId);
  }

  Future acceptInvite(String userId, String groupId, String status) async {
    return await _groupService.acceptInvite(groupId, userId, status);
  }
}
