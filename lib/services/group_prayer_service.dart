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
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

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
  String newPrayerId = '';

  Stream<List<CombineGroupPrayerStream>> getPrayers(String groupId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _groupPrayerCollectionReference
          .where('DeleteStatus', isEqualTo: 0)
          .where('GroupId', isEqualTo: groupId)
          .snapshots()
          .map((convert) {
        return convert.docs.map((f) {
          Stream<GroupPrayerModel> groupPrayer = Stream.value(f)
              .map<GroupPrayerModel>(
                  (doc) => GroupPrayerModel.fromData(doc.data(), doc.id));

          Stream<PrayerModel> prayer = _prayerCollectionReference
              .doc(f['PrayerId'])
              .snapshots()
              .map<PrayerModel>(
                  (doc) => PrayerModel.fromData(doc.data()!, doc.id));

          Stream<List<PrayerUpdateModel>> updates =
              _prayerUpdateCollectionReference
                  .where('PrayerId', isEqualTo: f['PrayerId'])
                  .snapshots()
                  .map<List<PrayerUpdateModel>>((list) => list.docs
                      .map((e) => PrayerUpdateModel.fromData(e.data(), e.id))
                      .toList());

          Stream<List<PrayerTagModel>> tags = _prayerTagCollectionReference
              .where('PrayerId', isEqualTo: f['PrayerId'])
              .snapshots()
              .map<List<PrayerTagModel>>((list) => list.docs
                  .map((e) => PrayerTagModel.fromData(e.data(), e.id))
                  .toList());

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
          StringUtils.getErrorMessage(e), groupId, 'PRAYER/service/getPrayers');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<CombineGroupPrayerStream> getPrayer(String groupPrayerId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _groupPrayerCollectionReference
          .doc(groupPrayerId)
          .snapshots()
          .map((_doc) {
        Stream<GroupPrayerModel> groupPrayer = Stream.value(_doc)
            .map<GroupPrayerModel>(
                (doc) => GroupPrayerModel.fromData(doc.data()!, doc.id));
        Stream<PrayerModel> prayer = _prayerCollectionReference
            .doc(_doc['PrayerId'])
            .snapshots()
            .map<PrayerModel>(
                (doc) => PrayerModel.fromData(doc.data()!, doc.id));
        Stream<List<PrayerUpdateModel>> updates =
            _prayerUpdateCollectionReference
                .where('PrayerId', isEqualTo: _doc['PrayerId'])
                .snapshots()
                .map<List<PrayerUpdateModel>>((list) => list.docs
                    .map((e) => PrayerUpdateModel.fromData(e.data(), e.id))
                    .toList());

        Stream<List<PrayerTagModel>> tags = _prayerTagCollectionReference
            .where('PrayerId', isEqualTo: _doc['PrayerId'])
            .snapshots()
            .map<List<PrayerTagModel>>((list) => list.docs
                .map((e) => PrayerTagModel.fromData(e.data(), e.id))
                .toList());
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
      // return _combineStream;
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          groupPrayerId, 'PRAYER/service/getPrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<CombineGroupPrayerStream> getPrayerFuture(String prayerID) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      var data = _groupPrayerCollectionReference.doc(prayerID).get();
      return data.then((_doc) async {
        GroupPrayerModel groupPrayer =
            GroupPrayerModel.fromData(_doc.data()!, _doc.id);
        PrayerModel prayer = await _prayerCollectionReference
            .doc(_doc['PrayerId'])
            .get()
            .then<PrayerModel>(
                (doc) => PrayerModel.fromData(doc.data()!, doc.id));

        List<PrayerUpdateModel> updates = await _prayerUpdateCollectionReference
            .where('PrayerId', isEqualTo: _doc['PrayerId'])
            .get()
            .then<List<PrayerUpdateModel>>((list) => list.docs
                .map((e) => PrayerUpdateModel.fromData(e.data(), e.id))
                .toList());

        List<PrayerTagModel> tags = await _prayerTagCollectionReference
            .where('PrayerId', isEqualTo: _doc['PrayerId'])
            .get()
            .then<List<PrayerTagModel>>((list) => list.docs
                .map((e) => PrayerTagModel.fromData(e.data(), e.id))
                .toList());

        return CombineGroupPrayerStream(
          prayer: prayer,
          updates: updates,
          groupPrayer: groupPrayer,
          tags: tags,
        );
      });
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), prayerID, 'PRAYER/service/getPrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
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
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      // store prayer
      _prayerCollectionReference.doc(newPrayerId).set(populatePrayer(
              userId, prayerDesc, creatorName, prayerDescBackup, newPrayerId)
          .toJson());

      //store user prayer
      _groupPrayerCollectionReference.doc(userPrayerID).set(
          populateGroupPrayer(groupId, newPrayerId, groupId, userPrayerID)
              .toJson());
      return userPrayerID;
    } catch (e) {
      await locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), groupId, 'PRAYER/service/addPrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future addPrayerTag(List<Contact> contactData, UserModel user, String message,
      String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      //store prayer Tag
      for (var i = 0; i < contactData.length; i++) {
        final _prayerTagID = Uuid().v1();
        // if (contactData[i] != null) {
        _prayerTagCollectionReference.doc(_prayerTagID).set(populatePrayerTag(
                contactData[i],
                user.id ?? '',
                user.firstName ?? '',
                message,
                prayerId,
                _prayerTagID)
            .toJson());
        final template = await _messageTemplateCollectionReference
            .doc(MessageTemplateType.tagPrayer)
            .get();
        final phoneNumber = (contactData[i].phones ?? []).length > 0
            ? (contactData[i].phones ?? []).toList()[0].value
            : null;
        final email = (contactData[i].emails ?? []).length > 0
            ? (contactData[i].emails ?? []).toList()[0].value
            : null;

        _notificationService.addEmail(
          title: '',
          email: email ?? '',
          message: message,
          sender: user.firstName ?? '',
          senderId: user.id ?? '',
          template: MessageTemplate.fromData(template.data()!, template.id),
          receiver: contactData[i].displayName ?? '',
        );
        _notificationService.addSMS(
            title: '',
            phoneNumber: phoneNumber ?? '',
            message: message,
            sender: user.firstName ?? '',
            senderId: user.id ?? '',
            template: MessageTemplate.fromData(template.data()!, template.id),
            receiver: contactData[i].displayName ?? '');
        // }
      }
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          user.id ?? '', 'PRAYER/service/addPrayerTag');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future removePrayerTag(String tagId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      _prayerTagCollectionReference.doc(tagId).delete();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), tagId,
          'PRAYER/service/removePrayerTag');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  // Future editPrayer(
  //   String description,
  //   String prayerID,
  // ) async {
  //   try {
  //     if (_firebaseAuth.currentUser == null)
  //       return Stream.error(StringUtils.unathorized);
  //     newPrayerId = prayerID;
  //     _prayerCollectionReference.doc(prayerID).update(
  //       {"Description": description, "ModifiedOn": DateTime.now()},
  //     );
  //   } catch (e) {
  //     locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerID,
  //         'PRAYER/service/editPrayer');
  //     throw HttpException(StringUtils.getErrorMessage(e));
  //   }
  // }

  // Future editUpdate(String description, String prayerID) async {
  //   try {
  //     if (_firebaseAuth.currentUser == null)
  //       return Stream.error(StringUtils.unathorized);
  //     _prayerUpdateCollectionReference.doc(prayerID).update(
  //       {"Description": description, "ModifiedOn": DateTime.now()},
  //     );
  //   } catch (e) {
  //     locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerID,
  //         'PRAYER/service/editPrayerUpdate');
  //     throw HttpException(StringUtils.getErrorMessage(e));
  //   }
  // }

  // Future addPrayerUpdate(String userId, String prayer, String prayerId) async {
  //   final updateId = Uuid().v1();
  //   final prayerUpdate = PrayerUpdateModel(
  //     id: updateId,
  //     prayerId: prayerId,
  //     deleteStatus: 0,
  //     userId: userId,
  //     title: '',
  //     description: prayer,
  //     modifiedBy: userId,
  //     modifiedOn: DateTime.now(),
  //     createdBy: userId,
  //     createdOn: DateTime.now(),
  //     descriptionBackup: '',
  //   );
  //   try {
  //     if (_firebaseAuth.currentUser == null)
  //       return Stream.error(StringUtils.unathorized);

  //     prayerId = prayerId;
  //     await _prayerCollectionReference
  //         .doc(prayerId)
  //         .update({'ModifiedOn': DateTime.now()});

  //     _prayerUpdateCollectionReference.doc(updateId).set(
  //           prayerUpdate.toJson(),
  //         );
  //   } catch (e) {
  //     locator<LogService>().createLog(StringUtils.getErrorMessage(e),
  //         prayerUpdate.userId ?? '', 'PRAYER/service/addPrayerUpdate');
  //     throw HttpException(StringUtils.getErrorMessage(e));
  //   }
  // }

  Stream<List<PrayerUpdateModel>> getPrayerUpdates(
    String prayerId,
  ) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _prayerUpdateCollectionReference
          .where('PrayerId', isEqualTo: prayerId)
          .snapshots()
          .asyncMap((event) => event.docs
              .map((e) => PrayerUpdateModel.fromData(e.data(), e.id))
              .toList());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerId,
          'PRAYER/service/getPrayerUpdates');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future snoozePrayer(DateTime endDate, String userPrayerID, int duration,
      String frequency) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
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
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          userPrayerID, 'PRAYER/service/snoozePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future unSnoozePrayer(DateTime endDate, String userPrayerID) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
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
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          userPrayerID, 'PRAYER/service/unSnoozePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future archivePrayer(
    String groupPrayerId,
    String prayerId,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      _groupPrayerCollectionReference.doc(groupPrayerId).update(
        {
          'IsArchived': true,
          'Status': Status.inactive,
          'IsFavourite': false,
          'ArchivedDate': DateTime.now(),
          'IsSnoozed': false
        },
      );
      final x = await _followedPrayerCollectionReference
          .where('PrayerId', isEqualTo: prayerId)
          .get();
      x.docs.forEach((element) {
        final f = FollowedPrayerModel.fromData(element.data(), element.id);
        _userPrayerCollectionReference
            .doc(f.userPrayerId)
            .update({'DeleteStatus': -1});
        // element.reference.delete();
      });
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          groupPrayerId, 'PRAYER/service/archivePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future unArchivePrayer(String userPrayerId, String prayerID) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      _prayerCollectionReference.doc(prayerID).update(
        {'IsAnswer': false},
      );
      _groupPrayerCollectionReference.doc(userPrayerId).update({
        'IsArchived': false,
        'Status': Status.active,
        'ArchivedDate': null,
      });
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          userPrayerId, 'PRAYER/service/unArchivePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future markPrayerAsAnswered(String prayerID, String groupPrayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
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
      _groupPrayerCollectionReference.doc(groupPrayerId).update(data);
      final x = await _followedPrayerCollectionReference
          .where('PrayerId', isEqualTo: prayerID)
          .get();
      x.docs.forEach((element) {
        final f = FollowedPrayerModel.fromData(element.data(), element.id);
        _userPrayerCollectionReference
            .doc(f.userPrayerId)
            .update({'DeleteStatus': -1});
        // element.reference.delete();
      });
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerID,
          'PRAYER/service/markPrayerAsAnswered');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future unMarkPrayerAsAnswered(String prayerID, String userPrayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      _prayerCollectionReference.doc(prayerID).update(
        {'IsAnswer': false},
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerID,
          'PRAYER/service/unMarkPrayerAsAnswered');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future favoritePrayer(
    String prayerID,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      _groupPrayerCollectionReference.doc(prayerID).update(
        {'IsFavourite': true},
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerID,
          'PRAYER/service/favoritePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future unFavoritePrayer(
    String prayerID,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      _groupPrayerCollectionReference.doc(prayerID).update(
        {'IsFavourite': false},
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerID,
          'PRAYER/service/unFavoritePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future deletePrayer(String userPrayeId, String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
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
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          userPrayeId, 'PRAYER/service/deletePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future deleteUpdate(String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      _prayerUpdateCollectionReference
          .doc(prayerId)
          .update({'DeleteStatus': -1});
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerId,
          'PRAYER/service/deletePrayerUpdate');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

//Group Prayers
  hidePrayer(String prayerId, UserModel user) {
    final hiddenPrayerId = Uuid().v1();
    var hiddenPrayer = HiddenPrayerModel(
      id: hiddenPrayerId,
      userId: user.id,
      prayerId: prayerId,
      createdBy: user.id,
      createdOn: DateTime.now(),
      modifiedBy: user.id,
      modifiedOn: DateTime.now(),
    );
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      _hiddenPrayerCollectionReference
          .doc(hiddenPrayerId)
          .set(hiddenPrayer.toJson());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          user.id ?? '', 'PRAYER/service/hidePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
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
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      var batch = FirebaseFirestore.instance.batch();
      // store prayer
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store group prayer
      batch.set(
          _groupPrayerCollectionReference.doc(_userPrayerID),
          populateGroupPrayer(_userID, _prayerID, _userID, _userPrayerID)
              .toJson());

      for (var groupId in groups) {
        var groupPrayerId = Uuid().v1();
        batch.set(
            _groupPrayerCollectionReference.doc(groupPrayerId),
            populateGroupPrayerByGroupID(
                    prayerData, _prayerID, groupId, groupPrayerId)
                .toJson());
      }
      await batch.commit();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          prayerData.userId ?? '', 'PRAYER/service/addPrayerWithGroup');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  // Stream<List<CombineGroupPrayerStream>> getGroupPrayers(String groupId) {
  //   try {
  //     if (_firebaseAuth.currentUser == null)
  //       return Stream.error(StringUtils.unathorized);
  //     return _groupPrayerCollectionReference
  //         .where('GroupId', isEqualTo: groupId)
  //         .snapshots()
  //         .map((convert) {
  //       return convert.docs.map((f) {
  //         Stream<GroupPrayerModel> groupPrayer = Stream.value(f)
  //             .map<GroupPrayerModel>(
  //                 (doc) => GroupPrayerModel.fromData(doc.data(), doc.id));

  //         Stream<PrayerModel> prayer = _prayerCollectionReference
  //             .doc(f['PrayerId'])
  //             .snapshots()
  //             .map<PrayerModel>(
  //                 (doc) => PrayerModel.fromData(doc.data()!, doc.id));
  //         Stream<List<PrayerUpdateModel>> updates =
  //             _prayerUpdateCollectionReference
  //                 .where('PrayerId', isEqualTo: f['PrayerId'])
  //                 .snapshots()
  //                 .map<List<PrayerUpdateModel>>((list) => list.docs
  //                     .map((e) => PrayerUpdateModel.fromData(e.data(), e.id))
  //                     .toList());

  //         return Rx.combineLatest3(
  //           groupPrayer,
  //           prayer,
  //           updates,
  //           (GroupPrayerModel groupPrayer, PrayerModel prayer,
  //                   List<PrayerUpdateModel> updates) =>
  //               CombineGroupPrayerStream(
  //             tags: [],
  //             groupPrayer: groupPrayer,
  //             prayer: prayer,
  //             updates: updates,
  //           ),
  //         );
  //       });
  //     }).switchMap((observables) {
  //       return observables.length > 0
  //           ? Rx.combineLatestList(observables)
  //           : Stream.value([]);
  //     });
  //   } catch (e) {
  //     locator<LogService>().createLog(StringUtils.getErrorMessage(e), groupId,
  //         'PRAYER/service/getGroupPrayers');
  //     throw HttpException(StringUtils.getErrorMessage(e));
  //   }
  // }

  Stream<List<HiddenPrayerModel>> getHiddenPrayers(
    String userId,
  ) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _hiddenPrayerCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .asyncMap((event) => event.docs
              .map((e) => HiddenPrayerModel.fromData(e.data(), e.id))
              .toList());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'PRAYER/service/getHiddenPrayers');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  // Future<List<FollowedPrayerModel>> getFollowedPrayers(String prayerId) {
  //   try {
  //     if (_firebaseAuth.currentUser == null)
  //       return Future.error(StringUtils.unathorized);
  //     return _followedPrayerCollectionReference
  //         .where('PrayerId', isEqualTo: prayerId)
  //         .get()
  //         .then((event) => event.docs
  //             .map((e) => FollowedPrayerModel.fromData(e.data(), e.id))
  //             .toList());
  //   } catch (e) {
  //     locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerId,
  //         'PRAYER/service/getFollowedPrayers');
  //     throw HttpException(StringUtils.getErrorMessage(e));
  //   }
  // }

  // Future<List<FollowedPrayerModel>> getFollowedPrayersByGroupId(
  //     String groupId) {
  //   try {
  //     if (_firebaseAuth.currentUser == null)
  //       return Future.error(StringUtils.unathorized);
  //     return _followedPrayerCollectionReference
  //         .where('GroupId', isEqualTo: groupId)
  //         .get()
  //         .then((event) => event.docs
  //             .map((e) => FollowedPrayerModel.fromData(e.data(), e.id))
  //             .toList());
  //   } catch (e) {
  //     locator<LogService>().createLog(StringUtils.getErrorMessage(e), groupId,
  //         'PRAYER/service/getFollowedPrayersByGroupId');
  //     throw HttpException(StringUtils.getErrorMessage(e));
  //   }
  // }

  Stream<List<FollowedPrayerModel>> getFollowedPrayersByUserId(String userId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _followedPrayerCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((event) => event.docs
              .map((e) => FollowedPrayerModel.fromData(e.data(), e.id))
              .toList());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'PRAYER/service/getFollowedPrayersByUserId');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<List<FollowedPrayerModel>> getFollowedPrayers(String prayerId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return _followedPrayerCollectionReference
          .where('PrayerId', isEqualTo: prayerId)
          .get()
          .then((event) {
        return event.docs
            .map((e) => FollowedPrayerModel.fromData(e.data(), e.id))
            .toList();
      });
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), '',
          'PRAYER/service/getFollowedPrayers');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future hideFromAllMembers(String prayerId, bool value) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _prayerCollectionReference
          .doc(prayerId)
          .update({'HideFromAllMembers': value});
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerId,
          'PRAYER/service/hideFromAllMembers');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future messageRequestor(PrayerRequestMessageModel requestMessageModel) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
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
          StringUtils.getErrorMessage(e),
          requestMessageModel.senderId ?? '',
          'PRAYER/service/messageRequestor');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future addToMyList(String prayerId, String userId, String groupId,
      bool isFollowedByAdmin) async {
    final userPrayerID = Uuid().v1();
    final followedPrayerID = Uuid().v1();

    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      //store user prayer
      _userPrayerCollectionReference
          .doc(userPrayerID)
          .set(populateUserPrayer(userId, prayerId, userPrayerID).toJson());
      _followedPrayerCollectionReference.doc(followedPrayerID).set(
          populateFollowedPrayer(userId, prayerId, userPrayerID, groupId,
                  isFollowedByAdmin, followedPrayerID)
              .toJson());
    } catch (e) {
      await locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), userId, 'PRAYER/service/addPrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future removeFromMyList(String followedPrayerId, String userPrayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _followedPrayerCollectionReference.doc(followedPrayerId).delete();
      _userPrayerCollectionReference.doc(userPrayerId).delete();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          followedPrayerId, 'PRAYER/service/removeFromMyList');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future flagAsInappropriate(String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _prayerCollectionReference
          .doc(prayerId)
          .update({'IsInappropriate': true});
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerId,
          'PRAYER/service/flagAsInappropriate');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  populateFollowedPrayer(String userId, String prayerId, String userPrayerId,
      String groupId, bool isFollowedByAdmin, String id) {
    FollowedPrayerModel followedPrayer = FollowedPrayerModel(
        id: id,
        prayerId: prayerId,
        userId: userId,
        createdBy: userId,
        createdOn: DateTime.now(),
        modifiedBy: userId,
        isFollowedByAdmin: isFollowedByAdmin,
        modifiedOn: DateTime.now(),
        userPrayerId: userPrayerId,
        groupId: groupId);
    return followedPrayer;
  }

  populateUserPrayer(String userId, String prayerID, String id) {
    UserPrayerModel userPrayer = UserPrayerModel(
      id: id,
      deleteStatus: 0,
      isArchived: false,
      archivedDate: null,
      userId: userId,
      snoozeDuration: 0,
      snoozeFrequency: '',
      status: Status.active,
      sequence: '',
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
    String id,
  ) {
    PrayerModel prayer = PrayerModel(
      id: id,
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
    String id,
  ) {
    GroupPrayerModel userPrayer = GroupPrayerModel(
        id: id,
        groupId: groupId,
        status: Status.active,
        sequence: '',
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

  PrayerTagModel populatePrayerTag(
    Contact contact,
    String userId,
    String sender,
    String message,
    String prayerId,
    String id,
  ) {
    PrayerTagModel prayerTag = PrayerTagModel(
      id: id,
      userId: userId,
      prayerId: prayerId == '' ? newPrayerId : prayerId,
      displayName: contact.displayName ?? '',
      identifier: contact.identifier ?? '',
      phoneNumber: (contact.phones ?? []).length > 0
          ? (contact.phones ?? []).toList()[0].value ?? ''
          : '',
      email: (contact.emails ?? []).length > 0
          ? (contact.emails ?? []).toList()[0].value ?? ''
          : '',
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
    PrayerModel prayerData,
    String prayerID,
    String groupID,
    String id,
  ) {
    GroupPrayerModel userPrayer = GroupPrayerModel(
        id: id,
        groupId: groupID,
        isArchived: false,
        status: Status.active,
        sequence: '',
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
