import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/group_settings_model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../locator.dart';

class GroupService {
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

  GroupUserModel populateGroupUser(
    // GroupModel groupData,
    String userID,
    String groupID,
    String role,
    String creator,
    String fullName,
    // String email
  ) {
    GroupUserModel userPrayer = GroupUserModel(
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

  GroupRequestModel populateGroupRequest(String userId, String status,
      String createdBy, DateTime createdOn, String groupId, String id) {
    GroupRequestModel groupRequest = GroupRequestModel(
        id: id,
        userId: userId,
        groupId: groupId,
        status: status,
        createdBy: createdBy,
        createdOn: createdOn);
    return groupRequest;
  }

  Stream<List<CombineGroupUserStream>> _combineAllGroupsStream;
  Stream<List<CombineGroupUserStream>> getAllGroups(String userId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _combineAllGroupsStream =
          _groupCollectionReference.snapshots().map((convert) {
        return convert.docs.map((g) {
          Stream<GroupModel> group = Stream.value(g)
              .map<GroupModel>((document) => GroupModel.fromData(document));
          Stream<List<GroupUserModel>> groupUsers =
              _userGroupCollectionReference
                  .where('GroupId', isEqualTo: g.id)
                  .snapshots()
                  .asyncMap((e) => e.docs
                      .map((doc) => GroupUserModel.fromData(doc))
                      .toList());

          Stream<List<GroupRequestModel>> groupRequests =
              _groupRequestCollectionReference
                  .where('GroupId', isEqualTo: g.id)
                  .snapshots()
                  .asyncMap((e) => e.docs
                      .map((doc) => GroupRequestModel.fromData(doc))
                      .toList());
          Stream<List<GroupSettings>> groupSettings =
              _groupSettingsCollectionReference
                  .where('GroupId', isEqualTo: g.id)
                  .snapshots()
                  .asyncMap((e) {
            if (e.docs.length == 0) {
              addGroupSettings(userId, g.id);
              return [
                GroupSettings(
                    allowAutoJoin: false,
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
            return e.docs.map((doc) => GroupSettings.fromData(doc)).toList();
          });
          return Rx.combineLatest4(
              groupUsers,
              group,
              groupRequests,
              groupSettings,
              (
                groupUsers,
                group,
                groupRequests,
                groupSettings,
              ) =>
                  CombineGroupUserStream(
                    groupUsers,
                    group,
                    groupRequests,
                    groupSettings[0],
                  ));
        });
      }).switchMap((observables) {
        return observables.length > 0
            ? Rx.combineLatestList(observables)
            : Stream.value([]);
      });
      return _combineAllGroupsStream;
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/getAllGroups');
      throw HttpException(e.message);
    }
  }

  Stream<CombineGroupUserStream> getGroup(String groupdId, String userId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      final c = _groupCollectionReference.doc(groupdId).snapshots().map((g) {
        // return convert.map((g) {
        Stream<GroupModel> group = Stream.value(g)
            .map<GroupModel>((document) => GroupModel.fromData(document));
        Stream<List<GroupUserModel>> groupUsers = _userGroupCollectionReference
            .where('GroupId', isEqualTo: g.id)
            .snapshots()
            .asyncMap((e) =>
                e.docs.map((doc) => GroupUserModel.fromData(doc)).toList());

        Stream<List<GroupRequestModel>> groupRequests =
            _groupRequestCollectionReference
                .where('GroupId', isEqualTo: g.id)
                .snapshots()
                .asyncMap((e) => e.docs
                    .map((doc) => GroupRequestModel.fromData(doc))
                    .toList());
        Stream<List<GroupSettings>> groupSettings =
            _groupSettingsCollectionReference
                .where('GroupId', isEqualTo: g.id)
                .snapshots()
                .asyncMap((e) {
          if (e.docs.length == 0) {
            addGroupSettings(userId, g.id);
            return [
              GroupSettings(
                  allowAutoJoin: false,
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
          return e.docs.map((doc) => GroupSettings.fromData(doc)).toList();
        });
        return Rx.combineLatest4(
            groupUsers,
            group,
            groupRequests,
            groupSettings,
            (groupUsers, group, groupRequests, groupSettings) =>
                CombineGroupUserStream(
                    groupUsers, group, groupRequests, groupSettings[0]));
        // });
      }).switchMap((observables) {
        return observables;
      });
      return c;
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          groupdId,
          'GROUP/service/getAllGroups');
      throw HttpException(e.message);
    }
  }

  Stream<List<CombineGroupUserStream>> _combineUserGroupStream;
  Stream<List<CombineGroupUserStream>> getUserGroups(String userId) {
    try {
      _combineUserGroupStream = _userGroupCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((convert) {
        return convert.docs.map((f) {
          Stream<GroupModel> group = _groupCollectionReference
              .doc(f['GroupId'])
              .snapshots()
              .map<GroupModel>((document) => GroupModel.fromData(document));
          Stream<List<GroupUserModel>> groupUsers =
              _userGroupCollectionReference
                  .where('GroupId', isEqualTo: f['GroupId'])
                  .snapshots()
                  .asyncMap((e) => e.docs
                      .map((doc) => GroupUserModel.fromData(doc))
                      .toList());
          Stream<List<GroupSettings>> groupSettings =
              _groupSettingsCollectionReference
                  .where('GroupId', isEqualTo: f['GroupId'])
                  .snapshots()
                  .asyncMap((e) {
            if (e.docs.length == 0) {
              addGroupSettings(userId, f['GroupId']);
              return [
                GroupSettings(
                    allowAutoJoin: false,
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
            return e.docs.map((doc) => GroupSettings.fromData(doc)).toList();
          });

          Stream<List<GroupRequestModel>> groupRequests =
              _groupRequestCollectionReference
                  .where('GroupId', isEqualTo: f['GroupId'])
                  .snapshots()
                  .asyncMap((e) => e.docs
                      .map((doc) => GroupRequestModel.fromData(doc))
                      .toList());
          return Rx.combineLatest4(
              groupUsers,
              group,
              groupRequests,
              groupSettings,
              (
                groupUsers,
                group,
                groupRequests,
                groupSettings,
              ) =>
                  CombineGroupUserStream(
                    groupUsers,
                    group,
                    groupRequests,
                    groupSettings[0],
                  ));
        });
      }).switchMap((observables) {
        return observables.length > 0
            ? Rx.combineLatestList(observables)
            : Stream.value([]);
      });

      return _combineUserGroupStream;
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/getUserGroups');
      throw HttpException(e.message);
    }
  }

  Stream<CombineGroupUserStream> getUserGroupById(
      String userGroupId, String userId) {
    try {
      final data = _userGroupCollectionReference.doc(userGroupId).snapshots();
      // .map((convert) {
      return data.map((f) {
        Stream<GroupModel> group = _groupCollectionReference
            .doc(f['GroupId'])
            .snapshots()
            .map<GroupModel>((document) => GroupModel.fromData(document));
        Stream<List<GroupUserModel>> groupUsers = _userGroupCollectionReference
            .where('GroupId', isEqualTo: f['GroupId'])
            .snapshots()
            .asyncMap((e) =>
                e.docs.map((doc) => GroupUserModel.fromData(doc)).toList());

        Stream<List<GroupRequestModel>> groupRequests =
            _groupRequestCollectionReference
                .where('GroupId', isEqualTo: f['GroupId'])
                .snapshots()
                .asyncMap((e) => e.docs
                    .map((doc) => GroupRequestModel.fromData(doc))
                    .toList());
        Stream<List<GroupSettings>> groupSettings =
            _groupSettingsCollectionReference
                .where('GroupId', isEqualTo: f['GroupId'])
                .snapshots()
                .asyncMap((e) {
          if (e.docs.length == 0) {
            addGroupSettings(userId, f['GroupId']);
            return [
              GroupSettings(
                  userId: userId,
                  groupId: f['GroupId'],
                  allowAutoJoin: false,
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
          return e.docs.map((doc) => GroupSettings.fromData(doc)).toList();
        });
        return Rx.combineLatest4(
            groupUsers,
            group,
            groupRequests,
            groupSettings,
            (
              groupUsers,
              group,
              groupRequests,
              groupSettings,
            ) =>
                CombineGroupUserStream(
                    groupUsers, group, groupRequests, groupSettings[0]));
      }).switchMap((observables) {
        return observables;
      });
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userGroupId,
          'GROUP/service/getUserGroups');
      throw HttpException(e.message);
    }
  }

  Future<String> addGroup(String userId, GroupModel groupData, String fullName,
      String userGroupId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;

      _groupCollectionReference
          .doc(groupData.id)
          .set(populateGroup(groupData, groupData.id).toJson());
      // FirebaseFirestore.instance
      //     .collection("Group/" + groupData.id + "/Users")
      //     .add({'userId': userId});

      _userGroupCollectionReference.doc(userGroupId).set(populateGroupUser(
            // groupData,
            userId,
            groupData.id,
            GroupUserRole.admin,
            groupData.createdBy,
            fullName,
          ).toJson());
      //store group settings

      addGroupSettings(userId, groupData.id);
      return userGroupId;
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/addGroup');
      throw HttpException(e.message);
    }
  }

  Future editGroup(
    GroupModel groupData,
    String groupID,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupCollectionReference.doc(groupID).update(
        {
          "Name": groupData.name,
          "Description": groupData.description,
          // "Email": groupData.email,
          "Organization": groupData.organization,
          "Location": groupData.location,
          "Status": groupData.status,
          "IsPrivate": groupData.isPrivate,
          "IsFeed": groupData.isFeed,
          "ModifiedOn": DateTime.now()
        },
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          groupID,
          'GROUP/service/editGroup');
      throw HttpException(e.message);
    }
  }

  joinRequest(
    String groupId,
    String userId,
    String status,
    String createdBy,
  ) async {
    try {
      final _requestID = Uuid().v1();
      if (_firebaseAuth.currentUser == null) return null;
      _groupRequestCollectionReference.doc(_requestID).set(populateGroupRequest(
              userId, status, createdBy, DateTime.now(), groupId, _requestID)
          .toJson());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/joinRequest');
      throw HttpException(e.message);
    }
  }

  acceptRequest(String groupId, GroupModel groupData, String userId,
      String requestId, String fullName) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      final _userGroupId = Uuid().v1();
      // _groupCollectionReference
      //     .doc(groupId)
      //     .collection('Users')
      //     .doc(_groupUserId)
      //     .set(populateGroupUser(
      //             groupData, userId, groupId, GroupUserRole.member)
      //         .toJson());
      _userGroupCollectionReference.doc(_userGroupId).set(populateGroupUser(
            // groupData,
            userId,
            groupId,
            GroupUserRole.member,
            userId,
            fullName,
          ).toJson());
      _groupRequestCollectionReference
          .doc(requestId)
          .update({"Status": StringUtils.joinRequestStatusApproved});
      // await addGroupUserReference(groupId, userId);

    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/acceptRequest');
      throw HttpException(e.message);
    }
  }

  autoJoinGroup(String groupId, String userId, String fullName) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      final _userGroupId = Uuid().v1();
      _userGroupCollectionReference.doc(_userGroupId).set(populateGroupUser(
            userId,
            groupId,
            GroupUserRole.member,
            userId,
            fullName,
          ).toJson());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/autoJoinGroup');
      throw HttpException(e.message);
    }
  }

  denyRequest(String groupId, String requestId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupRequestCollectionReference
          .doc(requestId)
          .update({"Status": StringUtils.joinRequestStatusDenied});
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          requestId,
          'GROUP/service/denyRequest');
      throw HttpException(e.message);
    }
  }

  leaveGroup(String userGroupId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _userGroupCollectionReference.doc(userGroupId).delete();
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userGroupId,
          'GROUP/service/leaveGroup');
      throw HttpException(e.message);
    }
  }

  deleteGroup(String groupId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;

      _groupCollectionReference.doc(groupId).delete();
      _userGroupCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      });
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          groupId,
          'GROUP/service/deleteGroup');
      throw HttpException(e.message);
    }
  }

  deleteFromGroup(String userId, String groupId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
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
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/removeFromGroup');
      throw HttpException(e.message);
    }
  }

  inviteMember(String groupName, String groupId, String email, String sender,
      String senderId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
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
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          senderId,
          'GROUP/service/inviteMember');
      throw HttpException(e.message);
    }
  }

  Future updateGroupSettings(
      {String key, dynamic value, String groupSettingsId}) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupSettingsCollectionReference.doc(groupSettingsId).update(
        {key: value},
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message, groupSettingsId, 'SETTINGS/service/updateGroupSettings');
      throw HttpException(e.message);
    }
  }

  Future<bool> addGroupSettings(String userId, String groupId) async {
    final groupSettingsId = Uuid().v1();

    try {
      if (_firebaseAuth.currentUser == null) return null;

      _groupSettingsCollectionReference
          .doc(groupSettingsId)
          .set(populateGroupSettings(userId, groupId).toJson());
      return true;
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'SETTINGS/service/addGroupSettings');
      throw HttpException(e.message);
    }
  }

  populateGroupSettings(String userId, String groupId) {
    GroupSettings groupsSettings = GroupSettings(
        allowAutoJoin: false,
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
