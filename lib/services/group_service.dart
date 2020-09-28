import 'package:be_still/models/group.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class GroupService {
  final CollectionReference _groupCollectionReference =
      Firestore.instance.collection("Group");
  final CollectionReference _groupUserCollectionReference =
      Firestore.instance.collection("UserGroup");

  Stream<List<CombineGroupUserStream>> _combineStream;
  Stream<List<CombineGroupUserStream>> fetchGroups(String userId) {
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
      if (e is PlatformException) {
        print(e.message);
      }
      return null;
    }
  }

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
        modifiedOn: groupData.modifiedOn);
    return userPrayer;
  }

  addGroup(String userID, GroupModel groupData) {
    // Generate uuid
    final _groupID = Uuid().v1();
    final _groupUserID = Uuid().v1();
    try {
      return Firestore.instance.runTransaction(
        (transaction) async {
          // store prayer
          await transaction.set(
              _groupCollectionReference.document(_groupID), groupData.toJson());

          //store user prayer
          await transaction.set(
              _groupUserCollectionReference.document(_groupUserID),
              populateGroupUser(groupData, userID, _groupID).toJson());
        },
      ).then((val) {
        return true;
      }).catchError((e) {
        if (e is PlatformException) {
          return e.message;
        }
        return e.toString();
      });
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }
}
