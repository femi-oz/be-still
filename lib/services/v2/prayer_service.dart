import 'package:be_still/enums/message-template.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/models/prayer.model.dart';
import 'package:be_still/models/models/tag.model.dart';
import 'package:be_still/models/models/update.model.dart';
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
      FirebaseFirestore.instance.collection("prayers_v2");

  final CollectionReference<Map<String, dynamic>>
      _messageTemplateCollectionReference =
      FirebaseFirestore.instance.collection("MessageTemplate");

  final _notificationService = locator<NotificationService>();

  Future<void> createPrayer(
      {required String userId,
      String? groupId,
      required String description,
      bool? isGroup}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
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
      //todo send push notification if group
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<PrayerDataModel>> getUserPrayers(String userId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _prayerDataCollectionReference
          .where('userId', isEqualTo: userId)
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

  Future<void> createPrayerTag(
      {required DocumentReference prayerReference,
      required List<Contact> contactData,
      required String userId,
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
      required String username,
      required String userId}) async {
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
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> createPrayerUpdate({
    required DocumentReference prayerReference,
    required List<UpdateModel> currentUpdates,
    required String userId,
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
          createdBy: userId,
          createdDate: DateTime.now(),
          modifiedBy: userId,
          modifiedDate: DateTime.now(),
        ));

      await prayerReference
          .update({"updates": currentUpdates.map((e) => e.toJson())});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> editPrayerUpdate({
    required DocumentReference prayerReference,
    required List<UpdateModel> currentUpdates,
    required UpdateModel update,
    required String updateId,
    required String userId,
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
          modifiedBy: userId,
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
      prayerReference.update({'isAnswered': true});
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
}
