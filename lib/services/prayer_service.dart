import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user_prayer.model.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

class PrayerService {
  final CollectionReference _prayerCollectionReference =
      Firestore.instance.collection("Prayer");
  final CollectionReference _userPrayerCollectionReference =
      Firestore.instance.collection("UserPrayer");
  final CollectionReference _groupPrayerCollectionReference =
      Firestore.instance.collection("GroupPrayer");

  // final CollectionReference _prayerDisableCollectionRefernce =
  //     Firestore.instance.collection("PrayerDisable");

  Stream<List<CombinePrayerStream>> _combineStream;
  Stream<List<CombinePrayerStream>> fetchPrayers(String userId) {
    try {
      _combineStream = _userPrayerCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((convert) {
        return convert.documents.map((f) {
          Stream<UserPrayerModel> userPrayer = Stream.value(f)
              .map<UserPrayerModel>(
                  (document) => UserPrayerModel.fromData(document));

          Stream<PrayerModel> prayer = _prayerCollectionReference
              .document(f.data['PrayerId'])
              .snapshots()
              .map<PrayerModel>((document) => PrayerModel.fromData(document));

          return Rx.combineLatest2(userPrayer, prayer,
              (userPrayer, prayer) => CombinePrayerStream(userPrayer, prayer));
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

  Stream<List<CombineGroupPrayerStream>> _combineGroupStream;
  Stream<List<CombineGroupPrayerStream>> fetchGroupPrayers(String groupId) {
    print(groupId);
    try {
      _combineGroupStream = _groupPrayerCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .snapshots()
          .map((convert) {
        return convert.documents.map((f) {
          Stream<GroupPrayerModel> groupPrayer = Stream.value(f)
              .map<GroupPrayerModel>(
                  (document) => GroupPrayerModel.fromData(document));

          Stream<PrayerModel> prayer = _prayerCollectionReference
              .document(f.data['PrayerId'])
              .snapshots()
              .map<PrayerModel>((document) => PrayerModel.fromData(document));

          return Rx.combineLatest2(
              groupPrayer,
              prayer,
              (groupPrayer, prayer) =>
                  CombineGroupPrayerStream(prayer, groupPrayer));
        });
      }).switchMap((observables) {
        return observables.length > 0
            ? Rx.combineLatestList(observables)
            : Stream.value([]);
      });
      return _combineGroupStream;
    } catch (e) {
      if (e is PlatformException) {
        print(e.message);
      }
      return null;
    }
  }

  populateUserPrayer(
    PrayerModel prayerData,
    String userID,
    String prayerID,
  ) {
    UserPrayerModel userPrayer = UserPrayerModel(
        userId: userID,
        status: 'Active',
        sequence: null,
        prayerId: prayerID,
        isFavorite: false,
        createdBy: prayerData.createdBy,
        createdOn: prayerData.createdOn,
        modifiedBy: prayerData.modifiedBy,
        modifiedOn: prayerData.modifiedOn);
    return userPrayer;
  }

  populateGroupPrayer(
    PrayerModel prayerData,
    String prayerID,
  ) {
    GroupPrayerModel userPrayer = GroupPrayerModel(
        groupId: prayerData.groupId,
        status: 'Active',
        sequence: null,
        prayerId: prayerID,
        isFavorite: false,
        createdBy: prayerData.createdBy,
        createdOn: prayerData.createdOn,
        modifiedBy: prayerData.modifiedBy,
        modifiedOn: prayerData.modifiedOn);
    return userPrayer;
  }

  Future addPrayer(
    PrayerModel prayerData,
    String _userID,
  ) async {
    // Generate uuid
    final _prayerID = Uuid().v1();
    final _userPrayerID = Uuid().v1();

    try {
      return Firestore.instance.runTransaction(
        (transaction) async {
          // store prayer
          await transaction.set(_prayerCollectionReference.document(_prayerID),
              prayerData.toJson());

          //store user prayer
          await transaction.set(
              _userPrayerCollectionReference.document(_userPrayerID),
              populateUserPrayer(prayerData, _userID, _prayerID).toJson());
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

  Future addGroupPrayer(
    PrayerModel prayerData,
  ) async {
    // Generate uuid
    final _prayerID = Uuid().v1();
    final _userPrayerID = Uuid().v1();

    try {
      return Firestore.instance.runTransaction(
        (transaction) async {
          // store prayer
          await transaction.set(_prayerCollectionReference.document(_prayerID),
              prayerData.toJson());

          //store user prayer
          await transaction.set(
              _groupPrayerCollectionReference.document(prayerData.groupId),
              populateGroupPrayer(prayerData, _prayerID).toJson());
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

  Future editPrayer(
    String description,
    String prayerID,
  ) async {
    try {
      _prayerCollectionReference.document(prayerID).updateData(
        {"Description": description},
      );
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future markPrayerAsAnswered(String prayerID) async {
    try {
      _prayerCollectionReference.document(prayerID).updateData(
        {'IsAnswer': true},
      );
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future archivePrayer(
    String prayerID,
  ) async {
    try {
      _prayerCollectionReference.document(prayerID).updateData(
        {'Status': 'Inactive'},
      );
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future deletePrayer(String prayerID) async {
    try {
      return Firestore.instance.runTransaction((transaction) async {
        await transaction.delete(_prayerCollectionReference.document(prayerID));
        final userPrayerRes = await _userPrayerCollectionReference
            .where("PrayerId", isEqualTo: prayerID)
            .limit(1)
            .getDocuments();
        await transaction.delete(_userPrayerCollectionReference
            .document(userPrayerRes.documents[0].documentID));
      }).then((val) {
        return true;
      }).catchError((e) {
        if (e is PlatformException) {
          return e.message;
        }
        return e.toString();
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  hidePrayer(String prayerId) {
    try {
      _prayerCollectionReference
          .document(prayerId)
          .updateData({'HideFromMe': true});
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  hideFromAllMembers(String prayerId, String groupId) {
    try {
      _prayerCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .snapshots()
          .map((event) {
        _prayerCollectionReference
            .document(prayerId)
            .updateData({'HideFromAllMembers': true});
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // hidePrayer(PrayerDisableModel prayerDisable) {
  //   final prayerDisableId = Uuid().v1();
  //   try {
  //     return Firestore.instance.runTransaction((transaction) async {
  //       await transaction.set(
  //           _prayerDisableCollectionRefernce.document(prayerDisableId),
  //           prayerDisable.toJson());
  //     }).then((value) {
  //       return true;
  //     }).catchError((e) {
  //       if (e is PlatformException) {
  //         return e.message;
  //       }
  //       return e.toString();
  //     });
  //   } catch (e) {
  //     if (e is PlatformException) {
  //       return e.message;
  //     }
  //     return e.toString();
  //   }
  // }

  // populatePrayerDisable(String userId, PrayerDisableModel prayerDisableData) {
  //   PrayerDisableModel hidePrayer = PrayerDisableModel(
  //       prayerId: prayerDisableData.prayerId,
  //       userId: userId,
  //       createdBy: prayerDisableData.createdBy,
  //       createdOn: prayerDisableData.createdOn,
  //       modifiedBy: prayerDisableData.modifiedBy,
  //       modifiedOn: prayerDisableData.modifiedOn);
  //   return hidePrayer;
  // }

  Stream<DocumentSnapshot> fetchPrayer(String prayerID) {
    try {
      return _prayerCollectionReference.document(prayerID).snapshots();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  flagAsInappropriate(String prayerId) {
    try {
      _prayerCollectionReference
          .document(prayerId)
          .updateData({'IsInappropriate': true});
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }
}
