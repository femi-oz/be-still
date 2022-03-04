import 'package:be_still/enums/message-template.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/update.model.dart';
import 'package:be_still/services/v2/notification_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class PrayerService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>>
      _prayerDataCollectionReference =
      FirebaseFirestore.instance.collection('prayers_v2');

  final CollectionReference<Map<String, dynamic>>
      _messageTemplateCollectionReference =
      FirebaseFirestore.instance.collection('MessageTemplate');

  final _notificationService = locator<NotificationService>();

  Future<void> createPrayer(
      {String? groupId, required String description, bool? isGroup}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final doc = PrayerDataModel(
        description: description,
        isAnswered: false,
        isFavorite: false,
        isGroup: isGroup ?? false,
        isInappropriate: false,
        userId: _firebaseAuth.currentUser?.uid,
        groupId: groupId,
        followers: [],
        status: Status.active,
        tags: [],
        updates: [],
        createdBy: _firebaseAuth.currentUser?.uid,
        modifiedBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
        snoozeEndDate: null,
      ).toJson();
      await _prayerDataCollectionReference.add(doc);
      //todo send push notification if group
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<PrayerDataModel>> getUserPrayers() {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _prayerDataCollectionReference
          .where('userId', isEqualTo: _firebaseAuth.currentUser?.uid)
          .where('isGroup', isEqualTo: false)
          .snapshots()
          .map((event) => event.docs
              .map((e) => PrayerDataModel.fromJson(e.data()))
              .toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<PrayerDataModel>> getUserFollowedPrayers() {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _prayerDataCollectionReference
          .where('followers.userId', isEqualTo: _firebaseAuth.currentUser?.uid)
          .snapshots()
          .map((event) => event.docs
              .map((e) => PrayerDataModel.fromJson(e.data()))
              .toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<PrayerDataModel>> getGroupPrayers(String groupId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _prayerDataCollectionReference
          .where('groupId', isEqualTo: groupId)
          .snapshots()
          .map((event) => event.docs
              .map((e) => PrayerDataModel.fromJson(e.data()))
              .toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<PrayerDataModel> getPrayer(String prayerId) {
    try {
      return _prayerDataCollectionReference
          .doc(prayerId)
          .snapshots()
          .map<PrayerDataModel>((doc) => PrayerDataModel.fromJson(doc.data()!));
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> editPrayer(
      {required DocumentReference prayerReference,
      required String prayerId,
      required String description}) async {
    try {
      await prayerReference
          .update({'description': description, 'modifiedOn': DateTime.now()});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> addPrayerToGroup(
      {required DocumentReference prayerReference,
      required String groupId,
      required bool isGroup}) async {
    try {
      await prayerReference.update({
        'groupId': groupId,
        'modifiedOn': DateTime.now(),
        'isGroup': isGroup
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> snoozePrayer(
      {required DocumentReference prayerReference}) async {
    try {
      prayerReference.update({'status': Status.snoozed});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> unSnoozePrayer(
      {required DocumentReference prayerReference}) async {
    try {
      prayerReference.update({'status': Status.active});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> archivePrayer({
    required DocumentReference prayerReference,
    required List<FollowerModel> currentFollowers,
    required bool isAdmin,
  }) async {
    try {
      if (currentFollowers.isNotEmpty &&
          currentFollowers.any(
              (element) => element.userId == _firebaseAuth.currentUser?.uid) &&
          !isAdmin) {
        FollowerModel user = currentFollowers.firstWhere(
            (element) => element.userId == _firebaseAuth.currentUser?.uid);
        user = currentFollowers[currentFollowers.indexOf(user)]
          ..prayerStatus = Status.archived;
        currentFollowers[currentFollowers.indexOf(user)] = user;
        await prayerReference.update({'followers': currentFollowers});
      } else {
        prayerReference.update({'status': Status.archived});
      }
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> unArchivePrayer(
      {required DocumentReference prayerReference,
      required List<FollowerModel> currentFollowers,
      required bool isAdmin}) async {
    if (currentFollowers.isNotEmpty &&
        currentFollowers.any(
            (element) => element.userId == _firebaseAuth.currentUser?.uid) &&
        !isAdmin) {
      FollowerModel user = currentFollowers.firstWhere(
          (element) => element.userId == _firebaseAuth.currentUser?.uid);
      user = currentFollowers[currentFollowers.indexOf(user)]
        ..prayerStatus = Status.active;
      currentFollowers[currentFollowers.indexOf(user)] = user;
      await prayerReference.update({'followers': currentFollowers});
    } else {
      prayerReference.update({'status': Status.active});
    }
  }

  Future<void> favoritePrayer(
      {required DocumentReference prayerReference}) async {
    try {
      prayerReference.update({'status': Status.favorite});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> unFavoritePrayer(
      {required DocumentReference prayerReference}) async {
    prayerReference.update({'status': Status.active});
  }

  Future<void> createPrayerTag(
      {required DocumentReference prayerReference,
      required List<Contact> contactData,
      required String username,
      required String description}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
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
                createdBy: _firebaseAuth.currentUser?.uid,
                createdDate: DateTime.now(),
                modifiedBy: _firebaseAuth.currentUser?.uid,
                modifiedDate: DateTime.now(),
              ))
          .toList();
      await prayerReference.update({'tags': tags.map((e) => e.toJson())});
      sendTagMessageToUsers(
          contactData: contactData,
          description: description,
          username: username);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> removePrayerTag(
      {required DocumentReference prayerReference,
      required List<TagModel> currentTags,
      required String tagId}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      currentTags = currentTags..removeWhere((element) => element.id == tagId);
      await prayerReference
          .update({"tags": currentTags.map((e) => e.toJson())});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> sendTagMessageToUsers(
      {required List<Contact> contactData,
      required String description,
      required String username}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
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
            senderId: _firebaseAuth.currentUser?.uid,
            template: MessageTemplate.fromData(template.data()!, template.id),
            receiver: contact.displayName,
          );

        if (phoneNumber != null)
          _notificationService.addSMS(
              title: '',
              phoneNumber: phoneNumber,
              message: description,
              sender: username,
              senderId: _firebaseAuth.currentUser?.uid,
              template: MessageTemplate.fromData(template.data()!, template.id),
              receiver: contact.displayName);
      }
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> createPrayerUpdate({
    required DocumentReference prayerReference,
    required List<UpdateModel> currentUpdates,
    required String description,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final docId = Uuid().v1();
      currentUpdates = currentUpdates
        ..add(UpdateModel(
          id: docId,
          description: description,
          status: Status.active,
          createdBy: _firebaseAuth.currentUser?.uid,
          createdDate: DateTime.now(),
          modifiedBy: _firebaseAuth.currentUser?.uid,
          modifiedDate: DateTime.now(),
        ));

      await prayerReference
          .update({'updates': currentUpdates.map((e) => e.toJson())});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> editPrayerUpdate({
    required DocumentReference prayerReference,
    required List<UpdateModel> currentUpdates,
    required UpdateModel update,
    required String updateId,
    required String description,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      currentUpdates[currentUpdates.indexOf(update)] = UpdateModel(
          id: update.id,
          description: description,
          status: update.status,
          createdBy: update.createdBy,
          createdDate: update.createdDate,
          modifiedBy: _firebaseAuth.currentUser?.uid,
          modifiedDate: DateTime.now());
      await prayerReference
          .update({"updates": currentUpdates.map((e) => e.toJson())});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> markPrayerAsAnswered(
      {required DocumentReference prayerReference}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      prayerReference.update({
        'isAnswered': true,
        'status': Status.archived,
        'modifiedOn': DateTime.now(),
        'modifiedBy': _firebaseAuth.currentUser?.uid
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> unMarkPrayerAsAnswered(
      {required DocumentReference prayerReference}) async {
    try {
      await prayerReference.update({
        'isAnswered': false,
        'modifiedOn': DateTime.now(),
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> deletePrayer(
      {required DocumentReference prayerReference}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      prayerReference.delete();
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> deleteUpdate({
    required DocumentReference prayerReference,
    required String prayerUpdateId,
    required List<UpdateModel> currentUpdates,
  }) async {
    try {
      currentUpdates = currentUpdates
        ..removeWhere((element) => element.id == prayerUpdateId);
      await prayerReference
          .update({'updates': currentUpdates.map((e) => e.toJson())});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> autoUnSnoozePrayers() async {
    try {
      final snoozedPrayers = await _prayerDataCollectionReference
          .where('userId', isEqualTo: _firebaseAuth.currentUser?.uid)
          .where('snoozeEndDate', isLessThan: Timestamp.now())
          .where('status', isEqualTo: Status.snoozed)
          .get();

      snoozedPrayers.docs.forEach((element) {
        element.reference
            .update({'status': Status.active, 'snoozeEndDate': null});
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> autoUnArchivePrayers() async {
    try {
      final archivedPrayers = await _prayerDataCollectionReference
          .where('userId', isEqualTo: _firebaseAuth.currentUser?.uid)
          .where('isGroup', isEqualTo: false)
          .get();

      archivedPrayers.docs.forEach((prayer) {
        final mappedPrayer = PrayerDataModel.fromJson(prayer.data());
        if ((mappedPrayer.followers ?? []).isNotEmpty &&
            (mappedPrayer.followers ?? []).any((element) =>
                element.userId == _firebaseAuth.currentUser?.uid)) {
          FollowerModel user = (mappedPrayer.followers ?? []).firstWhere(
              (element) => element.userId == _firebaseAuth.currentUser?.uid);
          user = (mappedPrayer.followers ??
              [])[(mappedPrayer.followers ?? []).indexOf(user)]
            ..prayerStatus = Status.active;
          (mappedPrayer.followers ??
              [])[(mappedPrayer.followers ?? []).indexOf(user)] = user;
          prayer.reference
              .update({'followers': (mappedPrayer.followers ?? [])});
        } else {
          prayer.reference.update({'status': Status.active});
        }
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }
}
