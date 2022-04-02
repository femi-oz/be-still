import 'package:be_still/enums/message-template.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/followed_prayer.model.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/message_template.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/update.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/services/v2/notification_service.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:uuid/uuid.dart';

class PrayerServiceV2 {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserServiceV2 _userService = locator<UserServiceV2>();

  final CollectionReference<Map<String, dynamic>>
      _prayerDataCollectionReference =
      FirebaseFirestore.instance.collection('prayers');

  final CollectionReference<Map<String, dynamic>> _userDataCollectionReference =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference<Map<String, dynamic>>
      _messageTemplateCollectionReference =
      FirebaseFirestore.instance.collection('MessageTemplate');

  final _notificationService = locator<NotificationServiceV2>();

  Future<void> createPrayer(
      {String? groupId,
      required String description,
      bool? isGroup,
      List<Contact>? contacts}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      final userDoc = await _userDataCollectionReference
          .doc(_firebaseAuth.currentUser?.uid)
          .get();
      final user = UserDataModel.fromJson(userDoc.data()!, userDoc.id);

      final doc = PrayerDataModel(
        description: description,
        creatorName: (user.firstName ?? '') + ' ' + (user.lastName ?? ''),
        isAnswered: false,
        isFavorite: false,
        isGroup: isGroup ?? false,
        isInappropriate: false,
        userId: _firebaseAuth.currentUser?.uid,
        groupId: groupId,
        followers: [],
        archivedDate: null,
        status: Status.active,
        tags: (contacts ?? [])
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
            .toList(),
        updates: [],
        createdBy: _firebaseAuth.currentUser?.uid,
        modifiedBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
        snoozeEndDate: DateTime.now(),
      ).toJson();

      _prayerDataCollectionReference.add(doc).then((value) {
        if (isGroup ?? false) {
          _notificationService.sendPrayerNotification(
              message: description,
              type: NotificationType.prayer,
              groupId: groupId ?? '',
              prayerId: value.id);
        }

        sendTagMessageToUsers(
            contactData: contacts ?? [],
            description: description,
            username: (user.firstName ?? '') + ' ' + (user.lastName ?? ''));
      });
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
          .where('status', isNotEqualTo: Status.deleted)
          .snapshots()
          .map((event) => event.docs
              .map((e) => PrayerDataModel.fromJson(e.data(), e.id))
              .toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<List<PrayerDataModel>> getUserFollowedPrayers(
      List<String> userGroupsId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      if (userGroupsId.isEmpty) return Future.value([]);
      final chunks = partition(userGroupsId, 10);
      final querySnapshots = await Future.wait(chunks.map((chunk) {
        return _prayerDataCollectionReference
            .where('status', isEqualTo: Status.active)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
      }).toList());
      final list = querySnapshots.expand((e) => e.docs).toList();
      return list.map((e) => PrayerDataModel.fromJson(e.data(), e.id)).toList();
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
          .where('status', isNotEqualTo: Status.deleted)
          .snapshots()
          .map((event) => event.docs
              .map((e) => PrayerDataModel.fromJson(e.data(), e.id))
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
          .map<PrayerDataModel>(
              (doc) => PrayerDataModel.fromJson(doc.data()!, doc.id));
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<PrayerDataModel> getPrayerFuture(String prayerId) async {
    try {
      final doc = await _prayerDataCollectionReference.doc(prayerId).get();
      if (!doc.exists) return Future.error(StringUtils.documentDoesNotExist);
      return PrayerDataModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> editPrayer(
      {required String prayerId, required String description}) async {
    try {
      await _prayerDataCollectionReference
          .doc(prayerId)
          .update({'description': description, 'modifiedDate': DateTime.now()});
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
        'isGroup': isGroup,
        'modifiedDate': DateTime.now(),
        'modifiedBy': _firebaseAuth.currentUser?.uid
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> snoozePrayer(
      {required String prayerId, required snoozeEndDate}) async {
    try {
      _prayerDataCollectionReference.doc(prayerId).update(
        {'status': Status.snoozed, 'snoozeEndDate': snoozeEndDate},
      );
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> unSnoozePrayer({required String prayerId}) async {
    try {
      _prayerDataCollectionReference
          .doc(prayerId)
          .update({'status': Status.active});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> archivePrayer(
      {required String prayerId,
      required List<FollowerModel> followers}) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      if (followers.isNotEmpty) {
        followers.forEach((follower) async {
          UserDataModel user =
              await _userService.getUserByIdFuture(follower.userId ?? '');
          final prayerToRemove = (user.prayers ?? [])
              .firstWhere((element) => element.prayerId == prayerId);
          batch.update(_prayerDataCollectionReference.doc(prayerId), {
            'status': Status.archived,
            'archivedDate': DateTime.now(),
            'followers': FieldValue.arrayRemove([follower.toJson()])
          });
          batch.update(_userDataCollectionReference.doc(follower.userId), {
            'prayers': FieldValue.arrayRemove([prayerToRemove.toJson()])
          });
          batch.commit();
        });
      } else {
        batch.update(_prayerDataCollectionReference.doc(prayerId),
            {'status': Status.archived, 'archivedDate': DateTime.now()});
        batch.commit();
      }
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> unArchivePrayer(
      {required String prayerId,
      required List<FollowerModel> currentFollowers,
      required bool isAdmin}) async {
    if (currentFollowers.isNotEmpty &&
        currentFollowers.any(
            (element) => element.userId == _firebaseAuth.currentUser?.uid) &&
        !isAdmin) {
      FollowerModel user = currentFollowers.firstWhere(
        (element) => element.userId == _firebaseAuth.currentUser?.uid,
        orElse: () => FollowerModel(),
      );
      user = currentFollowers[currentFollowers.indexOf(user)]
        ..prayerStatus = Status.active;
      currentFollowers[currentFollowers.indexOf(user)] = user;
      await _prayerDataCollectionReference
          .doc(prayerId)
          .update({'followers': FieldValue.arrayUnion(currentFollowers)});
    } else {
      _prayerDataCollectionReference
          .doc(prayerId)
          .update({'status': Status.active, 'isAnswered': false});
    }
  }

  Future<void> favoritePrayer({required String prayerId}) async {
    try {
      _prayerDataCollectionReference.doc(prayerId).update({'isFavorite': true});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> unFavoritePrayer({required String prayerId}) async {
    _prayerDataCollectionReference.doc(prayerId).update({'isFavorite': false});
  }

  Future<void> createPrayerTag(
      {required List<Contact> contactData,
      required String username,
      required String description,
      required String prayerId}) async {
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
      tags.forEach((element) async {
        await _prayerDataCollectionReference.doc(prayerId).update({
          'tags': FieldValue.arrayUnion([element.toJson()])
        });
        sendTagMessageToUsers(
            contactData: contactData,
            description: description,
            username: username);
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> removePrayerTag({
    required String prayerId,
    required TagModel currentTag,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _prayerDataCollectionReference.doc(prayerId).update({
        "tags": FieldValue.arrayRemove([currentTag.toJson()])
      });
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
    required String prayerId,
    required String description,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final docId = Uuid().v1();

      final updateList = [
        UpdateModel(
          id: docId,
          description: description,
          status: Status.active,
          createdBy: _firebaseAuth.currentUser?.uid,
          createdDate: DateTime.now(),
          modifiedBy: _firebaseAuth.currentUser?.uid,
          modifiedDate: DateTime.now(),
        ).toJson()
      ];

      await _prayerDataCollectionReference.doc(prayerId).update({
        'updates': FieldValue.arrayUnion(updateList),
        'modifiedDate': DateTime.now(),
        'modifiedBy': _firebaseAuth.currentUser?.uid
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> editPrayerUpdate(
      {required UpdateModel update,
      required String description,
      required String prayerId}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final newUpdate = UpdateModel(
          id: update.id,
          description: description,
          status: update.status,
          createdBy: update.createdBy,
          createdDate: update.createdDate,
          modifiedBy: _firebaseAuth.currentUser?.uid,
          modifiedDate: DateTime.now());
      deleteUpdate(prayerId: prayerId, currentUpdate: update);
      _prayerDataCollectionReference.doc(prayerId).update({
        'updates': FieldValue.arrayUnion([newUpdate.toJson()]),
        'modifiedDate': DateTime.now(),
        'modifiedBy': _firebaseAuth.currentUser?.uid
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> markPrayerAsAnswered(
      {required String prayerId,
      required List<FollowerModel> followers}) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      if (followers.isNotEmpty) {
        followers.forEach((follower) async {
          UserDataModel user =
              await _userService.getUserByIdFuture(follower.userId ?? '');
          final prayerToRemove = (user.prayers ?? [])
              .firstWhere((element) => element.prayerId == prayerId);
          batch.update(_prayerDataCollectionReference.doc(prayerId), {
            'isAnswered': true,
            'status': Status.archived,
            'archivedDate': DateTime.now(),
            'followers': FieldValue.arrayRemove([follower.toJson()])
          });
          batch.update(_userDataCollectionReference.doc(follower.userId), {
            'prayers': FieldValue.arrayRemove([prayerToRemove.toJson()]),
          });
          batch.commit();
        });
      } else {
        batch.update(_prayerDataCollectionReference.doc(prayerId), {
          'isAnswered': true,
          'status': Status.archived,
          'archivedDate': DateTime.now()
        });
        batch.commit();
      }
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> unMarkPrayerAsAnswered({required String prayerId}) async {
    try {
      _prayerDataCollectionReference
          .doc(prayerId)
          .update({'isAnswered': false});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> deletePrayer(
      {required String prayerId,
      required String groupId,
      required List<FollowerModel> followers}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(_prayerDataCollectionReference.doc(prayerId), {
        'status': Status.deleted,
        'modifiedDate': DateTime.now(),
        'modifiedBy': _firebaseAuth.currentUser?.uid
      });
      followers.forEach((follower) {
        final prayer = FollowedPrayer(groupId: groupId, prayerId: prayerId);
        batch.update(_userDataCollectionReference.doc(follower.userId), {
          'prayers': FieldValue.arrayRemove([prayer.toJson()]),
          'modifiedDate': DateTime.now(),
          'modifiedBy': _firebaseAuth.currentUser?.uid
        });
      });
      batch.commit();
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> deleteUpdate({
    required String prayerId,
    required UpdateModel currentUpdate,
  }) async {
    try {
      _prayerDataCollectionReference.doc(prayerId).update({
        'updates': FieldValue.arrayRemove([currentUpdate.toJson()])
      });
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
            .update({'status': Status.active, 'snoozeEndDate': DateTime.now()});
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> autoDeleteArchivePrayers(
      int autoDeletePeriod, bool includeAnsweredPrayers) async {
    final archivedPrayers = await _prayerDataCollectionReference
        .where('userId', isEqualTo: _firebaseAuth.currentUser?.uid)
        .where('status', isEqualTo: Status.archived)
        .get();

    var mappedPrayers = archivedPrayers.docs
        .map((e) => PrayerDataModel.fromJson(e.data(), e.id))
        .toList();
    if (!includeAnsweredPrayers) {
      mappedPrayers = mappedPrayers
          .where((element) => element.isAnswered == false)
          .toList();
    }
    final filteredPrayers = mappedPrayers
        .where((prayer) => (prayer.archivedDate ?? DateTime.now())
            .add(Duration(minutes: autoDeletePeriod))
            .isBefore(DateTime.now()))
        .toList();

    filteredPrayers.forEach((prayer) async {
      _prayerDataCollectionReference
          .doc(prayer.id)
          .update({'status': Status.deleted});
      final notProvider =
          Provider.of<NotificationProviderV2>(Get.context!, listen: false);
      final notifications = notProvider.localNotifications
          .where((e) => e.prayerId == prayer.id)
          .toList();
      notifications.forEach((element) {
        if (element.localNotificationId != null)
          notProvider
              .cancelLocalNotificationById(element.localNotificationId ?? 0);
      });
    });
  }

  Future<void> followPrayer(
      {required String prayerId, required String groupId}) async {
    final userPrayer =
        FollowedPrayer(prayerId: prayerId, groupId: groupId).toJson();
    final followers = FollowerModel(
            userId: FirebaseAuth.instance.currentUser?.uid,
            status: Status.active,
            id: groupId)
        .toJson();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.update(
        _userDataCollectionReference
            .doc(FirebaseAuth.instance.currentUser?.uid),
        {
          'prayers': FieldValue.arrayUnion([userPrayer])
        });

    batch.update(_prayerDataCollectionReference.doc(prayerId), {
      'followers': FieldValue.arrayUnion([followers])
    });
    batch.commit();
  }

  Future<void> unFollowPrayer(
      {required String prayerId,
      required String groupId,
      required FollowedPrayer prayer,
      required FollowerModel follower}) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.update(
        _userDataCollectionReference
            .doc(FirebaseAuth.instance.currentUser?.uid),
        {
          'prayers': FieldValue.arrayRemove([prayer.toJson()]),
          'modifiedDate': DateTime.now(),
          'modifiedBy': _firebaseAuth.currentUser?.uid
        });
    batch.update(_prayerDataCollectionReference.doc(prayerId), {
      'followers': FieldValue.arrayRemove([follower.toJson()]),
      'modifiedDate': DateTime.now(),
      'modifiedBy': _firebaseAuth.currentUser?.uid
    });
    batch.commit();
  }
}
