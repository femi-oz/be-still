import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';

import '../locator.dart';

class GroupService {
  final CollectionReference _groupCollectionReference =
      FirebaseFirestore.instance.collection("Group");
  final CollectionReference _groupUserCollectionReference =
      FirebaseFirestore.instance.collection("GroupUser");
  final CollectionReference _userCollectionReference =
      FirebaseFirestore.instance.collection("User");
  // final CollectionReference _groupPrayerCollectionReference =
  //     Firestore.instance.collection("GroupPrayer");

  // final CollectionReference _groupInviteCollectionRefernce =
  //     Firestore.instance.collection("GroupInvite");

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
      throw HttpException(e.message);
    }
  }

  Stream<List<CombineGroupUserStream>> _combineUserGroupStream;
  Stream<List<CombineGroupUserStream>> getUserGroups(String userId) {
    try {
      _combineUserGroupStream = _groupUserCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((convert) {
        return convert.docs.map((f) {
          // Stream<GroupUserModel> userGroup = Stream.value(f)
          //     .map<GroupUserModel>(
          //         (document) => GroupUserModel.fromData(document));

          Stream<GroupModel> group = _groupCollectionReference
              .doc(f.data()['GroupId'])
              .snapshots()
              .map<GroupModel>((document) => GroupModel.fromData(document));
          Stream<List<GroupUserModel>> groupUsers =
              _groupUserCollectionReference
                  .where('GroupId', isEqualTo: f.data()['GroupId'])
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
      throw HttpException(e.message);
    }
  }

  addGroup(String userID, GroupModel groupData, String fullName) async {
    // Generate uuid
    final _groupID = Uuid().v1();
    final _groupUserID = Uuid().v1();
    try {
      var batch = FirebaseFirestore.instance.batch();
      // return FirebaseFirestore.instance.runTransaction(
      //   (transaction) async {
      // store group
      batch.set(_groupCollectionReference.doc(_groupID), groupData.toJson());

      //store group user
      batch.set(_groupUserCollectionReference.doc(_groupUserID),
          populateGroupUser(groupData, userID, fullName, _groupID).toJson());
      //store group settings

      var user = await locator<UserService>().getCurrentUser();

      await locator<SettingsService>()
          .addGroupSettings(userID, user.email, _groupID);
      //   },
      // ).then((val) {
      //   return true;
      // }).catchError((e) {
      //   throw HttpException(e.message);
      // });
      await batch.commit();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<QuerySnapshot> getGroupUsers(String groupId) {
    try {
      var users = _groupUserCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .snapshots();
      return users;
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  leaveGroup(String userGroupId) {
    try {
      _groupUserCollectionReference.doc(userGroupId).delete();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  deleteGroup(String userGroupId, String groupId) {
    try {
      _groupUserCollectionReference.doc(userGroupId).delete();
      _groupCollectionReference.doc(groupId).delete();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  inviteMember(String groupName, String groupId, String email, String sender,
      String senderId) async {
    try {
      var dio = Dio(BaseOptions(followRedirects: false));
      var user = await _userCollectionReference
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();
      if (user.docs.length == 0) {
        throw HttpException(
            'This email is not registered on BeStill! Please try with a registered email');
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
      throw HttpException(e.message);
    }
  }

  joinRequest(String groupId, String userId, String userName) async {
    try {
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
      throw HttpException(e.message);
    }
  }

//   Future updateMemberType(String userId, String groupId) async {
//     try {
//       _groupCollectionReference
//           .where('UserId', isEqualTo: userId)
//           .snapshots()
//           .map((event) {
//         _groupCollectionReference
//             .document(groupId)
//             .updateData({'IsAdmin': '1'});
//       });
//     } catch (e) {
//       throw HttpException(e.message);
//     }
//   }

  acceptInvite(String groupId, String userId, String email, String name) async {
    try {
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
      throw HttpException(e.message);
    }
  }

//   Future removeMemberFromGroup(String userId, String groupId) async {
  //   try {
  //     return Firestore.instance.runTransaction((transaction) async {
  //       final userGroupRes = await _groupUserCollectionReference
  //           .where("GroupId", isEqualTo: groupId)
  //           .where("UserId", isEqualTo: userId)
  //           .limit(1)
  //           .getDocuments();
  //       await transaction.delete(_groupUserCollectionReference
  //           .document(userGroupRes.documents[0].id));
  //     }).then((value) {
  //       return true;
  //     }).catchError((e) {
  //       throw HttpException(e.message);
  //     });
  //   } catch (e) {
  //     throw HttpException(e.message);
  //   }
  // }
}
