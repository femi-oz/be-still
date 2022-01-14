import 'dart:async';

import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/services/group_service.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class GroupProvider with ChangeNotifier {
  GroupService _groupService = locator<GroupService>();
  NotificationService _notificationService = locator<NotificationService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<CombineGroupUserStream> _userGroups = [];
  List<CombineGroupUserStream> _allGroups = [];
  List<CombineGroupUserStream> _filteredAllGroups = [];
  CombineGroupUserStream _currentGroup = CombineGroupUserStream.defaultValue();
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

    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    _groupService
        .getUserGroups(userId)
        .asBroadcastStream()
        .listen((userGroups) {
      userGroups =
          userGroups.where((element) => element.group != null).toList();
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
      notifyListeners();
    });
  }

  // Stream<CombineGroupUserStream> getGroup(groupdId, String userId) {
  //   return _groupService.getGroup(groupdId, userId);
  // }

  Future<CombineGroupUserStream> getGroupFuture(groupdId, String userId) {
    return _groupService.getGroupFuture(groupdId, userId);
  }

  emptyGroupList() {
    _filteredAllGroups = [];
  }

  Future setAllGroups(String userId) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    _groupService.getAllGroups(userId).asBroadcastStream().listen((groups) {
      _allGroups = groups;
      _filteredAllGroups = [];
      notifyListeners();
    });
  }

  Future searchAllGroups(String searchQuery, String userId) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    if (searchQuery.trim().isEmpty) {
      _filteredAllGroups = [];
      notifyListeners();
      return;
    }
    List<CombineGroupUserStream> filteredGroups = _allGroups
        .where((CombineGroupUserStream data) =>
            data.group.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    _filteredAllGroups = filteredGroups;
    notifyListeners();
  }

  Future advanceSearchAllGroups(String name, String userId, String location,
      String church, String admin, String purpose) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    List<CombineGroupUserStream> filteredGroups = _allGroups
        .where((CombineGroupUserStream data) =>
            data.group.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
    if (location.trim().isNotEmpty)
      filteredGroups = filteredGroups
          .where((CombineGroupUserStream data) => data.group.location
              .toLowerCase()
              .contains(location.toLowerCase()))
          .toList();

    if (church.trim().isNotEmpty)
      filteredGroups = filteredGroups
          .where((CombineGroupUserStream data) => data.group.organization
              .toLowerCase()
              .contains(church.toLowerCase()))
          .toList();
    if (purpose.trim().isNotEmpty)
      filteredGroups = filteredGroups
          .where((CombineGroupUserStream data) => data.group.description
              .toLowerCase()
              .contains(purpose.toLowerCase()))
          .toList();
    if (admin.trim().isNotEmpty)
      filteredGroups = filteredGroups
          .where((CombineGroupUserStream data) => data.groupUsers.any((u) =>
              u.fullName.toLowerCase().contains(admin.toLowerCase()) &&
              u.role == GroupUserRole.admin))
          .toList();

    _filteredAllGroups = filteredGroups;

    notifyListeners();
  }

  Future<bool> addGroup(GroupModel groupData, String userID, String fullName,
      bool allowAutoJoin) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    {
      final _userGroupId = Uuid().v1();
      return _groupService
          .addGroup(userID, groupData, fullName, _userGroupId, allowAutoJoin)
          .then((value) async {
        await setCurrentGroupById(groupData.id, userID);
        return true;
      });
    }
  }

  Future editGroup(GroupModel groupData, String groupId, bool allowAutoJoin,
      String groupSettingsId, String userID) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    return await _groupService
        .editGroup(groupData, groupId, allowAutoJoin, groupSettingsId)
        .then((value) async {
      await setCurrentGroupById(groupId, userID);
      return true;
    });
  }

  Future leaveGroup(String userGroupId) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    return await _groupService.leaveGroup(userGroupId);
  }

  Future deleteGroup(
      String groupId, List<PushNotificationModel> requests) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);

    for (final req in requests) {
      _notificationService.updatePushNotification(req.id);
    }
    return await _groupService.deleteGroup(groupId);
  }

  Future setCurrentGroup(CombineGroupUserStream group) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    _currentGroup = group;
    notifyListeners();
  }

  Future setCurrentGroupById(String groupId, String userId) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    return _groupService.getGroupFuture(groupId, userId).then((userGroup) {
      _currentGroup = userGroup;
      notifyListeners();
    });
  }

  Future inviteMember(
    String groupName,
    String groupId,
    String email,
    String sender,
    String senderId,
  ) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    return await _groupService.inviteMember(
        groupName, groupId, email, sender, senderId);
  }

  Future deleteFromGroup(String userId, String groupId) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    return await _groupService.deleteFromGroup(userId, groupId);
  }

  Future joinRequest(String groupId, String userId, String createdBy) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    return await _groupService.joinRequest(groupId, userId, createdBy);
  }

  Future acceptRequest(String groupId, String senderId, String requestId,
      String fullName) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    return await _groupService.acceptRequest(
      groupId,
      senderId,
      requestId,
      fullName,
    );
  }

  Future autoJoinGroup(String groupId, String userId, String fullName) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    return await _groupService.autoJoinGroup(
      groupId,
      userId,
      fullName,
    );
  }

  Future denyRequest(String groupId, String requestId) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
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
      {String key = '', dynamic value, String settingsId = ''}) async {
    if (_firebaseAuth.currentUser == null)
      return Future.error(StringUtils.unathorized);
    await _groupService.updateGroupSettings(
        key: key, groupSettingsId: settingsId, value: value);
  }
}
