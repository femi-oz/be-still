import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/group_settings_model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../locator.dart';

class GroupService {
  final _databaseReference = FirebaseFirestore.instance;
  final CollectionReference<Map<String, dynamic>> _groupCollectionReference =
      FirebaseFirestore.instance.collection("Group");
  final CollectionReference<Map<String, dynamic>>
      _groupRequestCollectionReference =
      FirebaseFirestore.instance.collection("GroupRequest");
  final CollectionReference<Map<String, dynamic>>
      _userGroupCollectionReference =
      FirebaseFirestore.instance.collection("UserGroup");

  final CollectionReference<Map<String, dynamic>> _userCollectionReference =
      FirebaseFirestore.instance.collection("User");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>>
      _groupSettingsCollectionReference =
      FirebaseFirestore.instance.collection("GroupSettings");

  final CollectionReference<Map<String, dynamic>>
      _followedPrayerCollectionReference =
      FirebaseFirestore.instance.collection("FollowedPrayer");
  final CollectionReference<Map<String, dynamic>>
      _userPrayerCollectionReference =
      FirebaseFirestore.instance.collection("UserPrayer");
  final CollectionReference<Map<String, dynamic>>
      _groupPrayerCollectionReference =
      FirebaseFirestore.instance.collection("GroupPrayer");

  GroupUserModel populateGroupUser(
    // GroupModel groupData,
    String userID,
    String groupID,
    String role,
    String creator,
    String fullName,
    String id,
    // String email
  ) {
    GroupUserModel userPrayer = GroupUserModel(
      id: id,
      fullName: fullName,
      userId: userID,
      status: Status.active,
      groupId: groupID,
      role: role,
      createdBy: creator,
      createdOn: DateTime.now(),
      modifiedBy: creator,
      modifiedOn: DateTime.now(),
    );
    return userPrayer;
  }

  GroupModel populateGroup(
    GroupModel groupData,
    String groupID,
  ) {
    GroupModel group = GroupModel(
      status: Status.active,
      id: groupID,
      createdBy: groupData.createdBy,
      createdOn: groupData.createdOn,
      modifiedBy: groupData.modifiedBy,
      modifiedOn: groupData.modifiedOn,
      description: groupData.description,
      // email: groupData.email,
      isFeed: groupData.isFeed,
      isPrivate: groupData.isPrivate,
      location: groupData.location,
      name: groupData.name,
      organization: groupData.organization,
    );
    return group;
  }

  GroupRequestModel populateGroupRequest(String userId, String createdBy,
      DateTime createdOn, String groupId, String id) {
    GroupRequestModel groupRequest = GroupRequestModel(
        id: id,
        userId: userId,
        groupId: groupId,
        status: '',
        createdBy: createdBy,
        createdOn: createdOn);
    return groupRequest;
  }

  // Stream<List<CombineGroupUserStream>> _combineAllGroupsStream;
  Stream<List<CombineGroupUserStream>> getAllGroups(String userId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _groupCollectionReference.snapshots().map((convert) {
        return convert.docs.map((g) {
          Stream<GroupModel> group = Stream.value(g).map<GroupModel>(
              (document) => GroupModel.fromData(document.data(), document.id));
          Stream<List<GroupUserModel>> groupUsers =
              _userGroupCollectionReference
                  .where('GroupId', isEqualTo: g.id)
                  .snapshots()
                  .asyncMap((e) => e.docs
                      .map((doc) => GroupUserModel.fromData(doc.data(), doc.id))
                      .toList());

          Stream<List<GroupRequestModel>> groupRequests =
              _groupRequestCollectionReference
                  .where('GroupId', isEqualTo: g.id)
                  .snapshots()
                  .asyncMap((e) => e.docs
                      .map((doc) =>
                          GroupRequestModel.fromData(doc.data(), doc.id))
                      .toList());
          Stream<List<GroupSettings>> groupSettings =
              _groupSettingsCollectionReference
                  .where('GroupId', isEqualTo: g.id)
                  .snapshots()
                  .asyncMap((e) {
            if (e.docs.length == 0) {
              addGroupSettings(userId, g.id, true);
              return [
                GroupSettings(
                    id: '',
                    requireAdminApproval: true,
                    userId: userId,
                    groupId: g.id,
                    enableNotificationFormNewPrayers: false,
                    enableNotificationForUpdates: false,
                    notifyOfMembershipRequest: false,
                    notifyMeofFlaggedPrayers: false,
                    notifyWhenNewMemberJoins: false,
                    createdBy: userId,
                    createdOn: DateTime.now(),
                    modifiedBy: userId,
                    modifiedOn: DateTime.now())
              ];
            }
            return e.docs
                .map((doc) => GroupSettings.fromData(doc.data(), doc.id))
                .toList();
          });
          return Rx.combineLatest4(
              groupUsers,
              group,
              groupRequests,
              groupSettings,
              (
                List<GroupUserModel> groupUsers,
                GroupModel group,
                List<GroupRequestModel> groupRequests,
                List<GroupSettings> groupSettings,
              ) =>
                  CombineGroupUserStream(
                    groupUsers: groupUsers,
                    group: group,
                    groupRequests: groupRequests,
                    groupSettings: groupSettings[0],
                  ));
        });
      }).switchMap((observables) {
        return observables.length > 0
            ? Rx.combineLatestList(observables)
            : Stream.value([]);
      });
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), userId, 'GROUP/service/getAllGroups');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<CombineGroupUserStream> getGroupFuture(
      String groupdId, String userId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return _groupCollectionReference.doc(groupdId).get().then((g) async {
        GroupModel group = GroupModel.fromData(g.data()!, g.id);
        List<GroupUserModel> groupUsers = await _userGroupCollectionReference
            .where('GroupId', isEqualTo: g.id)
            .get()
            .then((e) => e.docs
                .map((doc) => GroupUserModel.fromData(doc.data(), doc.id))
                .toList());

        List<GroupRequestModel> groupRequests =
            await _groupRequestCollectionReference
                .where('GroupId', isEqualTo: g.id)
                .get()
                .then((e) => e.docs
                    .map(
                        (doc) => GroupRequestModel.fromData(doc.data(), doc.id))
                    .toList());
        List<GroupSettings> groupSettings =
            await _groupSettingsCollectionReference
                .where('GroupId', isEqualTo: g.id)
                .get()
                .then((e) {
          if (e.docs.length == 0) {
            addGroupSettings(userId, g.id, true);
            return [
              GroupSettings(
                  id: '',
                  requireAdminApproval: true,
                  userId: userId,
                  groupId: g.id,
                  enableNotificationFormNewPrayers: false,
                  enableNotificationForUpdates: false,
                  notifyOfMembershipRequest: false,
                  notifyMeofFlaggedPrayers: false,
                  notifyWhenNewMemberJoins: false,
                  createdBy: userId,
                  createdOn: DateTime.now(),
                  modifiedBy: userId,
                  modifiedOn: DateTime.now())
            ];
          }
          return e.docs
              .map((doc) => GroupSettings.fromData(doc.data(), doc.id))
              .toList();
        });
        return CombineGroupUserStream(
          group: group,
          groupRequests: groupRequests,
          groupSettings: groupSettings[0],
          groupUsers: groupUsers,
        );
      });
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), groupdId,
          'GROUP/service/getAllGroups');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<CombineGroupUserStream>> getUserGroups(String userId) {
    try {
      return _userGroupCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((convert) {
        return convert.docs.map((f) {
          Stream<GroupModel> group = _groupCollectionReference
              .doc(f['GroupId'])
              .snapshots()
              .map<GroupModel>((document) => document.data() == null
                  ? GroupModel.defaultValue()
                  : GroupModel.fromData(document.data()!, document.id));
          Stream<List<GroupUserModel>> groupUsers =
              _userGroupCollectionReference
                  .where('GroupId', isEqualTo: f['GroupId'])
                  .snapshots()
                  .asyncMap((e) => e.docs
                      .map((doc) => GroupUserModel.fromData(doc.data(), doc.id))
                      .toList());
          Stream<List<GroupSettings>> groupSettings =
              _groupSettingsCollectionReference
                  .where('GroupId', isEqualTo: f['GroupId'])
                  .where('UserId', isEqualTo: userId)
                  .snapshots()
                  .asyncMap((e) {
            if (e.docs.length == 0) {
              addGroupSettings(userId, f['GroupId'], false);
              return [
                GroupSettings(
                    id: '',
                    requireAdminApproval: true,
                    userId: userId,
                    groupId: f['GroupId'],
                    enableNotificationFormNewPrayers: false,
                    enableNotificationForUpdates: false,
                    notifyOfMembershipRequest: false,
                    notifyMeofFlaggedPrayers: false,
                    notifyWhenNewMemberJoins: false,
                    createdBy: userId,
                    createdOn: DateTime.now(),
                    modifiedBy: userId,
                    modifiedOn: DateTime.now())
              ];
            }
            return e.docs
                .map((doc) => GroupSettings.fromData(doc.data(), doc.id))
                .toList();
          });

          Stream<List<GroupRequestModel>> groupRequests =
              _groupRequestCollectionReference
                  .where('GroupId', isEqualTo: f['GroupId'])
                  .snapshots()
                  .asyncMap((e) => e.docs
                      .map((doc) =>
                          GroupRequestModel.fromData(doc.data(), doc.id))
                      .toList());
          return Rx.combineLatest4(
              groupUsers,
              group,
              groupRequests,
              groupSettings,
              (
                List<GroupUserModel> groupUsers,
                GroupModel group,
                List<GroupRequestModel> groupRequests,
                List<GroupSettings> groupSettings,
              ) =>
                  CombineGroupUserStream(
                    groupUsers: groupUsers,
                    group: group,
                    groupRequests: groupRequests,
                    groupSettings: groupSettings[0],
                  ));
        });
      }).switchMap((observables) {
        return observables.length > 0
            ? Rx.combineLatestList(observables)
            : Stream.value([]);
      });
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'GROUP/service/getUserGroups');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<String> addGroup(String userId, GroupModel groupData, String fullName,
      String userGroupId, bool requireAdminApproval) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final groupSettingsId = Uuid().v1();

      final batch = _databaseReference.batch();
      batch.set(_groupCollectionReference.doc(groupData.id),
          populateGroup(groupData, groupData.id ?? '').toJson());
      batch.set(
          _userGroupCollectionReference.doc(userGroupId),
          populateGroupUser(userId, groupData.id ?? '', GroupUserRole.admin,
                  groupData.createdBy ?? '', fullName, userGroupId)
              .toJson());
      batch.set(
          _groupSettingsCollectionReference.doc(groupSettingsId),
          populateGroupSettings(userId, groupData.id ?? '',
                  requireAdminApproval, groupSettingsId)
              .toJson());
      await batch.commit();

      return userGroupId;
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), userId, 'GROUP/service/addGroup');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<bool> editGroup(GroupModel groupData, String groupID,
      bool requireAdminApproval, String groupSettingsId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final batch = _databaseReference.batch();
      batch.update(
        _groupCollectionReference.doc(groupID),
        {
          "Name": groupData.name,
          "Description": groupData.description,
          "Organization": groupData.organization,
          "Location": groupData.location,
          "Status": groupData.status,
          "IsPrivate": groupData.isPrivate,
          "IsFeed": groupData.isFeed,
          "ModifiedOn": DateTime.now()
        },
      );

      batch.update(_groupSettingsCollectionReference.doc(groupSettingsId),
          {SettingsKey.requireAdminApproval: requireAdminApproval});
      await batch.commit();
      return true;
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), groupID, 'GROUP/service/editGroup');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  joinRequest(
    String groupId,
    String userId,
    String createdBy,
  ) async {
    try {
      final _requestID = Uuid().v1();
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _groupRequestCollectionReference.doc(_requestID).set(populateGroupRequest(
              userId, createdBy, DateTime.now(), groupId, _requestID)
          .toJson());
      getUserGroups(userId);
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), userId, 'GROUP/service/joinRequest');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  deleteRequest(String id) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _groupRequestCollectionReference.doc(id).delete();
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), id, 'GROUP/service/deleteRequest');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  acceptRequest(
      String groupId, String userId, String requestId, String fullName) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final _userGroupId = Uuid().v1();
      final batch = _databaseReference.batch();
      batch.set(
          _userGroupCollectionReference.doc(_userGroupId),
          populateGroupUser(userId, groupId, GroupUserRole.member, userId,
                  fullName, _userGroupId)
              .toJson());

      batch.delete(_groupRequestCollectionReference.doc(requestId));
      await batch.commit();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'GROUP/service/acceptRequest');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  autoJoinGroup(String groupId, String userId, String fullName) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final _userGroupId = Uuid().v1();
      _userGroupCollectionReference.doc(_userGroupId).set(populateGroupUser(
              userId,
              groupId,
              GroupUserRole.member,
              userId,
              fullName,
              _userGroupId)
          .toJson());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'GROUP/service/autoJoinGroup');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  denyRequest(String groupId, String requestId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _groupRequestCollectionReference.doc(requestId).delete();
      // .update({"Status": StringUtils.joinRequestStatusDenied});
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), requestId,
          'GROUP/service/denyRequest');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  leaveGroup(String userGroupId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _userGroupCollectionReference.doc(userGroupId).delete();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          userGroupId, 'GROUP/service/leaveGroup');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  deleteGroup(String groupId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final batch = _databaseReference.batch();
      batch.delete(_groupCollectionReference.doc(groupId));

      _userGroupCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .get()
          .then((value) {
        for (final doc in value.docs) {
          batch.delete(doc.reference);
        }
      });
      final x = await _followedPrayerCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .get();
      x.docs.forEach((element) {
        final f = FollowedPrayerModel.fromData(element.data(), element.id);
        batch.update(_userPrayerCollectionReference.doc(f.userPrayerId),
            {'DeleteStatus': -1});
      });
      _groupPrayerCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .get()
          .then((value) {
        for (final doc in value.docs) {
          batch.delete(doc.reference);
        }
      });
      await batch.commit();
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), groupId, 'GROUP/service/deleteGroup');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  deleteFromGroup(String userId, String groupId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _userGroupCollectionReference
          .where('UserId', isEqualTo: userId)
          .where('GroupId', isEqualTo: groupId)
          .get()
          .then((value) => {
                value.docs.forEach((element) {
                  var id = element.reference.id;
                  _userGroupCollectionReference.doc(id).delete();
                })
              });

      final userPrayers = _followedPrayerCollectionReference
          .where('UserId', isEqualTo: userId)
          .get();
      userPrayers.then((value) {
        final prayers = value.docs
            .map((e) => FollowedPrayerModel.fromData(e.data(), e.id))
            .toList();
        prayers.forEach((element) {
          if (element.groupId == groupId) {
            _followedPrayerCollectionReference.doc(element.id).delete();
            _userPrayerCollectionReference.doc(element.userPrayerId).delete();
          }
        });
      });
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'GROUP/service/removeFromGroup');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  inviteMember(String groupName, String groupId, String email, String sender,
      String senderId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      var dio = Dio(BaseOptions(followRedirects: false));
      var user = await _userCollectionReference
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();
      if (user.docs.length == 0) {
        var errorMessage =
            'This email is not registered on Be Still! Please try with a registered email';
        locator<LogService>()
            .createLog(errorMessage, senderId, 'GROUP/service/inviteMember');
        throw HttpException(errorMessage);
      }
      var data = {
        'groupname': groupName,
        'groupid': groupId,
        'userid': user.docs[0].id,
        'email': email,
        'sender': sender,
        'senderId': senderId,
      };
      await dio.post(
        'https://us-central1-bestill-app.cloudfunctions.net/GroupInvite',
        data: data,
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), senderId,
          'GROUP/service/inviteMember');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future updateGroupSettings(
      {required String key,
      required dynamic value,
      required String groupSettingsId}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _groupSettingsCollectionReference.doc(groupSettingsId).update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          groupSettingsId, 'SETTINGS/service/updateGroupSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<bool> addGroupSettings(
      String userId, String groupId, bool requireAdminApproval) async {
    final groupSettingsId = Uuid().v1();

    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      _groupSettingsCollectionReference.doc(groupSettingsId).set(
          populateGroupSettings(
                  userId, groupId, requireAdminApproval, groupSettingsId)
              .toJson());
      return true;
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'SETTINGS/service/addGroupSettings');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  GroupSettings populateGroupSettings(
      String userId, String groupId, bool requireAdminApproval, String id) {
    GroupSettings groupsSettings = GroupSettings(
        id: id,
        requireAdminApproval: requireAdminApproval,
        groupId: groupId,
        userId: userId,
        enableNotificationFormNewPrayers: false,
        enableNotificationForUpdates: false,
        notifyOfMembershipRequest: false,
        notifyMeofFlaggedPrayers: false,
        notifyWhenNewMemberJoins: false,
        createdBy: userId,
        createdOn: DateTime.now(),
        modifiedBy: userId,
        modifiedOn: DateTime.now());
    return groupsSettings;
  }
}
