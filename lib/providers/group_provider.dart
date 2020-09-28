import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/services/group_service.dart';
import 'package:flutter/cupertino.dart';

class GroupProvider with ChangeNotifier {
  GroupService _groupService = locator<GroupService>();
  Stream<List<CombineGroupUserStream>> getGroups(String userId) {
    return _groupService.fetchGroups(userId);
  }

  Future addGroup(GroupModel groupData, String _userID) async {
    return await _groupService.addGroup(_userID, groupData);
  }
}
