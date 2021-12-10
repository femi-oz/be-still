import 'package:be_still/enums/message-template.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

class GroupPrayerService {
  final CollectionReference<Map<String, dynamic>> _prayerCollectionReference =
      FirebaseFirestore.instance.collection("Prayer");
  final CollectionReference<Map<String, dynamic>>
      _groupPrayerCollectionReference =
      FirebaseFirestore.instance.collection("GroupPrayer");
  final CollectionReference<Map<String, dynamic>>
      _prayerUpdateCollectionReference =
      FirebaseFirestore.instance.collection("PrayerUpdate");
  final CollectionReference<Map<String, dynamic>>
      _hiddenPrayerCollectionReference =
      FirebaseFirestore.instance.collection("HiddenPrayer");
  final CollectionReference<Map<String, dynamic>> _userCollectionReference =
      FirebaseFirestore.instance.collection("User");
  final CollectionReference<Map<String, dynamic>>
      _prayerTagCollectionReference =
      FirebaseFirestore.instance.collection("PrayerTag");
  final CollectionReference<Map<String, dynamic>>
      _messageTemplateCollectionReference =
      FirebaseFirestore.instance.collection("MessageTemplate");
  final CollectionReference<Map<String, dynamic>>
      _userPrayerCollectionReference =
      FirebaseFirestore.instance.collection("UserPrayer");
  final CollectionReference<Map<String, dynamic>>
      _followedPrayerCollectionReference =
      FirebaseFirestore.instance.collection("FollowedPrayer");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _notificationService = locator<NotificationService>();
  var newPrayerId;

  Stream<List<CombineGroupPrayerStream>> getPrayers(String groupId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return _groupPrayerCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .snapshots()
          .map((convert) {
        return convert.docs.map((f) {
          Stream<GroupPrayerModel> groupPrayer = Stream.value(f)
              .map<GroupPrayerModel>((doc) => GroupPrayerModel.fromData(doc));

          Stream<PrayerModel> prayer = _prayerCollectionReference
              .doc(f['PrayerId'])
              .snapshots()
              .map<PrayerModel>((doc) => PrayerModel.fromData(doc));

          Stream<List<PrayerUpdateModel>> updates =
              _prayerUpdateCollectionReference
                  .where('PrayerId', isEqualTo: f['PrayerId'])
                  .snapshots()
                  .map<List<PrayerUpdateModel>>((list) => list.docs
                      .map((e) => PrayerUpdateModel.fromData(e))
                      .toList());

          Stream<List<PrayerTagModel>> tags = _prayerTagCollectionReference
              .where('PrayerId', isEqualTo: f['PrayerId'])
              .snapshots()
              .map<List<PrayerTagModel>>((list) =>
                  list.docs.map((e) => PrayerTagModel.fromData(e)).toList());

          return Rx.combineLatest4(groupPrayer, prayer, updates, tags,
              (GroupPrayerModel groupPrayer, PrayerModel prayer,
                  List<PrayerUpdateModel> updates, List<PrayerTagModel> tags) {
            return CombineGroupPrayerStream(
              prayer: prayer,
              updates: updates,
              groupPrayer: groupPrayer,
              tags: tags,
            );
          });
        });
      }).switchMap((observables) {
        return observables.length > 0
            ? Rx.combineLatestList(observables)
            : Stream.value([]);
      });
      // return _combineStream;
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          groupId,
          'PRAYER/service/getPrayers');
      throw HttpException(e.message);
    }
  }

  Stream<CombineGroupPrayerStream> getPrayer(String prayerID) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var data = _groupPrayerCollectionReference.doc(prayerID).snapshots();
      return data.map((doc) {
        Stream<GroupPrayerModel> groupPrayer = Stream.value(doc)
            .map<GroupPrayerModel>((doc) => GroupPrayerModel.fromData(doc));

        Stream<PrayerModel> prayer = _prayerCollectionReference
            .doc(doc['PrayerId'])
            .snapshots()
            .map<PrayerModel>((doc) => PrayerModel.fromData(doc));

        Stream<List<PrayerUpdateModel>> updates =
            _prayerUpdateCollectionReference
                .where('PrayerId', isEqualTo: doc['PrayerId'])
                .snapshots()
                .map<List<PrayerUpdateModel>>((list) => list.docs
                    .map((e) => PrayerUpdateModel.fromData(e))
                    .toList());

        Stream<List<PrayerTagModel>> tags = _prayerTagCollectionReference
            .where('PrayerId', isEqualTo: doc['PrayerId'])
            .snapshots()
            .map<List<PrayerTagModel>>((list) =>
                list.docs.map((e) => PrayerTagModel.fromData(e)).toList());
        return Rx.combineLatest4(
            groupPrayer,
            prayer,
            updates,
            tags,
            (GroupPrayerModel groupPrayer,
                    PrayerModel prayer,
                    List<PrayerUpdateModel> updates,
                    List<PrayerTagModel> tags) =>
                CombineGroupPrayerStream(
                  prayer: prayer,
                  updates: updates,
                  groupPrayer: groupPrayer,
                  tags: tags,
                ));
      }).switchMap((observables) {
        return observables;
      });
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerID,
          'PRAYER/service/getPrayer');
      throw HttpException(e.message);
    }
  }

  Future<CombineGroupPrayerStream> getPrayerFuture(String prayerID) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var data = _groupPrayerCollectionReference.doc(prayerID).get();
      return data.then((doc) async {
        GroupPrayerModel groupPrayer = GroupPrayerModel.fromData(doc);
        PrayerModel prayer = await _prayerCollectionReference
            .doc(doc['PrayerId'])
            .get()
            .then<PrayerModel>((doc) => PrayerModel.fromData(doc));

        List<PrayerUpdateModel> updates = await _prayerUpdateCollectionReference
            .where('PrayerId', isEqualTo: doc['PrayerId'])
            .get()
            .then<List<PrayerUpdateModel>>((list) =>
                list.docs.map((e) => PrayerUpdateModel.fromData(e)).toList());

        List<PrayerTagModel> tags = await _prayerTagCollectionReference
            .where('PrayerId', isEqualTo: doc['PrayerId'])
            .get()
            .then<List<PrayerTagModel>>((list) =>
                list.docs.map((e) => PrayerTagModel.fromData(e)).toList());
        // return Rx.combineLatest4(
        //     groupPrayer,
        //     prayer,
        //     updates,
        //     tags,
        //     (GroupPrayerModel groupPrayer,
        //             PrayerModel prayer,
        //             List<PrayerUpdateModel> updates,
        //             List<PrayerTagModel> tags) =>
        //         CombineGroupPrayerStream(
        //           prayer: prayer,
        //           updates: updates,
        //           groupPrayer: groupPrayer,
        //           tags: tags,
        //         ));
        return CombineGroupPrayerStream(
          prayer: prayer,
          updates: updates,
          groupPrayer: groupPrayer,
          tags: tags,
        );
      });
      // .switchMap((observables) {
      //   return observables;
      // });
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerID,
          'PRAYER/service/getPrayer');
      throw HttpException(e.message);
    }
  }

  Future addPrayer(
    String prayerDesc,
    String groupId,
    String creatorName,
    String prayerDescBackup,
    String userId,
  ) async {
    newPrayerId = Uuid().v1();
    final userPrayerID = Uuid().v1();

    try {
      if (_firebaseAuth.currentUser == null) return null;
      // store prayer
      _prayerCollectionReference.doc(newPrayerId).set(
          populatePrayer(userId, prayerDesc, creatorName, prayerDescBackup)
              .toJson());

      //store user prayer
      _groupPrayerCollectionReference
          .doc(userPrayerID)
          .set(populateGroupPrayer(groupId, newPrayerId, groupId).toJson());
      return userPrayerID;
    } catch (e) {
      await locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          groupId,
          'PRAYER/service/addPrayer');
      throw HttpException(e.message);
    }
  }

  Future addPrayerTag(List<Contact> contactData, UserModel user, String message,
      String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      //store prayer Tag
      for (var i = 0; i < contactData.length; i++) {
        ///b70b8540-9860-11eb-8da1-dfaaff472e96

        final _prayerTagID = Uuid().v1();
        if (contactData[i] != null) {
          _prayerTagCollectionReference.doc(_prayerTagID).set(populatePrayerTag(
                  contactData[i], user.id, user.firstName, message, prayerId)
              .toJson());
          final template = await _messageTemplateCollectionReference
              .doc(MessageTemplateType.tagPrayer)
              .get();
          final phoneNumber = contactData[i].phones.length > 0
              ? contactData[i].phones.toList()[0].value
              : null;
          final email = contactData[i].emails.length > 0
              ? contactData[i].emails.toList()[0]?.value
              : null;

          _notificationService.addEmail(
            email: email,
            message: message,
            sender: user.firstName,
            senderId: user.id,
            template: MessageTemplate.fromData(template),
            receiver: contactData[i].displayName,
          );
          _notificationService.addSMS(
              phoneNumber: phoneNumber,
              message: message,
              sender: user.firstName,
              senderId: user.id,
              template: MessageTemplate.fromData(template),
              receiver: contactData[i].displayName);
        }
      }
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          user.id,
          'PRAYER/service/addPrayerTag');
      throw HttpException(e.message);
    }
  }

  Future removePrayerTag(String tagId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _prayerTagCollectionReference.doc(tagId).delete();
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          tagId,
          'PRAYER/service/removePrayerTag');
      throw HttpException(e.message);
    }
  }

  Future editPrayer(
    String description,
    String prayerID,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      newPrayerId = prayerID;
      _prayerCollectionReference.doc(prayerID).update(
        {"Description": description, "ModifiedOn": DateTime.now()},
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerID,
          'PRAYER/service/editPrayer');
      throw HttpException(e.message);
    }
  }

  Future editUpdate(String description, String prayerID) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _prayerUpdateCollectionReference.doc(prayerID).update(
        {"Description": description, "ModifiedOn": DateTime.now()},
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerID,
          'PRAYER/service/editPrayerUpdate');
      throw HttpException(e.message);
    }
  }

  Future addPrayerUpdate(String userId, String prayer, String prayerId) async {
    final prayerUpdate = PrayerUpdateModel(
      prayerId: prayerId,
      deleteStatus: 0,
      userId: userId,
      title: '',
      description: prayer,
      modifiedBy: userId,
      modifiedOn: DateTime.now(),
      createdBy: userId,
      createdOn: DateTime.now(),
      descriptionBackup: '',
    );
    try {
      if (_firebaseAuth.currentUser == null) return null;
      final updateId = Uuid().v1();
      prayerId = prayerId;
      await _prayerCollectionReference
          .doc(prayerId)
          .update({'ModifiedOn': DateTime.now()});

      _prayerUpdateCollectionReference.doc(updateId).set(
            prayerUpdate.toJson(),
          );
    } catch (e) {
      locator<LogService>().createLog(
          e.message, prayerUpdate.userId, 'PRAYER/service/addPrayerUpdate');
      throw HttpException(e.message);
    }
  }

  Stream<List<PrayerUpdateModel>> getPrayerUpdates(
    String prayerId,
  ) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return _prayerUpdateCollectionReference
          .where('PrayerId', isEqualTo: prayerId)
          .snapshots()
          .asyncMap((event) =>
              event.docs.map((e) => PrayerUpdateModel.fromData(e)).toList());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerId,
          'PRAYER/service/getPrayerUpdates');
      throw HttpException(e.message);
    }
  }

  Future snoozePrayer(DateTime endDate, String userPrayerID, int duration,
      String frequency) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupPrayerCollectionReference.doc(userPrayerID).update(
        {
          'IsFavourite': false,
          'IsSnoozed': true,
          'SnoozeEndDate': endDate,
          'Status': Status.inactive,
          'SnoozeDuration': duration,
          'SnoozeFrequency': frequency,
        },
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userPrayerID,
          'PRAYER/service/snoozePrayer');
      throw HttpException(e.message);
    }
  }

  Future unSnoozePrayer(DateTime endDate, String userPrayerID) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupPrayerCollectionReference.doc(userPrayerID).update(
        {
          'IsSnoozed': false,
          'Status': Status.active,
          'SnoozeEndDate': endDate,
          'SnoozeDuration': 0,
          'SnoozeFrequency': '',
        },
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userPrayerID,
          'PRAYER/service/unSnoozePrayer');
      throw HttpException(e.message);
    }
  }

  Future archivePrayer(
    String userPrayerId,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupPrayerCollectionReference.doc(userPrayerId).update(
        {
          'IsArchived': true,
          'Status': Status.inactive,
          'IsFavourite': false,
          'ArchivedDate': DateTime.now(),
          'IsSnoozed': false
        },
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userPrayerId,
          'PRAYER/service/archivePrayer');
      throw HttpException(e.message);
    }
  }

  Future unArchivePrayer(String userPrayerId, String prayerID) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _prayerCollectionReference.doc(prayerID).update(
        {'IsAnswer': false},
      );
      _groupPrayerCollectionReference.doc(userPrayerId).update({
        'IsArchived': false,
        'Status': Status.active,
        'ArchivedDate': null,
      });
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userPrayerId,
          'PRAYER/service/unArchivePrayer');
      throw HttpException(e.message);
    }
  }

  Future markPrayerAsAnswered(String prayerID, String userPrayerId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _prayerCollectionReference.doc(prayerID).update(
        {'IsAnswer': true},
      );
      final data = {
        'IsArchived': true,
        'Status': Status.inactive,
        'IsFavourite': false,
        'ArchivedDate': DateTime.now(),
        'IsSnoozed': false
      };
      _groupPrayerCollectionReference.doc(userPrayerId).update(data);
    } catch (e) {
      locator<LogService>().createLog(
          e.message, prayerID, 'PRAYER/service/markPrayerAsAnswered');
      throw HttpException(e.message);
    }
  }

  Future unMarkPrayerAsAnswered(String prayerID, String userPrayerId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _prayerCollectionReference.doc(prayerID).update(
        {'IsAnswer': false},
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message, prayerID, 'PRAYER/service/unMarkPrayerAsAnswered');
      throw HttpException(e.message);
    }
  }

  Future favoritePrayer(
    String prayerID,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupPrayerCollectionReference.doc(prayerID).update(
        {'IsFavourite': true},
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerID,
          'PRAYER/service/favoritePrayer');
      throw HttpException(e.message);
    }
  }

  Future unFavoritePrayer(
    String prayerID,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupPrayerCollectionReference.doc(prayerID).update(
        {'IsFavourite': false},
      );
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerID,
          'PRAYER/service/unFavoritePrayer');
      throw HttpException(e.message);
    }
  }

  Future deletePrayer(String userPrayeId, String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _groupPrayerCollectionReference
          .doc(userPrayeId)
          .update({'DeleteStatus': -1});
      _userPrayerCollectionReference
          .where('PrayerId', isEqualTo: prayerId)
          .get()
          .then((userPrayers) {
        userPrayers.docs.forEach((element) {
          element.reference.update({'DeleteStatus': -1});
        });
      });
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userPrayeId,
          'PRAYER/service/deletePrayer');
      throw HttpException(e.message);
    }
  }

  Future deleteUpdate(String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _prayerUpdateCollectionReference
          .doc(prayerId)
          .update({'DeleteStatus': -1});
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerId,
          'PRAYER/service/deletePrayerUpdate');
      throw HttpException(e.message);
    }
  }

//Group Prayers
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
      if (_firebaseAuth.currentUser == null) return null;
      _hiddenPrayerCollectionReference
          .doc(hiddenPrayerId)
          .set(hiddenPrayer.toJson());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          user.id,
          'PRAYER/service/hidePrayer');
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
      if (_firebaseAuth.currentUser == null) return null;
      var batch = FirebaseFirestore.instance.batch();
      // store prayer
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store group prayer
      batch.set(_groupPrayerCollectionReference.doc(_userPrayerID),
          populateGroupPrayer(_userID, _prayerID, _userID).toJson());

      for (var groupId in groups) {
        var groupPrayerId = Uuid().v1();
        batch.set(
            _groupPrayerCollectionReference.doc(groupPrayerId),
            populateGroupPrayerByGroupID(prayerData, _prayerID, groupId)
                .toJson());
      }
      await batch.commit();
    } catch (e) {
      locator<LogService>().createLog(
          e.message, prayerData.userId, 'PRAYER/service/addPrayerWithGroup');
      throw HttpException(e.message);
    }
  }

  Stream<List<CombinePrayerStream>> _combineGroupStream;
  Stream<List<CombinePrayerStream>> getGroupPrayers(String groupId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _combineGroupStream = _groupPrayerCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .snapshots()
          .map((convert) {
        return convert.docs.map((f) {
          Stream<GroupPrayerModel> groupPrayer = Stream.value(f)
              .map<GroupPrayerModel>((doc) => GroupPrayerModel.fromData(doc));

          Stream<PrayerModel> prayer = _prayerCollectionReference
              .doc(f['PrayerId'])
              .snapshots()
              .map<PrayerModel>((doc) => PrayerModel.fromData(doc));
          Stream<List<PrayerUpdateModel>> updates =
              _prayerUpdateCollectionReference
                  .where('PrayerId', isEqualTo: f['PrayerId'])
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
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          groupId,
          'PRAYER/service/getGroupPrayers');
      throw HttpException(e.message);
    }
  }

  Stream<List<HiddenPrayerModel>> getHiddenPrayers(
    String userId,
  ) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return _hiddenPrayerCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .asyncMap((event) =>
              event.docs.map((e) => HiddenPrayerModel.fromData(e)).toList());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'PRAYER/service/getHiddenPrayers');
      throw HttpException(e.message);
    }
  }

  Future<List<FollowedPrayerModel>> getFollowedPrayers(String prayerId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return _followedPrayerCollectionReference
          .where('PrayerId', isEqualTo: prayerId)
          .get()
          .then((event) =>
              event.docs.map((e) => FollowedPrayerModel.fromData(e)).toList());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerId,
          'PRAYER/service/getFollowedPrayers');
      throw HttpException(e.message);
    }
  }

  Future<List<FollowedPrayerModel>> getFollowedPrayersByGroupId(
      String groupId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return _followedPrayerCollectionReference
          .where('GroupId', isEqualTo: groupId)
          .get()
          .then((event) =>
              event.docs.map((e) => FollowedPrayerModel.fromData(e)).toList());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          groupId,
          'PRAYER/service/getFollowedPrayersByGroupId');
      throw HttpException(e.message);
    }
  }

  Future<List<FollowedPrayerModel>> getFollowedPrayersByUserId(String userId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      return _followedPrayerCollectionReference
          .where('UserId', isEqualTo: userId)
          .get()
          .then((event) =>
              event.docs.map((e) => FollowedPrayerModel.fromData(e)).toList());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'PRAYER/service/getFollowedPrayersByUserId');
      throw HttpException(e.message);
    }
  }

  hideFromAllMembers(String prayerId, bool value) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _prayerCollectionReference
          .doc(prayerId)
          .update({'HideFromAllMembers': value});
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerId,
          'PRAYER/service/hideFromAllMembers');
      throw HttpException(e.message);
    }
  }

  messageRequestor(PrayerRequestMessageModel requestMessageModel) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var dio = Dio(BaseOptions(followRedirects: false));
      var user = await _userCollectionReference
          .where('Email', isEqualTo: requestMessageModel.email)
          .limit(1)
          .get();
      if (user.docs.length == 0) {
        throw HttpException(
            'This email is not registered on Be Still! Please try with a registered email');
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
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          requestMessageModel.senderId,
          'PRAYER/service/messageRequestor');
      throw HttpException(e.message);
    }
  }

  Future addToMyList(String prayerId, String userId, String groupId) async {
    final userPrayerID = Uuid().v1();
    final followedPrayerID = Uuid().v1();

    try {
      if (_firebaseAuth.currentUser == null) return null;
      //store user prayer
      _userPrayerCollectionReference
          .doc(userPrayerID)
          .set(populateUserPrayer(userId, prayerId).toJson());
      _followedPrayerCollectionReference.doc(followedPrayerID).set(
          populateFollowedPrayer(userId, prayerId, userPrayerID, groupId)
              .toJson());
    } catch (e) {
      await locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          userId,
          'PRAYER/service/addPrayer');
      throw HttpException(e.message);
    }
  }

  Future removeFromMyList(String followedPrayerId, String userPrayerId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _followedPrayerCollectionReference.doc(followedPrayerId).delete();
      await _userPrayerCollectionReference.doc(userPrayerId).delete();
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          followedPrayerId,
          'PRAYER/service/removeFromMyList');
      throw HttpException(e.message);
    }
  }

  flagAsInappropriate(String prayerId) {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _prayerCollectionReference
          .doc(prayerId)
          .update({'IsInappropriate': true});
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          prayerId,
          'PRAYER/service/flagAsInappropriate');
      throw HttpException(e.message);
    }
  }

  populateFollowedPrayer(
      String userId, String prayerId, String userPrayerId, String groupId) {
    FollowedPrayerModel followedPrayer = FollowedPrayerModel(
        prayerId: prayerId,
        userId: userId,
        createdBy: userId,
        createdOn: DateTime.now(),
        modifiedBy: userId,
        modifiedOn: DateTime.now(),
        userPrayerId: userPrayerId,
        groupId: groupId);
    return followedPrayer;
  }

  populateUserPrayer(String userId, String prayerID) {
    UserPrayerModel userPrayer = UserPrayerModel(
      deleteStatus: 0,
      isArchived: false,
      archivedDate: null,
      userId: userId,
      snoozeDuration: 0,
      snoozeFrequency: '',
      status: Status.active,
      sequence: null,
      prayerId: prayerID,
      isFavorite: false,
      isSnoozed: false,
      snoozeEndDate: DateTime.now(),
      createdBy: userId,
      createdOn: DateTime.now(),
      modifiedBy: userId,
      modifiedOn: DateTime.now(),
    );
    return userPrayer;
  }

  populatePrayer(
    String userId,
    String prayerDesc,
    String creatorName,
    String prayerDescBackup,
  ) {
    PrayerModel prayer = PrayerModel(
      isAnswer: false,
      isGroup: true,
      isInappropriate: false,
      title: '',
      type: '',
      userId: userId,
      status: Status.active,
      creatorName: creatorName,
      description: prayerDesc,
      descriptionBackup: prayerDescBackup,
      groupId: '0',
      createdBy: userId,
      createdOn: DateTime.now(),
      modifiedBy: userId,
      modifiedOn: DateTime.now(),
    );
    return prayer;
  }

  populateGroupPrayer(
    String groupId,
    String prayerID,
    String creatorId,
  ) {
    GroupPrayerModel userPrayer = GroupPrayerModel(
        groupId: groupId,
        status: Status.active,
        sequence: null,
        isSnoozed: false,
        isArchived: false,
        prayerId: prayerID,
        isFavorite: false,
        archivedDate: DateTime.now(),
        snoozeEndDate: DateTime.now(),
        snoozeDuration: 0,
        snoozeFrequency: '',
        createdBy: creatorId,
        createdOn: DateTime.now(),
        deleteStatus: 0,
        modifiedBy: creatorId,
        modifiedOn: DateTime.now());
    return userPrayer;
  }

  populateNotificationId(String notificationId) {
    return notificationId;
  }

  PrayerTagModel populatePrayerTag(Contact contact, String userId,
      String sender, String message, String prayerId) {
    PrayerTagModel prayerTag = PrayerTagModel(
      userId: userId,
      prayerId: prayerId == '' ? newPrayerId : prayerId,
      displayName: contact.displayName,
      identifier: contact.identifier,
      phoneNumber:
          contact.phones.length > 0 ? contact.phones.toList()[0].value : null,
      email:
          contact.emails.length > 0 ? contact.emails.toList()[0]?.value : null,
      message: message,
      tagger: sender,
      createdBy: sender,
      createdOn: DateTime.now(),
      modifiedBy: sender,
      modifiedOn: DateTime.now(),
    );
    return prayerTag;
  }

  populateGroupPrayerByGroupID(
      PrayerModel prayerData, String prayerID, String groupID) {
    GroupPrayerModel userPrayer = GroupPrayerModel(
        groupId: groupID,
        isArchived: false,
        status: Status.active,
        sequence: null,
        prayerId: prayerID,
        isFavorite: false,
        archivedDate: DateTime.now(),
        snoozeEndDate: DateTime.now(),
        snoozeDuration: 0,
        snoozeFrequency: '',
        createdBy: prayerData.createdBy,
        isSnoozed: false,
        createdOn: prayerData.createdOn,
        modifiedBy: prayerData.modifiedBy,
        deleteStatus: 0,
        modifiedOn: prayerData.modifiedOn);
    return userPrayer;
  }
}
