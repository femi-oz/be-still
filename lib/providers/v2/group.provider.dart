import 'dart:async';

import 'package:be_still/enums/user_role.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/notification.model.dart';
import 'package:be_still/models/v2/request.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/services/v2/group_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GroupProviderV2 with ChangeNotifier {
  GroupServiceV2 _groupService = locator<GroupServiceV2>();
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

  Future<void> setUserGroups(List<String> userGroupsId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _groupService
          .getUserGroups(userGroupsId)
          .asBroadcastStream()
          .listen((userGroups) {
        final isAdminGroups = userGroups
            .where((element) => (element.users ?? []).any((element) =>
                element.role == GroupUserRole.admin &&
                element.userId == FirebaseAuth.instance.currentUser?.uid))
            .toList();

        isAdminGroups.sort((a, b) => (a.name ?? '')
            .toLowerCase()
            .compareTo((b.name ?? '').toLowerCase()));

        final isNotAdminGroups = userGroups
            .where((element) => (element.users ?? []).any((element) =>
                element.role != GroupUserRole.admin &&
                element.userId == FirebaseAuth.instance.currentUser?.uid))
            .toList();

        isNotAdminGroups.sort((a, b) => (a.name ?? '')
            .toLowerCase()
            .compareTo((b.name ?? '').toLowerCase()));

        _userGroups = [...isAdminGroups, ...isNotAdminGroups];

        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setAllGroups() async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _groupService.getGroups().then((groups) {
        _allGroups = groups;
        if (_isAdvanceSearch)
          advanceSearchAllGroups(
              _groupName, _location, _church, _adminName, _purpose);
        else
          searchAllGroups(_searchQuery);
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

  Future<void> onGroupChanges(List<String> ids) async {
    try {
      _groupService.getUserGroupEmpty(ids).asBroadcastStream().listen((event) {
        setUserGroups(ids);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<GroupDataModel> getCurrentGroupById(String groupId) async {
    try {
      return _groupService.getGroup(groupId).then((group) {
        return group;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> searchAllGroups(String searchQuery) async {
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

  Future<void> advanceSearchAllGroups(String name, String location,
      String church, String adminName, String purpose) async {
    try {
      _groupName = name;
      _adminName = adminName;
      _location = location;
      _church = church;
      _purpose = purpose;
      _isAdvanceSearch = true;
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      List<GroupDataModel> filteredGroups = [];

      if (adminName.trim().isEmpty &&
          purpose.trim().isEmpty &&
          church.trim().isEmpty &&
          location.trim().isEmpty &&
          name.trim().isEmpty) {
        filteredGroups = [];
      } else {
        filteredGroups = _allGroups
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
        if (adminName.trim().isNotEmpty) {
          filteredGroups = filteredGroups.where((f) {
            final adminUid = (f.users ?? [])
                    .firstWhere((e) => e.role == GroupUserRole.admin)
                    .userId ??
                '';
            final allUsers =
                Provider.of<UserProviderV2>(Get.context!, listen: false)
                    .allUsers;
            final admin = allUsers.firstWhere((u) => u.id == adminUid,
                orElse: () => UserDataModel());

            return ('${admin.firstName} ${admin.lastName}'
                .toLowerCase()
                .contains(adminName.toLowerCase()));
          }).toList();
        }
      }

      _filteredAllGroups = filteredGroups;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createGroup(
      String name,
      String purpose,
      String fullName,
      String organization,
      String location,
      String type,
      bool requireAdminApproval,
      List<String> userGroupsId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      final groupId = await _groupService.createGroup(
          name: name,
          purpose: purpose,
          requireAdminApproval: requireAdminApproval,
          organization: organization,
          location: location,
          type: type);
      await setCurrentGroupById(groupId);
      return groupId;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> editGroup(
      String groupId,
      String name,
      String purpose,
      bool requireAdminApproval,
      String organization,
      String location,
      String type,
      List<String> userGroupsId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      await _groupService.editGroup(
          groupId: groupId,
          name: name,
          purpose: purpose,
          requireAdminApproval: requireAdminApproval,
          organization: organization,
          location: location,
          type: type);
      await setUserGroups(userGroupsId);
      await setCurrentGroupById(groupId);
      return groupId;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      await _groupService.removeGroupUser(
          userId: _firebaseAuth.currentUser?.uid ?? '', groupId: groupId);
    } catch (e) {
      rethrow;
    }
  }

  emptyGroupList() {
    try {
      _filteredAllGroups = [];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGroup(
      String groupId, List<NotificationModel> notifications) async {
    try {
      return await _groupService.deleteGroup(groupId, notifications);
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

  Future<void> removeGroupUser(String userId, String groupId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      await _groupService.removeGroupUser(userId: userId, groupId: groupId);
      // final user =
      //     Provider.of<UserProviderV2>(Get.context!, listen: false).currentUser;
      // setUserGroups(user.groups ?? []);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptRequest(
      GroupDataModel group, RequestModel request, String notificationId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.acceptJoinRequest(
          group: group, request: request, notificationId: notificationId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestToJoinGroup(String groupId, String message,
      String receiverId, List<String> tokens, List<String> userGroupsId) async {
    try {
      await _groupService.requestToJoinGroup(
        groupId: groupId,
        message: message,
        receiverId: receiverId,
        tokens: tokens,
      );
      setUserGroups(userGroupsId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> autoJoinGroup(GroupDataModel group, String message) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.autoJoinGroup(group: group, message: message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> denyRequest(GroupDataModel group, RequestModel request) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return await _groupService.denyJoinRequest(
          group: group, request: request);
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

  Future<void> updateGroupUserSettings(GroupDataModel group, String key,
      dynamic value, List<String> userGroupsId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      await _groupService.updateGroupUserSettings(group, key, value);
      await setUserGroups(userGroupsId);
    } catch (e) {
      rethrow;
    }
  }

  Future flush() async {
    _userGroups = [];
    _allGroups = [];
    _filteredAllGroups = [];
    _currentGroup = GroupDataModel();
    _isEdit = false;
    _groupJoinId = '';
    notifyListeners();
  }
}
