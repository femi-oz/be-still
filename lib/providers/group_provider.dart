import 'dart:async';

import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/services/group_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

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

  bool _isEdit = false;
  bool get isEdit => _isEdit;
  String _groupJoinId = '';
  String get groupJoinId => _groupJoinId;
  Future<void> setUserGroups(String userId) async {
    // if (_userGroups.isNotEmpty) {
    //   _userGroups = [];
    // }

    if (_firebaseAuth.currentUser == null) return null;
    _groupService
        .getUserGroups(userId)
        .asBroadcastStream()
        .listen((userGroups) {
      List<CombineGroupUserStream> _distinct = [];
      var idSet = <String>{};
      for (var e in userGroups) {
        if (idSet.add(e.group.id)) {
          _distinct.add(e);
        }
      }
      _userGroups = _distinct;
      _userGroups = _userGroups.map((u) {
        List<GroupUserModel> _distinct = [];
        var idSet = <String>{};
        for (var e in u.groupUsers) {
          if (idSet.add(e.userId)) {
            _distinct.add(e);
          }
        }
        return u..groupUsers = _distinct;
      }).toList();
    });
    notifyListeners();
  }

  Stream<CombineGroupUserStream> getGroup(groupdId, String userId) {
    return _groupService.getGroup(groupdId, userId);
  }

  Future setAllGroups(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    _groupService.getAllGroups(userId).asBroadcastStream().listen((groups) {
      _allGroups = groups;
      _filteredAllGroups =
          groups.where((e) => e.groupUsers.length > 0).toList();
      _filteredAllGroups = _filteredAllGroups
          .where((e) => !e.groupUsers.map((e) => e.userId).contains(userId))
          .toList();
      notifyListeners();
    });
  }

  Future searchAllGroups(String searchQuery, String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    List<CombineGroupUserStream> filteredGroups = _allGroups
        .where((CombineGroupUserStream data) =>
            data.group.name.toLowerCase().contains(searchQuery.toLowerCase()) &&
            !data.groupUsers.map((e) => e.userId).contains(userId))
        .toList();
    _filteredAllGroups = filteredGroups;

    _filteredAllGroups = _filteredAllGroups
        .where((e) => !e.groupUsers.map((e) => e.userId).contains(userId))
        .toList();
    notifyListeners();
  }

  Future addGroup(GroupModel groupData, String userID, String fullName) async {
    if (_firebaseAuth.currentUser == null) return null;
    {
      final _userGroupId = Uuid().v1();
      return _groupService
          .addGroup(userID, groupData, fullName, _userGroupId)
          .then((value) async {
        await Future.delayed(Duration(milliseconds: 500));
        await setCurrentGroupById(_userGroupId, userID);
      });
    }
  }

  Future editGroup(GroupModel groupData, String groupId) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.editGroup(groupData, groupId);
  }

  Future leaveGroup(String userGroupId) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.leaveGroup(userGroupId);
  }

  Future deleteGroup(String groupId) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.deleteGroup(groupId);
  }

  Future setCurrentGroup(CombineGroupUserStream group) async {
    if (_firebaseAuth.currentUser == null) return null;
    _currentGroup = group;
    notifyListeners();
  }

  Future setCurrentGroupById(String userGroupId, String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    _groupService
        .getUserGroupById(userGroupId, userId)
        .asBroadcastStream()
        .listen((userGroup) {
      _currentGroup = userGroup;
    });
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

  Future deleteFromGroup(String userId, String groupId) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.deleteFromGroup(userId, groupId);
  }

  Future joinRequest(
      String groupId, String userId, String status, String createdBy) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.joinRequest(groupId, userId, status, createdBy);
  }

  Future acceptRequest(GroupModel groupData, String groupId, String userId,
      String requestId, String fullName) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.acceptRequest(
      groupId,
      groupData,
      userId,
      requestId,
      fullName,
    );
  }

  Future autoJoinGroup(String groupId, String userId, String fullName) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.autoJoinGroup(
      groupId,
      userId,
      fullName,
    );
  }

  Future denyRequest(String groupId, String requestId) async {
    if (_firebaseAuth.currentUser == null) return null;
    return await _groupService.denyRequest(groupId, requestId);
  }

  void setEditMode(bool value) {
    _isEdit = value;
    notifyListeners();
  }

  void setJoinGroupId(String value) {
    _groupJoinId = value;
    notifyListeners();
  }

  Future updateGroupSettings(String userId,
      {String key, dynamic value, String settingsId}) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _groupService.updateGroupSettings(
        key: key, groupSettingsId: settingsId, value: value);
  }
}
