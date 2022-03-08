import 'dart:async';

import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/models/v2/request.model.dart';
import 'package:be_still/services/v2/group_service.dart';
import 'package:be_still/services/v2/notification_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupProviderV2 with ChangeNotifier {
  GroupServiceV2 _groupService = locator<GroupServiceV2>();
  NotificationServiceV2 _notificationService = locator<NotificationServiceV2>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//search params
  String _searchQuery = '';
  String _groupName = '';
  String _adminName = '';
  String _location = '';
  String _church = '';
  String _purpose = '';
  bool _isAdvanceSearch = false;
  //search params end

  late StreamSubscription<List<GroupDataModel>> groupUserStream;
  late StreamSubscription<List<GroupDataModel>> allGroupsStream;

  List<GroupDataModel> _userGroups = [];
  List<GroupDataModel> get userGroups => _userGroups;

  List<GroupDataModel> _allGroups = [];
  List<GroupDataModel> get allGroups => _allGroups;

  List<GroupDataModel> _filteredAllGroups = [];
  List<GroupDataModel> get filteredAllGroups => _filteredAllGroups;

  GroupDataModel _currentGroup = GroupDataModel();
  GroupDataModel get currentGroup => _currentGroup;

  bool _isEdit = false;
  bool get isEdit => _isEdit;

  String _groupJoinId = '';
  String get groupJoinId => _groupJoinId;

  Future<void> setUserGroups() async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      await _groupService.getUserGroupsFuture().then((userGroups) {
        _userGroups = userGroups;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setAllGroups(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      allGroupsStream =
          _groupService.getGroups().asBroadcastStream().listen((groups) {
        _allGroups = groups;
        if (_isAdvanceSearch)
          advanceSearchAllGroups(
              _groupName, userId, _location, _church, _adminName, _purpose);
        else
          searchAllGroups(_searchQuery, userId);
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setCurrentGroupById(String groupId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      await _groupService.getGroup(groupId).then((userGroup) {
        _currentGroup = userGroup;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> searchAllGroups(String searchQuery, String userId) async {
    try {
      _searchQuery = searchQuery;
      _isAdvanceSearch = false;
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      if (searchQuery.trim().isEmpty) {
        _filteredAllGroups = [];
        notifyListeners();
        return;
      }
      List<GroupDataModel> filteredGroups = _allGroups
          .where((GroupDataModel data) => (data.name ?? '')
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
      _filteredAllGroups = filteredGroups;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> advanceSearchAllGroups(String name, String userId,
      String location, String church, String adminName, String purpose) async {
    try {
      _groupName = name;
      _adminName = adminName;
      _location = location;
      _church = church;
      _purpose = purpose;
      _isAdvanceSearch = true;
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      List<GroupDataModel> filteredGroups = _allGroups
          .where((GroupDataModel data) =>
              (data.name ?? '').toLowerCase().contains(name.toLowerCase()))
          .toList();
      if (location.trim().isNotEmpty)
        filteredGroups = filteredGroups
            .where((GroupDataModel data) => (data.location ?? '')
                .toLowerCase()
                .contains(location.toLowerCase()))
            .toList();

      if (church.trim().isNotEmpty)
        filteredGroups = filteredGroups
            .where((GroupDataModel data) => (data.organization ?? '')
                .toLowerCase()
                .contains(church.toLowerCase()))
            .toList();
      if (purpose.trim().isNotEmpty)
        filteredGroups = filteredGroups
            .where((GroupDataModel data) => (data.purpose ?? '')
                .toLowerCase()
                .contains(purpose.toLowerCase()))
            .toList();
      // if (adminName.trim().isNotEmpty)
      //   filteredGroups = filteredGroups.where((GroupDataModel data) {
      //     UserDataModel admin;

      //     return (data.users ?? []).any((u) =>
      //         '${admin.firstName} ${admin.lastName}'
      //             .toLowerCase()
      //             .contains(adminName.toLowerCase()) &&
      //         u.role == GroupUserRole.admin);
      //   }).toList();

      //todo search by admin name
      if (adminName.trim().isEmpty &&
          purpose.trim().isEmpty &&
          church.trim().isEmpty &&
          location.trim().isEmpty &&
          _groupName.isEmpty) {
        filteredGroups = [];
      }

      _filteredAllGroups = filteredGroups;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createGroup(
      String name,
      String purpose,
      String fullName,
      String organization,
      String location,
      String type,
      bool requireAdminApproval) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      return await _groupService.createGroup(
          name: name,
          purpose: purpose,
          requireAdminApproval: requireAdminApproval,
          organization: organization,
          location: location,
          type: type);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> editGroup(
      String groupId,
      String name,
      String purpose,
      bool requireAdminApproval,
      String organization,
      String location,
      String type) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.editGroup(
          groupId: groupId,
          name: name,
          purpose: purpose,
          requireAdminApproval: requireAdminApproval,
          organization: organization,
          location: location,
          type: type);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveGroup(
      String groupId, List<GroupUserDataModel> users, String userId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.leaveGroup(
          groupId: groupId, users: users, userId: userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGroup(String groupId, List<RequestModel> requests) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      for (final req in requests) {
        await _notificationService.cancelPushNotification(req.id ?? '');
      }
      return await _groupService.deleteGroup(groupId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> inviteMember(
    String groupName,
    String groupId,
    String email,
    String sender,
    String senderId,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.inviteMember(
          groupName, groupId, email, sender, senderId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGroupUser(
    String groupId,
    String userId,
    List<GroupUserDataModel> groupUsers,
    List<FollowerModel> followers,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.deleteGroupUser(
          userId: userId,
          groupId: groupId,
          groupUsers: groupUsers,
          followers: followers);
    } catch (e) {
      rethrow;
    }
  }

  Future acceptRequest(
    GroupDataModel group,
    List<RequestModel> currentRequests,
    RequestModel request,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.acceptJoinRequest(
          group: group, request: request);
    } catch (e) {
      rethrow;
    }
  }

  Future requestToJoinGroup(String groupId, String message) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.requestToJoinGroup(
          groupId: groupId, message: message);
    } catch (e) {
      rethrow;
    }
  }

  Future autoJoinGroup(GroupDataModel group, String message) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.autoJoinGroup(group: group, message: message);
    } catch (e) {
      rethrow;
    }
  }

  Future denyRequest(GroupDataModel group, String requestId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.denyJoinRequest(
          group: group, requestId: requestId);
    } catch (e) {
      rethrow;
    }
  }

  void setEditMode(bool value) {
    try {
      _isEdit = value;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void setJoinGroupId(String value) {
    try {
      _groupJoinId = value;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future updateGroupSettings(
    String groupId,
    bool enableNotificationForUpdates,
    bool notifyMeofFlaggedPrayers,
    bool notifyWhenNewMemberJoins,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      await _groupService.updateGroupSettings(
          groupId: groupId,
          enableNotificationForUpdates: enableNotificationForUpdates,
          notifyMeofFlaggedPrayers: notifyMeofFlaggedPrayers,
          notifyWhenNewMemberJoins: notifyWhenNewMemberJoins);
    } catch (e) {
      rethrow;
    }
  }

  flush() {
    allGroupsStream.cancel();
    groupUserStream.cancel();
    resetValues();
  }

  resetValues() {
    _userGroups = [];
    _allGroups = [];
    _filteredAllGroups = [];
    _currentGroup = GroupDataModel();
    _isEdit = false;
    _groupJoinId = '';
    notifyListeners();
  }
}
