import 'package:be_still/enums/message-template.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/models/prayer.model.dart';
import 'package:be_still/models/models/tag.model.dart';
import 'package:be_still/models/models/update.model.dart';
import 'package:be_still/services/v2/notification_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';

class PrayerService {
  final CollectionReference<Map<String, dynamic>>
      _prayerDataCollectionReference =
      FirebaseFirestore.instance.collection('prayers_v2');

  final CollectionReference<Map<String, dynamic>>
      _messageTemplateCollectionReference =
      FirebaseFirestore.instance.collection('MessageTemplate');

  final _notificationService = locator<NotificationService>();

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

  Stream<List<PrayerDataModel>> getPrayers(String userId) {
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

  Stream<PrayerDataModel> getPrayer(String prayerId) {
    try {
      return _prayerDataCollectionReference
          .doc(prayerId)
          .snapshots()
          .map<PrayerDataModel>((doc) => PrayerDataModel.fromJson(doc.data()!));
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
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
      throw StringUtils.getErrorMessage(e);
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
      throw StringUtils.getErrorMessage(e);
    }
  }

  Future<void> unSnoozePrayer({
    required DocumentReference prayerReference,
  }) async {
    try {
      await prayerReference.update({
        'isSnoozed': false,
        'status': Status.active,
        'snoozeEndDate': null,
        'modifiedOn': DateTime.now(),
      });
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
    }
  }

  Future<void> unArchivePrayer(
      {required DocumentReference prayerReference}) async {
    try {
      await prayerReference.update({
        'isAnswered': false,
        'status': Status.active,
        'modifiedOn': DateTime.now(),
      });
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
    }
  }

  Future<void> unMarkPrayerAsAnswered(
      {required DocumentReference prayerReference}) async {
    try {
      await prayerReference.update({
        'isAnswered': false,
        'status': Status.active,
        'modifiedOn': DateTime.now(),
      });
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
    }
  }

  Future<void> unFavouritePrayer(
      {required DocumentReference prayerReference}) async {
    try {
      await prayerReference.update({
        'isFavorite': false,
        'status': Status.active,
        'modifiedOn': DateTime.now(),
      });
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
    }
  }

  // Future<void>autoDeleteArchivePrayers({
  //    required int autoDeletePeriod
  // })async {

  // }

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
      await prayerReference.update({'tags': tags.map((e) => e.toJson())});
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
          .update({'updates': currentUpdates.map((e) => e.toJson())});
    } catch (e) {
      StringUtils.getErrorMessage(e);
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
      throw StringUtils.getErrorMessage(e);
    }
  }
}
