import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class GroupService {
  final CollectionReference _groupCollectionReference =
      Firestore.instance.collection("Group");
  final CollectionReference _groupUserCollectionReference =
      Firestore.instance.collection("GroupUser");
  final CollectionReference _groupPrayerCollectionReference =
      Firestore.instance.collection("GroupPrayer");

  final CollectionReference _groupInviteCollectionRefernce =
      Firestore.instance.collection("GroupInvite");
  final CollectionReference _prayerCollectionReference =
      Firestore.instance.collection("Prayer");

  populateGroupUser(
    GroupModel groupData,
    String userID,
    String groupID,
  ) {
    GroupUserModel userPrayer = GroupUserModel(
      userId: userID,
      status: 'Active',
      groupId: groupID,
      isAdmin: true,
      isModerator: true,
      createdBy: groupData.createdBy,
      createdOn: groupData.createdOn,
      modifiedBy: groupData.modifiedBy,
      modifiedOn: groupData.modifiedOn,
    );
    return userPrayer;
  }

  Stream<List<CombineGroupUserStream>> _combineStream;
  Stream<List<CombineGroupUserStream>> getGroups(String userId) {
    try {
      _combineStream = _groupUserCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((convert) {
        return convert.documents.map((f) {
          Stream<GroupUserModel> userGroup = Stream.value(f)
              .map<GroupUserModel>(
                  (document) => GroupUserModel.fromData(document));

          Stream<GroupModel> group = _groupCollectionReference
              .document(f.data['GroupId'])
              .snapshots()
              .map<GroupModel>((document) => GroupModel.fromData(document));

          return Rx.combineLatest2(userGroup, group,
              (messages, user) => CombineGroupUserStream(messages, user));
        });
      }).switchMap((observables) {
        return observables.length > 0
            ? Rx.combineLatestList(observables)
            : Stream.value([]);
      });
      return _combineStream;
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  addGroup(String userID, GroupModel groupData) {
    // Generate uuid
    final _groupID = Uuid().v1();
    final _groupUserID = Uuid().v1();
    try {
      return Firestore.instance.runTransaction(
        (transaction) async {
          // store group
          await transaction.set(
              _groupCollectionReference.document(_groupID), groupData.toJson());

          //store group user
          await transaction.set(
              _groupUserCollectionReference.document(_groupUserID),
              populateGroupUser(groupData, userID, _groupID).toJson());
        },
      ).then((val) {
        return true;
      }).catchError((e) {
        throw HttpException(e.message);
      });
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<QuerySnapshot> getGroupUsers(String groupId) {
    try {
      return _groupUserCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .snapshots();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

//   populateGroupPrayer(UserModel userData, String groupPrayerID, String groupID,
//       GroupPrayerModel groupPrayerData) {
//     GroupPrayerModel groupPrayer = GroupPrayerModel(
//       id: groupPrayerID,
//       status: groupPrayerData.status,
//       groupId: groupID,
//       prayerId: groupPrayerData.prayerId,
//       sequence: groupPrayerData.sequence,
//       isFavorite: groupPrayerData.isFavorite,
//       createdBy: userData.createdBy,
//       createdOn: userData.createdOn,
//       modifiedBy: userData.modifiedBy,
//       modifiedOn: userData.modifiedOn,
//     );
//     return groupPrayer;
//   }

//   populateGroupInvite(GroupInviteModel groupInviteData, String groupInviteId,
//       String userId, String groupId, UserModel userData) {
//     GroupInviteModel groupInvite = GroupInviteModel(
//         id: groupInviteId,
//         userId: userId,
//         groupId: groupId,
//         status: groupInviteData.status,
//         createdBy: userData.createdBy,
//         createdOn: userData.createdOn,
//         modifiedBy: userData.modifiedBy,
//         modifiedOn: userData.modifiedOn);
//     return groupInvite;
//   }

//   inviteMember(GroupInviteModel groupInvite, String userId, String groupId,
//       UserModel userData) {
//     final groupInviteId = Uuid().v1();

//     try {
//       return Firestore.instance.runTransaction((transaction) async {
//         await transaction.set(
//             _groupInviteCollectionRefernce.document(groupInviteId),
//             populateGroupInvite(
//                     groupInvite, groupInviteId, userId, groupId, userData)
//                 .toJson());
//       }).then((value) {
//         return true;
//       }).catchError((e) {
//         throw HttpException(e.message);
//       });
//     } catch (e) {
//       throw HttpException(e.message);
//     }
//   }

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

//   acceptInvite(String groupId, String userId, String status) {
//     try {
//       _groupCollectionReference
//           .where('UserId', isEqualTo: userId)
//           .snapshots()
//           .map((event) {
//         _groupCollectionReference
//             .document(groupId)
//             .updateData({'Status': status});
//       });
//     } catch (e) {
//       throw HttpException(e.message);
//     }
//   }

//   Future removeMemberFromGroup(String userId, String groupId) async {
  //   try {
  //     return Firestore.instance.runTransaction((transaction) async {
  //       final userGroupRes = await _groupUserCollectionReference
  //           .where("GroupId", isEqualTo: groupId)
  //           .where("UserId", isEqualTo: userId)
  //           .limit(1)
  //           .getDocuments();
  //       await transaction.delete(_groupUserCollectionReference
  //           .document(userGroupRes.documents[0].documentID));
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
