import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/settings_service.dart';
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
      _groupUserCollectionReference =
      FirebaseFirestore.instance.collection("GroupUser");
  final CollectionReference<Map<String, dynamic>> _userCollectionReference =
      FirebaseFirestore.instance.collection("User");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  populateGroupUser(
    GroupModel groupData,
    String userID,
    String fullName,
    String groupID,
  ) {
    GroupUserModel userPrayer = GroupUserModel(
      userId: userID,
      status: Status.active,
      groupId: groupID,
      isAdmin: true,
      isModerator: true,
      fullName: fullName,
      createdBy: groupData.createdBy,
      createdOn: groupData.createdOn,
      modifiedBy: groupData.modifiedBy,
      modifiedOn: groupData.modifiedOn,
    );
    return userPrayer;
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
              _groupUserCollectionReference
                  .where('GroupId', isEqualTo: g.id)
                  .snapshots()
                  .asyncMap((e) => e.docs
                      .map((doc) => GroupUserModel.fromData(doc))
                      .toList());

          return Rx.combineLatest2(groupUsers, group,
              (groupUsers, group) => CombineGroupUserStream(groupUsers, group));
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
      if (_firebaseAuth.currentUser == null) return null;
      _combineUserGroupStream = _groupUserCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((convert) {
        return convert.docs.map((f) {
          Stream<GroupModel> group = _groupCollectionReference
              .doc(f['GroupId'])
              .snapshots()
              .map<GroupModel>((document) => GroupModel.fromData(document));
          Stream<List<GroupUserModel>> groupUsers =
              _groupUserCollectionReference
                  .where('GroupId', isEqualTo: f['GroupId'])
                  .snapshots()
                  .asyncMap((e) => e.docs
                      .map((doc) => GroupUserModel.fromData(doc))
                      .toList());

          return Rx.combineLatest2(groupUsers, group,
              (groupUsers, group) => CombineGroupUserStream(groupUsers, group));
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

  addGroup(String userId, GroupModel groupData, String fullName,
      String email) async {
    final _groupID = Uuid().v1();
    final _groupUserId = Uuid().v1();
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var batch = FirebaseFirestore.instance.batch();

      batch.set(_groupCollectionReference.doc(_groupID), groupData.toJson());

      //store group user
      batch.set(_groupUserCollectionReference.doc(_groupUserId),
          populateGroupUser(groupData, userId, fullName, _groupID).toJson());
      //store group settings

      await locator<SettingsService>()
          .addGroupSettings(userId, email, _groupID);

      await batch.commit();
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/addGroup');
      throw HttpException(e.message);
    }
  }

  Stream<QuerySnapshot> getGroupUsers(String groupId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var users = _groupUserCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .snapshots();
      return users;
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          groupId,
          'GROUP/service/getGroupUsers');
      throw HttpException(e.message);
    }
  }

  leaveGroup(String userGroupId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupUserCollectionReference.doc(userGroupId).delete();
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userGroupId,
          'GROUP/service/leaveGroup');
      throw HttpException(e.message);
    }
  }

  deleteGroup(String userGroupId, String groupId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupUserCollectionReference.doc(userGroupId).delete();
      _groupCollectionReference.doc(groupId).delete();
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userGroupId,
          'GROUP/service/deleteGroup');
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

  joinRequest(String groupId, String userId, String userName) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var dio = Dio(BaseOptions(followRedirects: false));
      var data = {
        'groupId': groupId,
        'userId': userId,
        'userName': userName,
      };
      print(data);
      await dio.post(
        'https://us-central1-bestill-app.cloudfunctions.net/JoinRequest',
        data: data,
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/joinRequest');
      throw HttpException(e.message);
    }
  }

  acceptInvite(String groupId, String userId, String email, String name) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var dio = Dio();
      await dio.post(
        'https://us-central1-bestill-app.cloudfunctions.net/InviteAcceptance',
        data: {
          'groupId': groupId,
          'userId': userId,
          'email': email,
          'name': name,
        },
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'GROUP/service/acceptInvite');
      throw HttpException(e.message);
    }
  }
}
