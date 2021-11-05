import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/log_service.dart';
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
      _userGroupCollectionReference =
      FirebaseFirestore.instance.collection("UserGroup");

  final CollectionReference<Map<String, dynamic>> _userCollectionReference =
      FirebaseFirestore.instance.collection("User");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserGroupModel populateGroupUser(GroupModel groupData, String userID,
      String groupID, String role, String creator) {
    UserGroupModel userPrayer = UserGroupModel(
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
      email: groupData.email,
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

          Stream<List<GroupRequestModel>> groupRequests = FirebaseFirestore
              .instance
              .collection("Group/" + g.id + "/Requests")
              .snapshots()
              .asyncMap((e) => e.docs
                  .map((doc) => GroupRequestModel.fromData(doc))
                  .toList());

          return Rx.combineLatest3(
              groupUsers,
              group,
              groupRequests,
              (
                groupUsers,
                group,
                groupRequests,
              ) =>
                  CombineGroupUserStream(
                    groupUsers,
                    group,
                    groupRequests,
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

          Stream<List<GroupRequestModel>> groupRequests = FirebaseFirestore
              .instance
              .collection("Group/" + f.id + "/Requests")
              .snapshots()
              .asyncMap((e) => e.docs
                  .map((doc) => GroupRequestModel.fromData(doc))
                  .toList());
          return Rx.combineLatest3(
              groupUsers,
              group,
              groupRequests,
              (
                groupUsers,
                group,
                groupRequests,
              ) =>
                  CombineGroupUserStream(
                    groupUsers,
                    group,
                    groupRequests,
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

  Future<void> addGroup(
      String userId, GroupModel groupData, String email) async {
    // final _groupID = Uuid().v1();
    final _userGroupId = Uuid().v1();
    try {
      if (_firebaseAuth.currentUser == null) return null;

      _groupCollectionReference
          .doc(groupData.id)
          .set(populateGroup(groupData, groupData.id).toJson());
      // FirebaseFirestore.instance
      //     .collection("Group/" + groupData.id + "/Users")
      //     .add({'userId': userId});

      _userGroupCollectionReference.doc(_userGroupId).set(populateGroupUser(
              groupData,
              userId,
              groupData.id,
              GroupUserRole.admin,
              groupData.createdBy)
          .toJson());
      return groupData.id;
      //store group settings

      // await locator<SettingsService>()
      //     .addGroupSettings(userId, email, groupData.id);
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
          "Email": groupData.email,
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
      _groupCollectionReference
          .doc(groupId)
          .collection('Requests')
          .doc(_requestID)
          .set(populateGroupRequest(userId, status, createdBy, DateTime.now(),
                  groupId, _requestID)
              .toJson());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/joinRequest');
      throw HttpException(e.message);
    }
  }

  acceptRequest(
    String groupId,
    GroupModel groupData,
    String userId,
    String requestId,
  ) async {
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
              groupData, userId, groupId, GroupUserRole.member, userId)
          .toJson());
      FirebaseFirestore.instance
          .collection("Group/" + groupId + "/Requests")
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

  denyRequest(String groupId, String requestId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      FirebaseFirestore.instance
          .collection("Group/" + groupId + "/Requests")
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
}
