import 'package:be_still/enums/group_type.dart';
import 'package:be_still/enums/message-template.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/models/group.model.dart';
import 'package:be_still/models/models/group_user.model.dart';
import 'package:be_still/models/models/prayer.model.dart';
import 'package:be_still/models/models/tag.model.dart';
import 'package:be_still/models/models/update.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

class PrayerService {
  //#region

  final CollectionReference<Map<String, dynamic>> _prayerCollectionReference =
      FirebaseFirestore.instance.collection("Prayer");
  final CollectionReference<Map<String, dynamic>>
      _userPrayerCollectionReference =
      FirebaseFirestore.instance.collection("UserPrayer");
  final CollectionReference<Map<String, dynamic>>
      _groupPrayerCollectionReference =
      FirebaseFirestore.instance.collection("GroupPrayer");
  final CollectionReference<Map<String, dynamic>>
      _prayerUpdateCollectionReference =
      FirebaseFirestore.instance.collection("PrayerUpdate");
  final CollectionReference<Map<String, dynamic>>
      _hiddenPrayerCollectionReference =
      FirebaseFirestore.instance.collection("HiddenPrayer");
  final CollectionReference<Map<String, dynamic>>
      _prayerTagCollectionReference =
      FirebaseFirestore.instance.collection("PrayerTag");
  final CollectionReference<Map<String, dynamic>>
      _messageTemplateCollectionReference =
      FirebaseFirestore.instance.collection("MessageTemplate");
  final CollectionReference<Map<String, dynamic>>
      _localNotificationCollectionReference =
      FirebaseFirestore.instance.collection("LocalNotification");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _notificationService = locator<NotificationService>();
  var newPrayerId;

  // Stream<List<CombinePrayerStream>> _combineStream;
  Stream<List<CombinePrayerStream>> getPrayers(String userId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _userPrayerCollectionReference
          .where('UserId', isEqualTo: userId)
          .where('DeleteStatus', isEqualTo: 0)
          .snapshots()
          .map((convert) {
        return convert.docs.map((f) {
          Stream<UserPrayerModel> userPrayer = Stream.value(f)
              .map<UserPrayerModel>(
                  (doc) => UserPrayerModel.fromData(doc.data(), doc.id));

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

          return Rx.combineLatest4(
              userPrayer,
              prayer,
              updates,
              tags,
              (UserPrayerModel userPrayer,
                      PrayerModel prayer,
                      List<PrayerUpdateModel> updates,
                      List<PrayerTagModel> tags) =>
                  CombinePrayerStream(
                    prayer: prayer,
                    updates: updates,
                    userPrayer: userPrayer,
                    tags: tags,
                  ));
        });
      }).switchMap((observables) {
        return observables.length > 0
            ? Rx.combineLatestList(observables)
            : Stream.value([]);
      });
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), userId, 'PRAYER/service/getPrayers');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<CombinePrayerStream> getPrayer(String userPrayerId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _userPrayerCollectionReference
          .doc(userPrayerId)
          .snapshots()
          .map((_doc) {
        Stream<UserPrayerModel> userPrayer = Stream.value(_doc)
            .map<UserPrayerModel>(
                (doc) => UserPrayerModel.fromData(doc.data()!, doc.id));
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
            userPrayer,
            prayer,
            updates,
            tags,
            (UserPrayerModel userPrayer,
                    PrayerModel prayer,
                    List<PrayerUpdateModel> updates,
                    List<PrayerTagModel> tags) =>
                CombinePrayerStream(
                  prayer: prayer,
                  updates: updates,
                  userPrayer: userPrayer,
                  tags: tags,
                ));
      }).switchMap((observables) {
        return observables;
      });
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          userPrayerId, 'PRAYER/service/getPrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future addPrayer(
    String prayerDesc,
    String userId,
    String creatorName,
    String prayerDescBackup,
  ) async {
    newPrayerId = Uuid().v1();
    final userPrayerID = Uuid().v1();

    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      // store prayer
      _prayerCollectionReference.doc(newPrayerId).set(populatePrayer(
              userId, prayerDesc, creatorName, prayerDescBackup, newPrayerId)
          .toJson());

      //store user prayer
      _userPrayerCollectionReference
          .doc(userPrayerID)
          .set(populateUserPrayer(userId, newPrayerId, userPrayerID).toJson());
    } catch (e) {
      await locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), userId, 'PRAYER/service/addPrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future addPrayerTag(List<Contact> contactData, UserModel user, String message,
      String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
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
      }
      // }
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          user.id ?? '', 'PRAYER/service/addPrayerTag');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future removePrayerTag(String tagId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _prayerTagCollectionReference.doc(tagId).delete();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), tagId,
          'PRAYER/service/removePrayerTag');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future editPrayer(
    String description,
    String prayerID,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      newPrayerId = prayerID;
      _prayerCollectionReference.doc(prayerID).update(
        {"Description": description, "ModifiedOn": DateTime.now()},
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerID,
          'PRAYER/service/editPrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future editUpdate(String description, String prayerID) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _prayerUpdateCollectionReference.doc(prayerID).update(
        {"Description": description, "ModifiedOn": DateTime.now()},
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerID,
          'PRAYER/service/editPrayerUpdate');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future addPrayerUpdate(String userId, String prayer, String prayerId) async {
    final updateId = Uuid().v1();
    final prayerUpdate = PrayerUpdateModel(
      id: updateId,
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
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      prayerId = prayerId;
      await _prayerCollectionReference
          .doc(prayerId)
          .update({'ModifiedOn': DateTime.now()});
      _prayerUpdateCollectionReference.doc(updateId).set(
            prayerUpdate.toJson(),
          );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          prayerUpdate.userId ?? '', 'PRAYER/service/addPrayerUpdate');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

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
        return Future.error(StringUtils.unathorized);
      _userPrayerCollectionReference.doc(userPrayerID).update(
        {
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
        return Future.error(StringUtils.unathorized);
      _userPrayerCollectionReference.doc(userPrayerID).update(
        {
          'IsSnoozed': false,
          'Status': Status.active,
          'SnoozeEndDate': null,
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

  Future<void> unSnoozePrayerPast(String userId) async {
    final snoozedPrayers = await _userPrayerCollectionReference
        .where('UserId', isEqualTo: userId)
        .where('SnoozeEndDate', isLessThan: Timestamp.now())
        .where('IsSnoozed', isEqualTo: true)
        .get();

    snoozedPrayers.docs.forEach((element) {
      element.reference.update({
        'IsSnoozed': false,
        'Status': Status.active,
        'SnoozeEndDate': null,
        'SnoozeDuration': 0,
        'SnoozeFrequency': '',
      });
    });
  }

  Future<void> autoDeleteArchivePrayers(
      String userId, int autoDeletePeriod) async {
    final archivedPrayers = await _userPrayerCollectionReference
        .where('UserId', isEqualTo: userId)
        .where('IsArchived', isEqualTo: true)
        .get();
    final mappedPrayers = archivedPrayers.docs
        .map((e) => UserPrayerModel.fromData(e.data(), e.id))
        .toList();
    final filteredPrayers = mappedPrayers.where((prayer) =>
        (prayer.archivedDate ?? DateTime.now())
            .add(Duration(minutes: autoDeletePeriod))
            .isBefore(DateTime.now()));
    filteredPrayers.forEach((userPrayer) async {
      _prayerCollectionReference.doc(userPrayer.prayerId).update(
        {'IsAnswer': false},
      );
      _userPrayerCollectionReference.doc(userPrayer.id).update({
        'IsArchived': false,
        'Status': Status.active,
        'ArchivedDate': null,
      });
      final notifications = await _localNotificationCollectionReference
          .where('EntityId', isEqualTo: userPrayer.id)
          .get();
      notifications.docs.forEach((element) => element.reference.delete());
    });
  }

  Future archivePrayer(
    String userPrayerId,
  ) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _userPrayerCollectionReference.doc(userPrayerId).update(
        {
          'IsArchived': true,
          'Status': Status.inactive,
          'IsFavourite': false,
          'ArchivedDate': DateTime.now(),
          'IsSnoozed': false
        },
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          userPrayerId, 'PRAYER/service/archivePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future unArchivePrayer(String userPrayerId, String prayerID) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _prayerCollectionReference.doc(prayerID).update(
        {'IsAnswer': false},
      );
      _userPrayerCollectionReference.doc(userPrayerId).update({
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

  Future markPrayerAsAnswered(String prayerID, String userPrayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
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
      _userPrayerCollectionReference.doc(userPrayerId).update(data);
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerID,
          'PRAYER/service/markPrayerAsAnswered');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future unMarkPrayerAsAnswered(String prayerID, String userPrayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
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
        return Future.error(StringUtils.unathorized);
      _userPrayerCollectionReference.doc(prayerID).update(
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
        return Future.error(StringUtils.unathorized);
      _userPrayerCollectionReference.doc(prayerID).update(
        {'IsFavourite': false},
      );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), prayerID,
          'PRAYER/service/unFavoritePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future deletePrayer(String userPrayeId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _userPrayerCollectionReference
          .doc(userPrayeId)
          .update({'DeleteStatus': -1});
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          userPrayeId, 'PRAYER/service/deletePrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future deleteUpdate(String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
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
        return Future.error(StringUtils.unathorized);
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
        return Future.error(StringUtils.unathorized);
      var batch = FirebaseFirestore.instance.batch();
      // store prayer
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store user prayer
      batch.set(_userPrayerCollectionReference.doc(_userPrayerID),
          populateUserPrayer(_userID, _prayerID, _userPrayerID).toJson());

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

  Future addPrayerToGroup(PrayerModel prayerData, List selectedGroups) async {
    // Generate uuid
    final _prayerID = Uuid().v1();
    final groupPrayerId = Uuid().v1();
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      var batch = FirebaseFirestore.instance.batch();
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store group prayer
      batch.set(_groupPrayerCollectionReference.doc(groupPrayerId),
          populateGroupPrayer(prayerData, _prayerID, groupPrayerId).toJson());
      await batch.commit();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          prayerData.userId ?? '', 'PRAYER/service/addPrayerToGroup');
      throw HttpException(StringUtils.getErrorMessage(e));
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
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      var batch = FirebaseFirestore.instance.batch();
      // store prayer
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store group prayer
      batch.set(_groupPrayerCollectionReference.doc(groupPrayerId),
          populateGroupPrayer(prayerData, _prayerID, groupPrayerId).toJson());
      await batch.commit();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          prayerData.userId ?? '', 'PRAYER/service/addGroupPrayer');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  hideFromAllMembers(String prayerId, bool value) {
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

  populatePrayer(String userId, String prayerDesc, String creatorName,
      String prayerDescBackup, String id) {
    PrayerModel prayer = PrayerModel(
      id: id,
      isGroup: false,
      isAnswer: false,
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
        modifiedOn: DateTime.now());
    return userPrayer;
  }

  populateNotificationId(String notificationId) {
    return notificationId;
  }

  PrayerTagModel populatePrayerTag(Contact contact, String userId,
      String sender, String message, String prayerId, String id) {
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

  populateGroupPrayer(
    PrayerModel prayerData,
    String prayerID,
    String id,
  ) {
    GroupPrayerModel userPrayer = GroupPrayerModel(
        id: id,
        groupId: prayerData.groupId,
        status: Status.active,
        sequence: '',
        deleteStatus: 0,
        prayerId: prayerID,
        isSnoozed: false,
        isArchived: false,
        isFavorite: false,
        archivedDate: DateTime.now(),
        snoozeEndDate: DateTime.now(),
        snoozeDuration: 0,
        snoozeFrequency: '',
        createdBy: prayerData.createdBy,
        createdOn: prayerData.createdOn,
        modifiedBy: prayerData.modifiedBy,
        modifiedOn: prayerData.modifiedOn);
    return userPrayer;
  }

  populateGroupPrayerByGroupID(
      PrayerModel prayerData, String prayerID, String groupID, String id) {
    GroupPrayerModel userPrayer = GroupPrayerModel(
        id: id,
        groupId: groupID,
        status: Status.active,
        sequence: '',
        prayerId: prayerID,
        isSnoozed: false,
        deleteStatus: 0,
        archivedDate: DateTime.now(),
        snoozeEndDate: DateTime.now(),
        snoozeDuration: 0,
        snoozeFrequency: '',
        isFavorite: false,
        isArchived: false,
        createdBy: prayerData.createdBy,
        createdOn: prayerData.createdOn,
        modifiedBy: prayerData.modifiedBy,
        modifiedOn: prayerData.modifiedOn);
    return userPrayer;
  }
// #endregion */

//=============================================================================================================================//
//new data structure

  final CollectionReference<Map<String, dynamic>>
      _prayerDataCollectionReference =
      FirebaseFirestore.instance.collection("prayers_v2");

  Future<void> createPrayer(
      {required String userId,
      String? groupId,
      required String description,
      bool? isGroup}) async {
    try {
      final doc = PrayerDataModel(
        description: description,
        isAnswered: false,
        isFavorite: false,
        isGroup: isGroup ?? false,
        isInappropriate: false,
        userId: userId,
        groupId: groupId,
        followers: [],
        status: Status.active,
        tags: [],
        updates: [],
        createdBy: userId,
        modifiedBy: userId,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
        snoozeEndDate: null,
      ).toJson();
      await _prayerDataCollectionReference.add(doc);
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Stream<List<PrayerDataModel>> getUserPrayers(String userId) {
    try {
      return _prayerDataCollectionReference
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((event) => event.docs
              .map((e) => PrayerDataModel.fromJson(e.data()))
              .toList());
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
    }
  }

  Future<void> createPrayerTag(
      {required DocumentReference prayerReference,
      required List<Contact> contactData,
      required String userId,
      required String username,
      required String description}) async {
    try {
      List<TagModel>? tags = contactData
          .map((contact) => TagModel(
                displayName: contact.displayName ?? '',
                contactIdentifier: contact.identifier ?? '',
                phoneNumber: (contact.phones ?? []).length > 0
                    ? (contact.phones ?? []).toList()[0].value ?? ''
                    : '',
                email: (contact.emails ?? []).length > 0
                    ? (contact.emails ?? []).toList()[0].value ?? ''
                    : '',
                status: Status.active,
                createdBy: userId,
                createdDate: DateTime.now(),
                modifiedBy: userId,
                modifiedDate: DateTime.now(),
              ))
          .toList();
      await prayerReference.update({"tags": tags.map((e) => e.toJson())});
      sendTagMessageToUsers(
          contactData: contactData,
          description: description,
          username: username,
          userId: userId);
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> sendTagMessageToUsers(
      {required List<Contact> contactData,
      required String description,
      required String username,
      required String userId}) async {
    final template = await _messageTemplateCollectionReference
        .doc(MessageTemplateType.tagPrayer)
        .get();
    for (final contact in contactData) {
      final phoneNumber = (contact.phones ?? []).length > 0
          ? (contact.phones ?? []).toList()[0].value
          : null;
      final email = (contact.emails ?? []).length > 0
          ? (contact.emails ?? []).toList()[0].value
          : null;
      if (email != null)
        _notificationService.addEmail(
          title: '',
          email: email,
          message: description,
          sender: username,
          senderId: userId,
          template: MessageTemplate.fromData(template.data()!, template.id),
          receiver: contact.displayName,
        );

      if (phoneNumber != null)
        _notificationService.addSMS(
            title: '',
            phoneNumber: phoneNumber,
            message: description,
            sender: username,
            senderId: userId,
            template: MessageTemplate.fromData(template.data()!, template.id),
            receiver: contact.displayName);
    }
  }

  Future<void> createPrayerUpdate(
      {required DocumentReference prayerReference,
      required List<UpdateModel> currentUpdates,
      required String userId,
      required String description}) async {
    try {
      currentUpdates = currentUpdates
        ..add(UpdateModel(
          description: description,
          status: Status.active,
          createdBy: userId,
          createdDate: DateTime.now(),
          modifiedBy: userId,
          modifiedDate: DateTime.now(),
        ));

      await prayerReference
          .update({"updates": currentUpdates.map((e) => e.toJson())});
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }
}
