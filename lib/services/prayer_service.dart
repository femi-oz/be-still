import 'dart:io';

import 'package:be_still/enums/message-template.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    prayerId = _prayerID;

    try {
      // store prayer
      _prayerCollectionReference.doc(_prayerID).set(prayerData.toJson());

      //store user prayer
      _userPrayerCollectionReference
          .doc(_userPrayerID)
          .set(populateUserPrayer(_userID, _prayerID, _userID).toJson());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future addUserPrayer(String prayerId, String prayerDesc, String _userID,
      String creatorId, String creator) async {
    // Generate uuid
    final _userPrayerID = Uuid().v1();
    var dio = Dio(BaseOptions(followRedirects: false));

    try {
      //store user prayer
      _userPrayerCollectionReference
          .doc(_userPrayerID)
          .set(populateUserPrayer(_userID, prayerId, creatorId).toJson());
      await locator<NotificationService>().addMobileNotification(
          prayerDesc, NotificationType.prayer, creator, creatorId, _userID);
      var devices =
          await locator<NotificationService>().getNotificationToken(_userID);
      for (int i = 0; i < devices.length; i++) {
        var data = {
          'title': "You have been tagged in a prayer",
          'tokens': devices.map((e) => e.name).toList(),
          'message': prayerDesc,
          'sender': creator,
        };
        await dio.post(
          'https://us-central1-bestill-app.cloudfunctions.net/SendNotification',
          data: data,
        );
      }
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future addPrayerTag(PrayerTagModel prayerTagData, String countryCode,
      [List<PrayerTagModel> oldTags]) async {
    final _prayerTagID = Uuid().v1();
    var dio = Dio(BaseOptions(followRedirects: false));
    try {
      //store prayer Tag
      if (prayerTagData != null) {
        await _prayerTagCollectionReference
            .doc(_prayerTagID)
            .set(populatePrayerTag(prayerTagData).toJson());
        var template = await _messageTemplateCollectionReference
            .doc(MessageTemplateType.tagPrayer)
            .get();
        // compare old tags vs new tag to know if person has already received email/text
        if (oldTags.map((e) => e?.email).contains(prayerTagData.email) ||
            oldTags
                .map((e) => e?.phoneNumber)
                .contains(prayerTagData.phoneNumber)) return;
        if (prayerTagData.email != null) {
          var _template = MessageTemplate.fromData(template);
          var templateSubject = _template.templateSubject;
          var templateBody = _template.templateBody;
          templateSubject =
              templateSubject.replaceAll("{Sender}", prayerTagData.tagger);
          templateBody =
              templateBody.replaceAll("{Receiver}", prayerTagData.displayName);
          templateBody =
              templateBody.replaceAll("{message}", prayerTagData.message);
          var data = {
            'templateSubject': templateSubject,
            'templateBody': templateBody,
            'email': prayerTagData.email,
            'sender': prayerTagData.tagger,
          };
          await dio.post(
            'https://us-central1-bestill-app.cloudfunctions.net/SendMessage',
            data: data,
          );
          return;
        }
        if (prayerTagData.phoneNumber != null) {
          var _templateBody = MessageTemplate.fromData(template).templateBody;
          _templateBody =
              _templateBody.replaceAll('{Receiver}', prayerTagData.displayName);
          _templateBody =
              _templateBody.replaceAll('{message}', prayerTagData.message);
          _templateBody = _templateBody.replaceAll('<br/>', "\n");
          var data = {
            'phoneNumber': prayerTagData.phoneNumber,
            'template': _templateBody,
            'country': countryCode
          };
          await dio.post(
            'https://us-central1-bestill-app.cloudfunctions.net/SendTextMessage',
            data: data,
          );
          return;
        }
      }
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future removePrayerTag(String tagId) async {
    try {
      await _prayerTagCollectionReference.doc(tagId).delete();
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
        {"Description": description, "ModifiedOn": DateTime.now()},
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

  Future markPrayerAsAnswered(String prayerID) async {
    try {
      _prayerCollectionReference.doc(prayerID).update(
        {'IsArchived': true, 'IsAnswer': true, 'Status': Status.inactive},
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
        {'IsArchived': true, 'Status': Status.inactive},
      );
    } catch (e) {
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
      throw HttpException(e.message);
    }
  }

  Future deletePrayer(String id) async {
    try {
      _userPrayerCollectionReference.doc(id).delete();
    } catch (e) {
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
        createdBy: creatorId,
        createdOn: DateTime.now(),
        modifiedBy: creatorId,
        modifiedOn: DateTime.now());
    return userPrayer;
  }

  populatePrayerTag(
    PrayerTagModel prayerTagData,
  ) {
    PrayerTagModel prayerTag = PrayerTagModel(
      userId: prayerTagData.userId,
      prayerId: prayerId,
      displayName: prayerTagData.displayName,
      phoneNumber: prayerTagData.phoneNumber,
      email: prayerTagData.email,
      message: prayerTagData.message,
      tagger: prayerTagData.tagger,
      createdBy: prayerTagData.createdBy,
      createdOn: prayerTagData.createdOn,
      modifiedBy: prayerTagData.modifiedBy,
      modifiedOn: prayerTagData.modifiedOn,
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
