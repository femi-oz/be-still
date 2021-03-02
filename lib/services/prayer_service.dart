import 'dart:io';
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
import 'package:flutter/cupertino.dart';
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
  final CollectionReference _prayerTagCollectionReference =
      FirebaseFirestore.instance.collection("PrayerTag");
  final CollectionReference _messageTemplateCollectionReference =
      FirebaseFirestore.instance.collection("MessageTemplate");

  final _notificationService = locator<NotificationService>();
  var prayerId;

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
                  .where('PrayerId', isEqualTo: f.data()['PrayerId'])
                  .snapshots()
                  .map<List<PrayerUpdateModel>>((list) => list.docs
                      .map((e) => PrayerUpdateModel.fromData(e))
                      .toList());

          Stream<List<PrayerTagModel>> tags = _prayerTagCollectionReference
              // .doc(f.data()['PrayerId'])
              .where('PrayerId', isEqualTo: f.data()['PrayerId'])
              // .orderBy('ModifiedOn')
              .snapshots()
              .map<List<PrayerTagModel>>((list) =>
                  list.docs.map((e) => PrayerTagModel.fromData(e)).toList());

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
      return _combineStream;
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, userId);
      throw HttpException(e.message);
    }
  }

  Stream<CombinePrayerStream> getPrayer(String prayerID) {
    try {
      var data = _userPrayerCollectionReference.doc(prayerID).snapshots();

      var _combineStream = data.map((doc) {
        Stream<UserPrayerModel> userPrayer = Stream.value(doc)
            .map<UserPrayerModel>((doc) => UserPrayerModel.fromData(doc));

        Stream<PrayerModel> prayer = _prayerCollectionReference
            .doc(doc.data()['PrayerId'])
            .snapshots()
            .map<PrayerModel>((doc) => PrayerModel.fromData(doc));

        Stream<List<PrayerUpdateModel>> updates =
            _prayerUpdateCollectionReference
                .where('PrayerId', isEqualTo: doc.data()['PrayerId'])
                .snapshots()
                .map<List<PrayerUpdateModel>>((list) => list.docs
                    .map((e) => PrayerUpdateModel.fromData(e))
                    .toList());

        Stream<List<PrayerTagModel>> tags = _prayerTagCollectionReference
            // .doc(doc.data()['PrayerId'])
            .where('PrayerId', isEqualTo: doc.data()['PrayerId'])
            .snapshots()
            .map<List<PrayerTagModel>>((list) =>
                list.docs.map((e) => PrayerTagModel.fromData(e)).toList());
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
      return _combineStream;
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerID);
      throw HttpException(e.message);
    }
  }

  Future addPrayer(
    String prayerDesc,
    String userId,
    String creatorName,
  ) async {
    // Generate uuid
    final prayerId = Uuid().v1();
    final userPrayerID = Uuid().v1();

    try {
      // store prayer
      await _prayerCollectionReference.doc(prayerId).set(
          populatePrayer(userId, prayerDesc, prayerId, creatorName).toJson());

      //store user prayer
      await _userPrayerCollectionReference
          .doc(userPrayerID)
          .set(populateUserPrayer(userId, prayerId, userId).toJson());
    } catch (e) {
      await locator<LogService>().createLog(e.code, e.message, userId);
      throw HttpException(e.message);
    }
  }

  Future addUserPrayer(String prayerId, String prayerDesc, String userId,
      String senderId, String sender) async {
    // Generate uuid
    final _userPrayerID = Uuid().v1();
    try {
      //store user prayer
      await _userPrayerCollectionReference
          .doc(_userPrayerID)
          .set(populateUserPrayer(userId, prayerId, senderId).toJson());
      var devices = await _notificationService.getNotificationToken(userId);
      for (int i = 0; i < devices.length; i++) {
        await _notificationService.addPushNotification(
          message: prayerDesc,
          sender: sender,
          senderId: senderId,
          recieverId: userId,
          tokens: devices.map((e) => e.name).toList(),
        );
      }
    } catch (e) {
      await locator<LogService>().createLog(e.code, e.message, userId);
      throw HttpException(e.message);
    }
  }

  Future addPrayerTag(List<Contact> contactData, UserModel user, String message,
      [List<PrayerTagModel> oldTags]) async {
    try {
      //store prayer Tag
      for (var i = 0; i < contactData.length; i++) {
        final _prayerTagID = Uuid().v1();
        if (contactData[i] != null) {
          await _prayerTagCollectionReference.doc(_prayerTagID).set(
              populatePrayerTag(
                      contactData[i], user.id, user.firstName, message)
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
          // compare old tags vs new tag to know if person has already received email/text
          if (oldTags.map((e) => e?.email).contains(email) ||
              oldTags.map((e) => e?.phoneNumber).contains(phoneNumber)) return;
          await _notificationService.addEmail(
            email: email,
            message: message,
            sender: user.firstName,
            senderId: user.id,
            template: MessageTemplate.fromData(template),
            receiver: contactData[i].displayName,
          );
          await _notificationService.addSMS(
              phoneNumber: phoneNumber,
              message: message,
              sender: user.firstName,
              senderId: user.id,
              template: MessageTemplate.fromData(template),
              receiver: contactData[i].displayName);
        }
      }
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, user.id);
      throw HttpException(e.message);
    }
  }

  Future removePrayerTag(String tagId) async {
    try {
      await _prayerTagCollectionReference.doc(tagId).delete();
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, tagId);
      throw HttpException(e.message);
    }
  }

  Future editPrayer(
    String description,
    String prayerID,
  ) async {
    try {
      _prayerCollectionReference.doc(prayerID).update(
        {"Description": description, "ModifiedOn": DateTime.now()},
      );
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerID);
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
      locator<LogService>().createLog(e.code, e.message, prayerupdate.userId);
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
      locator<LogService>().createLog(e.code, e.message, prayerId);
      throw HttpException(e.message);
    }
  }

  Future markPrayerAsAnswered(String prayerID) async {
    try {
      _prayerCollectionReference.doc(prayerID).update(
        {'IsArchived': true, 'IsAnswer': true, 'Status': Status.inactive},
      );
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerID);
      throw HttpException(e.message);
    }
  }

  Future snoozePrayer(
      String prayerID, DateTime endDate, String userPrayerID) async {
    try {
      _userPrayerCollectionReference.doc(userPrayerID).update(
        {
          'IsFavourite': false,
          'IsSnoozed': true,
          'SnoozeEndDate': endDate,
          'Status': Status.inactive
        },
      );
      _prayerCollectionReference
          .doc(prayerID)
          .update({'Status': Status.inactive});
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerID);
      throw HttpException(e.message);
    }
  }

  Future unSnoozePrayer(
      String prayerID, DateTime endDate, String userPrayerID) async {
    try {
      _userPrayerCollectionReference.doc(userPrayerID).update(
        {'IsSnoozed': false, 'Status': Status.active},
      );
      _prayerCollectionReference
          .doc(prayerID)
          .update({'Status': Status.active});
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerID);
      throw HttpException(e.message);
    }
  }

  Future archivePrayer(
    String prayerID,
  ) async {
    try {
      _prayerCollectionReference.doc(prayerID).update(
        {'IsArchived': true, 'Status': Status.inactive},
      );
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerID);
      throw HttpException(e.message);
    }
  }

  Future unArchivePrayer(
    String prayerID,
  ) async {
    try {
      _prayerCollectionReference.doc(prayerID).update(
        {'IsArchived': false, 'IsAnswer': false, 'Status': Status.active},
      );
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerID);
      throw HttpException(e.message);
    }
  }

  Future favoritePrayer(
    String prayerID,
  ) async {
    try {
      _userPrayerCollectionReference.doc(prayerID).update(
        {'IsFavourite': true},
      );
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerID);
      throw HttpException(e.message);
    }
  }

  Future unFavoritePrayer(
    String prayerID,
  ) async {
    try {
      _userPrayerCollectionReference.doc(prayerID).update(
        {'IsFavourite': false},
      );
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerID);
      throw HttpException(e.message);
    }
  }

  Future deletePrayer(String prayerID) async {
    try {
      _userPrayerCollectionReference.doc(prayerID).delete();
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerID);
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
      _hiddenPrayerCollectionReference
          .doc(hiddenPrayerId)
          .set(hiddenPrayer.toJson());
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, user.id);
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
      // store prayer
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store user prayer
      batch.set(_userPrayerCollectionReference.doc(_userPrayerID),
          populateUserPrayer(_userID, _prayerID, _userID).toJson());

      for (var groupId in groups) {
        var groupPrayerId = Uuid().v1();
        batch.set(
            _groupPrayerCollectionReference.doc(groupPrayerId),
            populateGroupPrayerByGroupID(prayerData, _prayerID, groupId)
                .toJson());
      }
      await batch.commit();
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerData.userId);
      throw HttpException(e.message);
    }
  }

  Future addPrayerToGroup(PrayerModel prayerData, List selectedGroups) async {
    // Generate uuid
    final _prayerID = Uuid().v1();
    final groupPrayerId = Uuid().v1();
    try {
      var batch = FirebaseFirestore.instance.batch();
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store group prayer
      batch.set(_groupPrayerCollectionReference.doc(groupPrayerId),
          populateGroupPrayer(prayerData, _prayerID).toJson());
      await batch.commit();
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerData.userId);
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
      // store prayer
      batch.set(_prayerCollectionReference.doc(_prayerID), prayerData.toJson());

      //store group prayer
      batch.set(_groupPrayerCollectionReference.doc(groupPrayerId),
          populateGroupPrayer(prayerData, _prayerID).toJson());
      await batch.commit();
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerData.userId);
      throw HttpException(e.message);
    }
  }

  Stream<List<CombinePrayerStream>> _combineGroupStream;
  Stream<List<CombinePrayerStream>> getGroupPrayers(String groupId) {
    print(groupId);
    try {
      _combineGroupStream = _groupPrayerCollectionReference
          // .orderBy('CreatedOn', descending: true)
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
      locator<LogService>().createLog(e.code, e.message, groupId);
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
      locator<LogService>().createLog(e.code, e.message, userId);
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
      locator<LogService>().createLog(e.code, e.message, prayerId);
      throw HttpException(e.message);
    }
  }

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
      locator<LogService>()
          .createLog(e.code, e.message, requestMessageModel.senderId);
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
      locator<LogService>().createLog(e.code, e.message, userPrayer.userId);
      throw HttpException(e.message);
    }
  }

  flagAsInappropriate(String prayerId) {
    try {
      _prayerCollectionReference
          .doc(prayerId)
          .update({'IsInappropriate': true});
    } catch (e) {
      locator<LogService>().createLog(e.code, e.message, prayerId);
      throw HttpException(e.message);
    }
  }

  populatePrayer(
    String userId,
    String prayerDesc,
    String prayerId,
    String creatorName,
  ) {
    PrayerModel prayer = PrayerModel(
      isAnswer: false,
      isArchived: false,
      isInappropriate: false,
      isSnoozed: false,
      snoozeEndDate: null,
      title: '',
      type: '',
      userId: userId,
      status: Status.active,
      creatorName: creatorName,
      description: prayerDesc,
      groupId: '0',
      createdBy: userId,
      createdOn: DateTime.now(),
      modifiedBy: userId,
      modifiedOn: DateTime.now(),
    );
    return prayer;
  }

  populateUserPrayer(
    String userId,
    String prayerID,
    String creatorId,
  ) {
    UserPrayerModel userPrayer = UserPrayerModel(
        userId: userId,
        status: Status.active,
        sequence: null,
        prayerId: prayerID,
        isFavorite: false,
        isSnoozed: false,
        snoozeEndDate: DateTime.now(),
        createdBy: creatorId,
        createdOn: DateTime.now(),
        modifiedBy: creatorId,
        modifiedOn: DateTime.now());
    return userPrayer;
  }

  PrayerTagModel populatePrayerTag(
      Contact contact, String userId, String sender, String message) {
    PrayerTagModel prayerTag = PrayerTagModel(
      userId: userId,
      prayerId: prayerId,
      displayName: contact.displayName,
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
}
