import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/models/user_prayer.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class PrayerService {
  final CollectionReference _prayerCollectionReference =
      Firestore.instance.collection("Prayer");
  final CollectionReference _userPrayerCollectionReference =
      Firestore.instance.collection("UserPrayer");

  Future fetchPrayers(UserModel user) async {
    try {
      return _prayerCollectionReference
          .where('UserId', isEqualTo: user.id)
          .where('Status', isEqualTo: 'Active')
          .where('IsAnswer', isEqualTo: false)
          .snapshots();
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future fetchArchivedPrayers(UserModel user) async {
    try {
      return _prayerCollectionReference
          .where('UserId', isEqualTo: user.id)
          .where('Status', isEqualTo: 'Inactive')
          .snapshots();
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future fetchAnsweredPrayers(UserModel user) async {
    try {
      return _prayerCollectionReference
          .where('UserId', isEqualTo: user.id)
          .where('IsAnswer', isEqualTo: true)
          .snapshots();
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
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

  Future editPrayer(
    PrayerModel prayerData,
    String prayerID,
  ) async {
    try {
      _prayerCollectionReference.document(prayerID).updateData(
            prayerData.toJson(),
          );
      // return Firestore.instance.runTransaction(
      //   (transaction) async {
      // store prayer
      // await transaction.update(
      //     _prayerCollectionReference.document(prayerID),
      //     prayerData.toJson());

      //store user prayer
      // await transaction.set(
      //     _userPrayerCollectionReference.document(_userPrayerID),
      //     populateUserPrayer(prayerData, _userID, _prayerID).toJson());
      // },
      // ).then((val) {
      //   return true;
      // }).catchError((e) {
      //   if (e is PlatformException) {
      //     return e.message;
      //   }
      //   return e.toString();
      // });
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

  Stream<DocumentSnapshot> fetchPrayer(String prayerID) {
    try {
      return _prayerCollectionReference.document(prayerID).snapshots();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
