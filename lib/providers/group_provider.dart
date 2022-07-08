// import 'dart:async';

// import 'package:be_still/enums/user_role.dart';
// import 'package:be_still/locator.dart';
// import 'package:be_still/models/group.model.dart';
// import 'package:be_still/models/notification.model.dart';
// import 'package:be_still/services/group_service.dart';
// import 'package:be_still/services/notification_service.dart';
// import 'package:be_still/utils/string_utils.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:uuid/uuid.dart';

// class GroupProvider with ChangeNotifier {
//   GroupService _groupService = locator<GroupService>();
//   NotificationService _notificationService = locator<NotificationService>();
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   GroupProvider._();
//   factory GroupProvider() => _instance;
//   static final GroupProvider _instance = GroupProvider._();

//   late StreamSubscription<List<CombineGroupUserStream>> groupUserStream;
//   late StreamSubscription<List<CombineGroupUserStream>> allGroupsStream;

//   List<CombineGroupUserStream> _userGroups = [];
//   List<CombineGroupUserStream> _sortedMemberGroups = [];
//   List<CombineGroupUserStream> _allGroups = [];
//   List<CombineGroupUserStream> _filteredAllGroups = [];
//   CombineGroupUserStream _currentGroup = CombineGroupUserStream.defaultValue();
//   List<CombineGroupUserStream> get userGroups => _userGroups;
//   List<CombineGroupUserStream> get sortedMemberGroups => _sortedMemberGroups;
//   List<CombineGroupUserStream> get allGroups => _allGroups;
//   List<CombineGroupUserStream> get filteredAllGroups => _filteredAllGroups;
//   CombineGroupUserStream get currentGroup => _currentGroup;

//   bool _isEdit = false;
//   bool get isEdit => _isEdit;
//   String _groupJoinId = '';
//   String get groupJoinId => _groupJoinId;

//   resetValues() {
//     _userGroups = [];
//     _allGroups = [];
//     _filteredAllGroups = [];
//     _currentGroup = CombineGroupUserStream.defaultValue();
//     _isEdit = false;
//     _groupJoinId = '';
//     notifyListeners();
//   }

//   Future<void> setUserGroups(String userId) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       groupUserStream = _groupService
//           .getUserGroups(userId)
//           .asBroadcastStream()
//           .listen((userGroups) {
//         userGroups = userGroups
//             .where((element) => (element.group?.id ?? '').isNotEmpty)
//             .toList();
//         List<CombineGroupUserStream> _distinct = [];
//         var idSet = <String>{};
//         for (var e in userGroups) {
//           if (idSet.add(e.group?.id ?? '')) {
//             _distinct.add(e);
//           }
//         }
//         _userGroups = _distinct;
//         _userGroups = _userGroups.map((u) {
//           List<GroupUserModel> _distinct = [];
//           var idSet = <String>{};
//           for (var e in u.groupUsers ?? []) {
//             if (idSet.add(e.userId)) {
//               _distinct.add(e);
//             }
//           }
//           return u..groupUsers = _distinct;
//         }).toList();

//         final isAdminGroups = _userGroups
//             .where((element) => (element.groupUsers ?? []).any((element) =>
//                 element.role == GroupUserRole.admin &&
//                 element.userId == userId))
//             .toList();

//         isAdminGroups.sort((a, b) => (a.group?.name ?? '')
//             .toLowerCase()
//             .compareTo((b.group?.name ?? '').toLowerCase()));

//         final isNotAdminGroups = _userGroups
//             .where((element) => (element.groupUsers ?? []).any((element) =>
//                 element.role != GroupUserRole.admin &&
//                 element.userId == userId))
//             .toList();

//         isNotAdminGroups.sort((a, b) => (a.group?.name ?? '')
//             .toLowerCase()
//             .compareTo((b.group?.name ?? '').toLowerCase()));

//         _userGroups = [...isAdminGroups, ...isNotAdminGroups];

//         notifyListeners();
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<CombineGroupUserStream> getGroupFuture(groupdId, String userId) {
//     try {
//       return _groupService.getGroupFuture(groupdId, userId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   emptyGroupList() {
//     try {
//       _filteredAllGroups = [];
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future setAllGroups(String userId) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       allGroupsStream = _groupService
//           .getAllGroups(userId)
//           .asBroadcastStream()
//           .listen((groups) {
//         _allGroups = groups;
//         if (_isAdvanceSearch)
//           advanceSearchAllGroups(
//               _groupName, userId, _location, _church, _adminName, _purpose);
//         else
//           searchAllGroups(_searchQuery, userId);
//         notifyListeners();
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }

// //search params
//   String _searchQuery = '';
//   String _groupName = '';
//   String _adminName = '';
//   String _location = '';
//   String _church = '';
//   String _purpose = '';
//   bool _isAdvanceSearch = false;
//   //search params end

//   Future searchAllGroups(String searchQuery, String userId) async {
//     try {
//       _searchQuery = searchQuery;
//       _isAdvanceSearch = false;
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       if (searchQuery.trim().isEmpty) {
//         _filteredAllGroups = [];
//         notifyListeners();
//         return;
//       }
//       List<CombineGroupUserStream> filteredGroups = _allGroups
//           .where((CombineGroupUserStream data) => (data.group?.name ?? '')
//               .toLowerCase()
//               .contains(searchQuery.toLowerCase()))
//           .toList();
//       _filteredAllGroups = filteredGroups;
//       notifyListeners();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future advanceSearchAllGroups(String name, String userId, String location,
//       String church, String admin, String purpose) async {
//     try {
//       _groupName = name;
//       _adminName = admin;
//       _location = location;
//       _church = church;
//       _purpose = purpose;
//       _isAdvanceSearch = true;
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       List<CombineGroupUserStream> filteredGroups = _allGroups
//           .where((CombineGroupUserStream data) => (data.group?.name ?? '')
//               .toLowerCase()
//               .contains(name.toLowerCase()))
//           .toList();
//       if (location.trim().isNotEmpty)
//         filteredGroups = filteredGroups
//             .where((CombineGroupUserStream data) => (data.group?.location ?? '')
//                 .toLowerCase()
//                 .contains(location.toLowerCase()))
//             .toList();

//       if (church.trim().isNotEmpty)
//         filteredGroups = filteredGroups
//             .where((CombineGroupUserStream data) =>
//                 (data.group?.organization ?? '')
//                     .toLowerCase()
//                     .contains(church.toLowerCase()))
//             .toList();
//       if (purpose.trim().isNotEmpty)
//         filteredGroups = filteredGroups
//             .where((CombineGroupUserStream data) =>
//                 (data.group?.description ?? '')
//                     .toLowerCase()
//                     .contains(purpose.toLowerCase()))
//             .toList();
//       if (admin.trim().isNotEmpty)
//         filteredGroups = filteredGroups
//             .where((CombineGroupUserStream data) => (data.groupUsers ?? []).any(
//                 (u) =>
//                     (u.fullName ?? '')
//                         .toLowerCase()
//                         .contains(admin.toLowerCase()) &&
//                     u.role == GroupUserRole.admin))
//             .toList();
//       if (admin.trim().isEmpty &&
//           purpose.trim().isEmpty &&
//           church.trim().isEmpty &&
//           location.trim().isEmpty &&
//           _groupName.isEmpty) {
//         filteredGroups = [];
//       }

//       _filteredAllGroups = filteredGroups;
//       notifyListeners();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future addGroup(GroupModel groupData, String userID, String fullName,
//       bool allowAutoJoin) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       {
//         final _userGroupId = Uuid().v1();
//         return _groupService
//             .addGroup(userID, groupData, fullName, _userGroupId, allowAutoJoin)
//             .then((value) async {
//           await setCurrentGroupById(groupData.id ?? '', userID);
//           return true;
//         });
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future editGroup(GroupModel groupData, String groupId, bool allowAutoJoin,
//       String groupSettingsId, String userID) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       return await _groupService
//           .editGroup(groupData, groupId, allowAutoJoin, groupSettingsId)
//           .then((value) async {
//         await setCurrentGroupById(groupId, userID);
//         return true;
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future leaveGroup(String userGroupId) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       return await _groupService.leaveGroup(userGroupId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future deleteGroup(
//       String groupId, List<PushNotificationModel> requests) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);

//       for (final req in requests) {
//         await _notificationService.updatePushNotification(req.id ?? '');
//       }
//       return await _groupService.deleteGroup(groupId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future setCurrentGroup(CombineGroupUserStream group) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       _currentGroup = group;
//       notifyListeners();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> setCurrentGroupById(String groupId, String userId) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       return _groupService.getGroupFuture(groupId, userId).then((userGroup) {
//         _currentGroup = userGroup;
//         notifyListeners();
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future inviteMember(
//     String groupName,
//     String groupId,
//     String email,
//     String sender,
//     String senderId,
//   ) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       return await _groupService.inviteMember(
//           groupName, groupId, email, sender, senderId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future deleteFromGroup(String userId, String groupId) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       return await _groupService.deleteFromGroup(userId, groupId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future joinRequest(String groupId, String userId, String createdBy) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       return await _groupService.joinRequest(groupId, userId, createdBy);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future acceptRequest(String groupId, String senderId, String requestId,
//       String fullName) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       return await _groupService.acceptRequest(
//         groupId,
//         senderId,
//         requestId,
//         fullName,
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future autoJoinGroup(String groupId, String userId, String fullName) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       return await _groupService.autoJoinGroup(
//         groupId,
//         userId,
//         fullName,
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future denyRequest(String groupId, String requestId) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       return await _groupService.denyRequest(groupId, requestId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   void setEditMode(bool value) {
//     try {
//       _isEdit = value;
//       notifyListeners();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   void setJoinGroupId(String value) {
//     try {
//       _groupJoinId = value;
//       notifyListeners();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future updateGroupSettings(String? userId,
//       {String key = '', dynamic value, String settingsId = ''}) async {
//     try {
//       if (_firebaseAuth.currentUser == null)
//         return Future.error(StringUtils.unathorized);
//       await _groupService.updateGroupSettings(
//           key: key, groupSettingsId: settingsId, value: value);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   flush() async {
//     allGroupsStream.cancel();
//     groupUserStream.cancel();
//     resetValues();
//   }
// }
