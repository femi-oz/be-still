import 'dart:io';

import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

class PrayerService {
  final CollectionReference _prayerCollectionReference =
      FirebaseFirestore.instance.collection("Prayer");
  final CollectionReference _userPrayerCollectionReference =
      FirebaseFirestore.instance.collection("UserPrayer");
  final CollectionReference _groupPrayerCollectionReference =
      FirebaseFirestore.instance.collection("GroupPrayer");
  final CollectionReference _prayerUpdateCollectionReference =
      FirebaseFirestore.instance.collection("PrayerUpdate");
  final CollectionReference _hiddenPrayerCollectionReference =
      FirebaseFirestore.instance.collection("HiddenPrayer");
  final CollectionReference _userCollectionReference =
      FirebaseFirestore.instance.collection("User");

  Stream<List<CombinePrayerStream>> _combineStream;
  Stream<List<CombinePrayerStream>> getPrayers(String userId) {
    try {
      _combineStream = _userPrayerCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((convert) {
        return convert.docs.map((f) {
          Stream<UserPrayerModel> userPrayer = Stream.value(f)
              .map<UserPrayerModel>((doc) => UserPrayerModel.fromData(doc));

          Stream<PrayerModel> prayer = _prayerCollectionReference
              .doc(f.data()['PrayerId'])
              .snapshots()
              .map<PrayerModel>((doc) => PrayerModel.fromData(doc));

          Stream<List<PrayerUpdateModel>> updates =
              _prayerUpdateCollectionReference
                  // .doc(f.data()['PrayerId'])
                  .where('PrayerId', isEqualTo: f.data()['PrayerId'])
                  .snapshots()
                  .map<List<PrayerUpdateModel>>((list) => list.docs
                      .map((e) => PrayerUpdateModel.fromData(e))
                      .toList());

          return Rx.combineLatest3(
              userPrayer,
              prayer,
              updates,
              (UserPrayerModel userPrayer, PrayerModel prayer,
                      List<PrayerUpdateModel> updates) =>
                  CombinePrayerStream(
                    prayer: prayer,
                    updates: updates,
                    userPrayer: userPrayer,
                  ));
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
        status: Status.active,
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
        status: Status.active,
        sequence: null,
        prayerId: prayerID,
        isFavorite: false,
        createdBy: prayerData.createdBy,
        createdOn: prayerData.createdOn,
        modifiedBy: prayerData.modifiedBy,
        modifiedOn: prayerData.modifiedOn);
    return userPrayer;
  }

  populateGroupPrayerByGroupID(
      PrayerModel prayerData, String prayerID, String groupID) {
    GroupPrayerModel userPrayer = GroupPrayerModel(
        groupId: groupID,
        status: Status.active,
        sequence: null,
        prayerId: prayerID,
        isFavorite: false,
        createdBy: prayerData.createdBy,
        createdOn: prayerData.createdOn,
        modifiedBy: prayerData.modifiedBy,
        modifiedOn: prayerData.modifiedOn);
    return userPrayer;
  }

  // Future prayerRequestMessage(
  //   PrayerRequestMessageModel prayerRequestData,
  // ) async {
  //   try {
  //     return FirebaseFirestore.instance.runTransaction(
  //       (transaction) async {
  //         transaction.set(
  //             _prayerRequestMessageCollectionReference
  //                 .doc(prayerRequestData.senderId),
  //             prayerRequestData.toJson());
  //       },
  //     ).then((value) {
  //       return true;
  //     }).catchError((e) {
  //       throw HttpException(e.message);
  //     });
  //   } catch (e) {
  //     throw HttpException(e.message);
  //   }
  // }

  messageRequestor(PrayerRequestMessageModel requestMessageModel) async {
    try {
      var dio = Dio(BaseOptions(followRedirects: false));
      var user = await _userCollectionReference
          .where('Email', isEqualTo: requestMessageModel.email)
          .limit(1)
          .get();
      if (user.docs.length == 0) {
        throw HttpException(
            'This email is not registered on BeStill! Please try with a registered email');
      }
      var data = {
        'recieverId': requestMessageModel.receiverId,
        'receiver': requestMessageModel.receiver,
        'message': user.docs[0].id,
        'email': requestMessageModel.email,
        'sender': requestMessageModel.sender,
        'senderId': user.docs[0].id,
      };
      await dio.post(
        'https://us-central1-bestill-app.cloudfunctions.net/SendMessage',
        data: data,
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  tagPrayer(
      String prayerId, String userId, String tagger, String taggerId) async {
    try {
      var dio = Dio(BaseOptions(followRedirects: false));
      var data = {
        'prayerId': prayerId,
        'userId': userId,
        'tagger': tagger,
        'taggerId': taggerId,
      };
      await dio.post(
        'https://us-central1-bestill-app.cloudfunctions.net/PrayerTag',
        data: data,
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future addPrayer(
    PrayerModel prayerData,
    String _userID,
  ) async {
    // Generate uuid
    final _prayerID = Uuid().v1();
    final _userPrayerID = Uuid().v1();

    try {
      var batch = FirebaseFirestore.instance.batch();
      // return FirebaseFirestore.instance.runTransaction(
      // (transaction) async {
      // store prayer
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store user prayer
      batch.set(_userPrayerCollectionReference.doc(_userPrayerID),
          populateUserPrayer(prayerData, _userID, _prayerID).toJson());
      // }
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

  Future addPrayerWithGroup(
    BuildContext context,
    PrayerModel prayerData,
    List groups,
    String _userID,
  ) async {
    // Generate uuid
    final _prayerID = Uuid().v1();
    final _userPrayerID = Uuid().v1();

    try {
      var batch = FirebaseFirestore.instance.batch();
      // return FirebaseFirestore.instance.runTransaction(
      //   (transaction) async {
      // store prayer
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store user prayer
      batch.set(_userPrayerCollectionReference.doc(_userPrayerID),
          populateUserPrayer(prayerData, _userID, _prayerID).toJson());

      for (var groupId in groups) {
        var groupPrayerId = Uuid().v1();
        batch.set(
            _groupPrayerCollectionReference.doc(groupPrayerId),
            populateGroupPrayerByGroupID(prayerData, _prayerID, groupId)
                .toJson());
      }
      //   },
      // ).then((val) {
      //   for (var groupId in groups) {
      //     Provider.of<NotificationProvider>(context, listen: false)
      //         .newPrayerGroupNotification(_prayerID, groupId);
      //   }
      // }).catchError((e) {
      //   throw HttpException(e.message);
      // });
      await batch.commit();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<List<CombinePrayerStream>> _combineGroupStream;
  Stream<List<CombinePrayerStream>> getGroupPrayers(String groupId) {
    print(groupId);
    try {
      _combineGroupStream = _groupPrayerCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .snapshots()
          .map((convert) {
        return convert.docs.map((f) {
          Stream<GroupPrayerModel> groupPrayer = Stream.value(f)
              .map<GroupPrayerModel>((doc) => GroupPrayerModel.fromData(doc));

          Stream<PrayerModel> prayer = _prayerCollectionReference
              .doc(f.data()['PrayerId'])
              .snapshots()
              .map<PrayerModel>((doc) => PrayerModel.fromData(doc));
          Stream<List<PrayerUpdateModel>> updates =
              _prayerUpdateCollectionReference
                  .where('PrayerId', isEqualTo: f.data()['PrayerId'])
                  .snapshots()
                  .map<List<PrayerUpdateModel>>((list) => list.docs
                      .map((e) => PrayerUpdateModel.fromData(e))
                      .toList());

          return Rx.combineLatest3(
            groupPrayer,
            prayer,
            updates,
            (GroupPrayerModel groupPrayer, PrayerModel prayer,
                    List<PrayerUpdateModel> updates) =>
                CombinePrayerStream(
              groupPrayer: groupPrayer,
              prayer: prayer,
              updates: updates,
            ),
          );
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
    BuildContext context,
    PrayerModel prayerData,
  ) async {
    // Generate uuid
    final _prayerID = Uuid().v1();
    final groupPrayerId = Uuid().v1();
    try {
      var batch = FirebaseFirestore.instance.batch();
      // return FirebaseFirestore.instance.runTransaction(
      //   (transaction) async {
      // store prayer
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store group prayer
      batch.set(_groupPrayerCollectionReference.doc(groupPrayerId),
          populateGroupPrayer(prayerData, _prayerID).toJson());
      //   },
      // ).then((val) {
      //   Provider.of<NotificationProvider>(context, listen: false)
      //       .newPrayerGroupNotification(_prayerID, prayerData.groupId);
      // }).catchError((e) {
      //   throw HttpException(e.message);
      // });
      await batch.commit();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future addPrayerToGroup(PrayerModel prayerData, List selectedGroups) async {
    // Generate uuid
    final _prayerID = Uuid().v1();
    final groupPrayerId = Uuid().v1();
    try {
      var batch = FirebaseFirestore.instance.batch();
      // return FirebaseFirestore.instance.runTransaction(
      //   (transaction) async {
      // store prayer
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store group prayer
      batch.set(_groupPrayerCollectionReference.doc(groupPrayerId),
          populateGroupPrayer(prayerData, _prayerID).toJson());
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

  Future editPrayer(
    String description,
    String prayerID,
  ) async {
    try {
      _prayerCollectionReference.doc(prayerID).update(
        {"Description": description},
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future addPrayerUpdate(
    PrayerUpdateModel prayerupdate,
  ) async {
    try {
      final updateId = Uuid().v1();
      _prayerUpdateCollectionReference.doc(updateId).set(
            prayerupdate.toJson(),
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
          .asyncMap((event) =>
              event.docs.map((e) => PrayerUpdateModel.fromData(e)).toList());
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
          .asyncMap((event) =>
              event.docs.map((e) => HiddenPrayerModel.fromData(e)).toList());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future markPrayerAsAnswered(String prayerID) async {
    try {
      _prayerCollectionReference.doc(prayerID).update(
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
      _prayerCollectionReference.doc(prayerID).update(
        {'IsArchived': true},
      );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future deletePrayer(String prayerID) async {
    try {
      var batch = FirebaseFirestore.instance.batch();
      // return FirebaseFirestore.instance.runTransaction((transaction) async {
      batch.delete(_prayerCollectionReference.doc(prayerID));
      final userPrayerRes = await _userPrayerCollectionReference
          .where("PrayerId", isEqualTo: prayerID)
          .limit(1)
          .get();
      batch
          .delete(_userPrayerCollectionReference.doc(userPrayerRes.docs[0].id));
      await batch.commit();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  hidePrayer(String prayerId, UserModel user) {
    final hiddenPrayerId = Uuid().v1();
    var hiddenPrayer = HiddenPrayerModel(
      userId: user.id,
      prayerId: prayerId,
      createdBy: user.id,
      createdOn: DateTime.now(),
      modifiedBy: user.id,
      modifiedOn: DateTime.now(),
    );
    try {
      _hiddenPrayerCollectionReference
          .doc(hiddenPrayerId)
          .set(hiddenPrayer.toJson());
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
          .doc(prayerId)
          .update({'HideFromAllMembers': value});
      // });
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<DocumentSnapshot> getPrayer(String prayerID) {
    try {
      return _prayerCollectionReference.doc(prayerID).snapshots();
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future addPrayerToMyList(UserPrayerModel userPrayer) async {
    try {
      final userPrayerId = Uuid().v1();
      return await _userPrayerCollectionReference
          .doc(userPrayerId)
          .set(userPrayer.toJson());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  flagAsInappropriate(String prayerId) {
    try {
      _prayerCollectionReference
          .doc(prayerId)
          .update({'IsInappropriate': true});
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
