import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/models/user_prayer.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

class PrayerService {
  final CollectionReference _prayerCollectionReference =
      Firestore.instance.collection("Prayer");
  final CollectionReference _userPrayerCollectionReference =
      Firestore.instance.collection("UserPrayer");
  final CollectionReference _groupPrayerCollectionReference =
      Firestore.instance.collection("GroupPrayer");
  final CollectionReference _prayerUpdateCollectionReference =
      Firestore.instance.collection("PrayerUpdate");
  final CollectionReference _hiddenPrayerCollectionReference =
      Firestore.instance.collection("HiddenPrayer");

  // final CollectionReference _prayerDisableCollectionRefernce =
  //     Firestore.instance.collection("PrayerDisable");

  Stream<List<CombinePrayerStream>> _combineStream;
  Stream<List<CombinePrayerStream>> getPrayers(String userId) {
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
      throw HttpException(e.message);
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
        throw HttpException(e.message);
      });
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<List<CombineGroupPrayerStream>> _combineGroupStream;
  Stream<List<CombineGroupPrayerStream>> getGroupPrayers(String groupId) {
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
      throw HttpException(e.message);
    }
  }

  Future addGroupPrayer(
    PrayerModel prayerData,
  ) async {
    // Generate uuid
    final _prayerID = Uuid().v1();
    final groupPrayerId = Uuid().v1();
    try {
      return Firestore.instance.runTransaction(
        (transaction) async {
          // store prayer
          await transaction.set(_prayerCollectionReference.document(_prayerID),
              prayerData.toJson());

          //store user prayer
          await transaction.set(
              _groupPrayerCollectionReference.document(groupPrayerId),
              populateGroupPrayer(prayerData, _prayerID).toJson());
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

  Future editPrayer(
    String description,
    String prayerID,
  ) async {
    try {
      _prayerCollectionReference.document(prayerID).updateData(
        {"Description": description},
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future addPrayerUpdate(
    PrayerUpdateModel prayerUpdateData,
  ) async {
    try {
      _prayerUpdateCollectionReference.document().setData(
            prayerUpdateData.toJson(),
          );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<List<PrayerUpdateModel>> getPrayerUpdates(
    String prayerId,
  ) {
    try {
      return _prayerUpdateCollectionReference
          .where('PrayerId', isEqualTo: prayerId)
          .snapshots()
          .asyncMap((event) => event.documents
              .map((e) => PrayerUpdateModel.fromData(e))
              .toList());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<List<HiddenPrayerModel>> getHiddenPrayers(
    String userId,
  ) {
    try {
      return _hiddenPrayerCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .asyncMap((event) => event.documents
              .map((e) => HiddenPrayerModel.fromData(e))
              .toList());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future markPrayerAsAnswered(String prayerID) async {
    try {
      _prayerCollectionReference.document(prayerID).updateData(
        {'IsAnswer': true},
      );
    } catch (e) {
      throw HttpException(e.message);
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
      throw HttpException(e.message);
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
        throw HttpException(e.message);
      });
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  hidePrayer(String prayerId, UserModel user) {
    final hiddenPrayerId = Uuid().v1();
    var hiddenPrayer = HiddenPrayerModel(
      userId: user.id,
      prayerId: prayerId,
      createdBy: '${user.firstName} ${user.lastName}',
      createdOn: DateTime.now(),
      modifiedBy: '${user.firstName} ${user.lastName}',
      modifiedOn: DateTime.now(),
    );
    try {
      _hiddenPrayerCollectionReference
          .document(hiddenPrayerId)
          .setData(hiddenPrayer.toJson());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  hideFromAllMembers(String prayerId, bool value) {
    try {
      // _prayerCollectionReference
      //     .where('GroupId', isEqualTo: groupId)
      //     .snapshots()
      //     .map((event) {
      _prayerCollectionReference
          .document(prayerId)
          .updateData({'HideFromAllMembers': value});
      // });
    } catch (e) {
      throw HttpException(e.message);
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

  Stream<DocumentSnapshot> getPrayer(String prayerID) {
    try {
      return _prayerCollectionReference.document(prayerID).snapshots();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future addPrayerToMyList(UserPrayerModel userPrayer) async {
    try {
      final userPrayerId = Uuid().v1();
      return await _userPrayerCollectionReference
          .document(userPrayerId)
          .setData(userPrayer.toJson());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  flagAsInappropriate(String prayerId) {
    try {
      _prayerCollectionReference
          .document(prayerId)
          .updateData({'IsInappropriate': true});
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
