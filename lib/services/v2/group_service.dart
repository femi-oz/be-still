import 'dart:io';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/request_status.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/followed_prayer.model.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/models/v2/notification.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/request.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/v2/prayer_service.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiver/iterables.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class GroupServiceV2 {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  UserServiceV2 _userService = locator<UserServiceV2>();
  PrayerServiceV2 _prayerService = locator<PrayerServiceV2>();

  final CollectionReference<Map<String, dynamic>>
      _groupDataCollectionReference =
      FirebaseFirestore.instance.collection("groups");

  final CollectionReference<Map<String, dynamic>>
      _prayerDataCollectionReference =
      FirebaseFirestore.instance.collection("prayers");

  final CollectionReference<Map<String, dynamic>> _userDataCollectionReference =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference<Map<String, dynamic>>
      _notificationCollectionReference =
      FirebaseFirestore.instance.collection("notifications");

  Future<String> createGroup(
      {required String name,
      required String purpose,
      required bool requireAdminApproval,
      required String organization,
      required String location,
      required String type}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final groupId = Uuid().v1();

      final doc = GroupDataModel(
        id: groupId,
        name: name,
        purpose: purpose,
        requireAdminApproval: requireAdminApproval,
        location: location,
        organization: organization,
        requests: [],
        users: [
          GroupUserDataModel(
              id: Uuid().v1(),
              enableNotificationForUpdates: true,
              notifyMeOfFlaggedPrayers: true,
              notifyWhenNewMemberJoins: true,
              role: GroupUserRole.admin,
              enableNotificationForNewPrayers: true,
              userId: _firebaseAuth.currentUser?.uid,
              status: Status.active,
              createdBy: _firebaseAuth.currentUser?.uid,
              modifiedBy: _firebaseAuth.currentUser?.uid,
              createdDate: DateTime.now(),
              modifiedDate: DateTime.now())
        ],
        type: type,
        status: Status.active,
        createdBy: _firebaseAuth.currentUser?.uid,
        modifiedBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.set(_groupDataCollectionReference.doc(groupId), doc);
      batch.update(
          _userDataCollectionReference.doc(_firebaseAuth.currentUser?.uid), {
        'groups': FieldValue.arrayUnion([groupId])
      });
      batch.commit();
      return groupId;
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> editGroup(
      {required String groupId,
      required String name,
      required String purpose,
      required bool requireAdminApproval,
      required String organization,
      required String location,
      required String type}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _groupDataCollectionReference.doc(groupId).update({
        'purpose': purpose,
        'name': name,
        'organization': organization,
        'location': location,
        'type': type,
        'requireAdminApproval': requireAdminApproval,
        'modifiedBy': _firebaseAuth.currentUser?.uid,
        'modifiedDate': DateTime.now()
      });
      final group = await _groupDataCollectionReference
          .doc(groupId)
          .get()
          .then((value) => GroupDataModel.fromJson(value.data()!, value.id));
      if (!requireAdminApproval) {
        final activeRequests = (group.requests ?? [])
            .where((e) => e.status == RequestStatus.pending)
            .toList();
        for (final req in activeRequests) {
          acceptJoinRequest(
            group: group,
            request: req,
            senderId: req.userId,
          );
        }
        // add each to group
        // send notification that they joined
      }
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<List<GroupDataModel>> getUserGroupsFuture(
      List<String> userGroupsId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      if (userGroupsId.isEmpty) return Future.value([]);
      final chunks = partition(userGroupsId, 10);
      final querySnapshots = await Future.wait(chunks.map((chunk) {
        return _groupDataCollectionReference
            .where('status', isEqualTo: Status.active)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
      }).toList());
      final list = querySnapshots.expand((e) => e.docs).toList();
      return list.map((e) => GroupDataModel.fromJson(e.data(), e.id)).toList();
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserGroupEmpty(
      List<String> userGroupsId) {
    return _groupDataCollectionReference.snapshots();
  }

  Stream<List<GroupDataModel>> getUserGroups(List<String> userGroupsId) {
    if (_firebaseAuth.currentUser == null)
      return Stream.error(StringUtils.unathorized);
    if (userGroupsId.isEmpty) return Stream.value([]);
    final List<List<String>> chunks = partition(userGroupsId, 10).toList();
    List<Stream<List<GroupDataModel>>> streams =
        <Stream<List<GroupDataModel>>>[];
    chunks.forEach((chunk) => streams.add(_groupDataCollectionReference
        .where('status', isEqualTo: Status.active)
        .where(FieldPath.documentId, whereIn: chunk)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((document) =>
                GroupDataModel.fromJson(document.data(), document.id))
            .toList())));
    return ZipStream(
        streams,
        (List<List<GroupDataModel>> value) =>
            value.expand((element) => element).toList());
  }

  Future<GroupDataModel> getGroup(String groupId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final doc = await _groupDataCollectionReference.doc(groupId).get();
      if (!doc.exists) return Future.error(StringUtils.documentDoesNotExist);
      return GroupDataModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<List<GroupDataModel>> getGroups() {
    try {
      return _groupDataCollectionReference
          .where('status', isNotEqualTo: Status.deleted)
          .get()
          .then((event) => event.docs
              .map((e) => GroupDataModel.fromJson(e.data(), e.id))
              .toList());
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
    }
  }

  Future<void> editUserRole(
      {required GroupUserDataModel userData,
      required String role,
      required String groupId}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      final updatePayload = GroupUserDataModel(
              id: userData.id,
              userId: userData.userId,
              role: role,
              enableNotificationForNewPrayers:
                  userData.enableNotificationForNewPrayers,
              enableNotificationForUpdates:
                  userData.enableNotificationForUpdates,
              notifyMeOfFlaggedPrayers: userData.notifyMeOfFlaggedPrayers,
              notifyWhenNewMemberJoins: userData.notifyWhenNewMemberJoins,
              createdBy: userData.createdBy,
              createdDate: userData.createdDate ?? DateTime.now(),
              modifiedBy: userData.modifiedBy,
              modifiedDate: userData.modifiedDate ?? DateTime.now(),
              status: userData.status)
          .toJson();

      final group = await _groupDataCollectionReference
          .doc(groupId)
          .get()
          .then((value) => GroupDataModel.fromJson(value.data()!, value.id));
      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(_groupDataCollectionReference.doc(groupId), {
        'modifiedDate': DateTime.now(),
        'users': FieldValue.arrayRemove([
          {
            'id': userData.id,
            'userId': userData.userId,
            'role': userData.role,
            'enableNotificationForNewPrayers':
                userData.enableNotificationForNewPrayers,
            'enableNotificationForUpdates':
                userData.enableNotificationForUpdates,
            'notifyMeOfFlaggedPrayers': userData.notifyMeOfFlaggedPrayers,
            'notifyWhenNewMemberJoins': userData.notifyWhenNewMemberJoins,
            'createdBy': userData.createdBy,
            'createdDate':
                Timestamp.fromDate(userData.createdDate ?? DateTime.now()),
            'modifiedBy': userData.modifiedBy,
            'modifiedDate':
                Timestamp.fromDate(userData.modifiedDate ?? DateTime.now()),
            'status': userData.status
          }
        ])
      });
      batch.update(_groupDataCollectionReference.doc(groupId), {
        'users': FieldValue.arrayUnion([updatePayload])
      });
      // batch.update(_userDataCollectionReference.doc(userData.userId),
      //     {'modifiedDate': DateTime.now()});
      batch.commit();
      updateGroupUsers(
          userIds: (group.users ?? []).map((e) => e.id ?? '').toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> requestToJoinGroup({
    required String groupId,
    required String message,
    required List<String> receiverIds,
  }) async {
    try {
      List<String> tokens = [];

      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final request = RequestModel(
        id: Uuid().v1(),
        userId: _firebaseAuth.currentUser?.uid,
        status: RequestStatus.pending,
        createdBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedBy: _firebaseAuth.currentUser?.uid,
        modifiedDate: DateTime.now(),
      ).toJson();

      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(_groupDataCollectionReference.doc(groupId), {
        "requests": FieldValue.arrayUnion([request])
      });
      for (final receiverId in receiverIds) {
        final user = await _userService.getUserByIdFuture(receiverId);
        if (user.enableNotificationsForAllGroups ?? false) {
          tokens = (user.devices ?? []).map((e) => e.token ?? '').toList();
        }
        final notId = Uuid().v1();
        final doc = NotificationModel(
          id: notId,
          message: message,
          status: Status.active,
          tokens: tokens,
          isSent: 0,
          senderId: _firebaseAuth.currentUser?.uid,
          type: NotificationType.request,
          groupId: groupId,
          prayerId: '',
          receiverId: receiverId,
          modifiedBy: _firebaseAuth.currentUser?.uid,
          createdBy: _firebaseAuth.currentUser?.uid,
          createdDate: DateTime.now(),
          modifiedDate: DateTime.now(),
        ).toJson();
        batch.set(_notificationCollectionReference.doc(notId), doc);
      }
      batch.commit();
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> updateGroupUsers({required List<String> userIds}) async {
    for (final id in userIds) {
      if (id.isNotEmpty)
        _userDataCollectionReference
            .doc(id)
            .update({'modifiedDate': DateTime.now()});
    }
  }

  Future<void> acceptJoinRequest(
      {required GroupDataModel group,
      required RequestModel request,
      required senderId}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      final notifications = await _notificationCollectionReference
          .where('senderId', isEqualTo: senderId)
          .where('status', isEqualTo: Status.active)
          .get()
          .then((value) => value.docs
              .map((e) => NotificationModel.fromJson(e.data()))
              .toList());
      final notificationIds = notifications
          .where((element) =>
              element.type == NotificationType.request &&
              element.groupId == group.id)
          .map((e) => e.id)
          .toList();
      final receiverNotifications = notifications
          .where((element) =>
              element.type == NotificationType.request &&
              element.groupId == group.id)
          .toList();
      final receiverIds = receiverNotifications
          .where((element) =>
              element.receiverId != FirebaseAuth.instance.currentUser?.uid)
          .map((e) => e.receiverId)
          .toList();

      final currentUser = await _userService
          .getUserByIdFuture(FirebaseAuth.instance.currentUser?.uid ?? '');
      final userName =
          (currentUser.firstName ?? '') + ' ' + (currentUser.lastName ?? '');
      final newUser =
          await _userService.getUserByIdFuture(request.userId ?? '');
      final newUserName =
          (newUser.firstName ?? '') + ' ' + (newUser.lastName ?? '');

      final user = GroupUserDataModel(
          id: request.userId,
          role: GroupUserRole.member,
          userId: request.userId,
          status: Status.active,
          enableNotificationForUpdates: true,
          notifyMeOfFlaggedPrayers: true,
          notifyWhenNewMemberJoins: true,
          enableNotificationForNewPrayers: true,
          createdBy: _firebaseAuth.currentUser?.uid,
          createdDate: DateTime.now(),
          modifiedBy: _firebaseAuth.currentUser?.uid,
          modifiedDate: DateTime.now());
      final notId = Uuid().v1();
      final doc = NotificationModel(
        id: notId,
        message: 'Your request to join this group has been accepted',
        status: Status.active,
        isSent: 0,
        senderId: _firebaseAuth.currentUser?.uid,
        tokens: [],
        type: NotificationType.accept_request,
        groupId: group.id,
        prayerId: '',
        receiverId: request.userId,
        modifiedBy: _firebaseAuth.currentUser?.uid,
        createdBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();

      final createdDate =
          Timestamp.fromDate(request.createdDate ?? DateTime.now());
      final modifiedDate =
          Timestamp.fromDate(request.modifiedDate ?? DateTime.now());

      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(_groupDataCollectionReference.doc(group.id), {
        'requests': FieldValue.arrayRemove([
          {
            'id': request.id,
            'userId': request.userId,
            'createdBy': request.createdBy,
            'createdDate': createdDate,
            'modifiedBy': request.modifiedBy,
            'modifiedDate': modifiedDate,
            'status': request.status
          }
        ])
      });
      batch.update(_groupDataCollectionReference.doc(group.id), {
        'modifiedDate': DateTime.now(),
        'users': FieldValue.arrayUnion([user.toJson()])
      });

      batch.update(_userDataCollectionReference.doc(request.userId), {
        'groups': FieldValue.arrayUnion([group.id])
      });

      batch.set(_notificationCollectionReference.doc(notId), doc);

      if (notificationIds.isNotEmpty)
        for (final id in notificationIds) {
          batch.update(_notificationCollectionReference.doc(id),
              {'status': Status.inactive});
        }
      if (receiverIds.isNotEmpty)
        for (final receiverId in receiverIds) {
          final notifId = Uuid().v1();

          final acceptedDoc = NotificationModel(
            id: notifId,
            message:
                "$userName has approved $newUserName's request to join group ${group.name}",
            status: Status.active,
            isSent: 0,
            senderId: _firebaseAuth.currentUser?.uid,
            tokens: [],
            type: NotificationType.accept_request,
            groupId: group.id,
            prayerId: '',
            receiverId: receiverId,
            modifiedBy: _firebaseAuth.currentUser?.uid,
            createdBy: _firebaseAuth.currentUser?.uid,
            createdDate: DateTime.now(),
            modifiedDate: DateTime.now(),
          ).toJson();

          batch.set(_notificationCollectionReference.doc(notifId), acceptedDoc);
        }

      batch.commit();
      updateGroupUsers(
          userIds: (group.users ?? []).map((e) => e.id ?? '').toList());
      analytics.logJoinGroup(groupId: group.id ?? '');
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> autoJoinGroup(
      {required GroupDataModel group, required String message}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final user = GroupUserDataModel(
        id: Uuid().v1(),
        userId: _firebaseAuth.currentUser?.uid,
        role: GroupUserRole.member,
        enableNotificationForNewPrayers: true,
        enableNotificationForUpdates: true,
        notifyMeOfFlaggedPrayers: true,
        notifyWhenNewMemberJoins: true,
        status: Status.active,
        createdBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedBy: _firebaseAuth.currentUser?.uid,
        modifiedDate: DateTime.now(),
      );

      final adminId = (group.users ?? [])
              .firstWhere((element) => element.role == GroupUserRole.admin)
              .userId ??
          '';

      final admin = await _userService.getUserByIdFuture(adminId);

      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(_groupDataCollectionReference.doc(group.id), {
        'modifiedDate': DateTime.now(),
        'users': FieldValue.arrayUnion([user.toJson()])
      });

      batch.update(
          _userDataCollectionReference.doc(_firebaseAuth.currentUser?.uid), {
        'groups': FieldValue.arrayUnion([group.id])
      });

      final notId = Uuid().v1();
      final doc = NotificationModel(
        id: notId,
        message: message,
        status: Status.active,
        isSent: 0,
        tokens: [],
        type: NotificationType.join_group,
        groupId: group.id,
        prayerId: '',
        receiverId: admin.id,
        modifiedBy: _firebaseAuth.currentUser?.uid,
        createdBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();
      batch.set(_notificationCollectionReference.doc(notId), doc);
      batch.commit();
      updateGroupUsers(
          userIds: (group.users ?? []).map((e) => e.id ?? '').toList());
      analytics.logJoinGroup(groupId: group.id ?? '');
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> deleteGroup(
      String groupId, List<NotificationModel> notifications) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final groupPrayers = await _prayerDataCollectionReference
          .where('groupId', isEqualTo: groupId)
          .get()
          .then((value) => value.docs
              .map((e) => PrayerDataModel.fromJson(e.data(), e.id))
              .toList());

      final group = await getGroup(groupId);
      final groupUsers = group.users;

      //remove all followed prayers from user lists
      if ((groupUsers ?? []).isNotEmpty) {
        (groupUsers ?? []).forEach((element) async {
          UserDataModel user =
              await _userService.getUserByIdFuture(element.userId ?? '');
          final prayerToRemove = (user.prayers ?? []).firstWhere(
            (e) => e.groupId == groupId,
            orElse: () => FollowedPrayer(),
          );
          final groupIdToRemove =
              (user.groups ?? []).firstWhere((element) => element == group.id);

          WriteBatch batch = FirebaseFirestore.instance.batch();
          for (final not in notifications) {
            batch.update(_notificationCollectionReference.doc(not.id),
                {'status': Status.inactive});
          }

          for (final prayer in groupPrayers) {
            batch.update(_prayerDataCollectionReference.doc(prayer.id),
                {'status': Status.deleted});
          }

          batch.update(_userDataCollectionReference.doc(element.userId), {
            'prayers': FieldValue.arrayRemove([prayerToRemove.toJson()])
          });
          batch.update(_userDataCollectionReference.doc(element.userId), {
            'groups': FieldValue.arrayRemove([groupIdToRemove])
          });

          batch.delete(
            _groupDataCollectionReference.doc(groupId),
          );
          batch.commit();
        });
      } else {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (final not in notifications) {
          batch.update(_notificationCollectionReference.doc(not.id),
              {'status': Status.inactive});
        }

        for (final prayer in groupPrayers) {
          batch.update(_prayerDataCollectionReference.doc(prayer.id),
              {'status': Status.deleted});
        }

        batch.delete(
          _groupDataCollectionReference.doc(groupId),
        );

        batch.commit();
      }
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> inviteMember(String groupName, String groupId, String email,
      String sender, String senderId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final dio = Dio(BaseOptions(followRedirects: false));

      final data = {
        'groupName': groupName,
        'groupId': groupId,
        'userId': _firebaseAuth.currentUser?.uid,
        'email': email,
        'sender': sender,
        'senderId': senderId,
      };
      await dio.post(
        'https://us-central1-bestill-app.cloudfunctions.net/GroupInvite',
        data: data,
      );
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> denyJoinRequest(
      {required GroupDataModel group,
      required RequestModel request,
      required String senderId}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      final notifications = await _notificationCollectionReference
          .where('senderId', isEqualTo: senderId)
          .where('status', isEqualTo: Status.active)
          .get()
          .then((value) => value.docs
              .map((e) => NotificationModel.fromJson(e.data()))
              .toList());
      final notificationIds = notifications
          .where((element) =>
              element.type == NotificationType.request &&
              element.groupId == group.id)
          .map((e) => e.id)
          .toList();
      final receiverNotifications = notifications
          .where((element) =>
              element.type == NotificationType.request &&
              element.groupId == group.id)
          .toList();
      final receiverIds = receiverNotifications
          .where((element) =>
              element.receiverId != FirebaseAuth.instance.currentUser?.uid)
          .map((e) => e.receiverId)
          .toList();

      final currentUser = await _userService
          .getUserByIdFuture(FirebaseAuth.instance.currentUser?.uid ?? '');
      final userName =
          (currentUser.firstName ?? '') + ' ' + (currentUser.lastName ?? '');
      final newUser =
          await _userService.getUserByIdFuture(request.userId ?? '');
      final newUserName =
          (newUser.firstName ?? '') + ' ' + (newUser.lastName ?? '');

      final createdDate =
          Timestamp.fromDate(request.createdDate ?? DateTime.now());
      final modifiedDate =
          Timestamp.fromDate(request.modifiedDate ?? DateTime.now());

      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(_groupDataCollectionReference.doc(group.id), {
        'modifiedDate': DateTime.now(),
        'requests': FieldValue.arrayRemove([
          {
            'id': request.id,
            'userId': request.userId,
            'createdBy': request.createdBy,
            'createdDate': createdDate,
            'modifiedBy': request.modifiedBy,
            'modifiedDate': modifiedDate,
            'status': request.status
          }
        ])
      });

      if (notificationIds.isNotEmpty)
        for (final id in notificationIds) {
          batch.update(_notificationCollectionReference.doc(id),
              {'status': Status.inactive});
        }
      if (receiverIds.isNotEmpty)
        for (final receiverId in receiverIds) {
          final notifId = Uuid().v1();

          final denyDoc = NotificationModel(
            id: notifId,
            message:
                "$userName has denied $newUserName's request to join group ${group.name}",
            status: Status.active,
            isSent: 0,
            senderId: _firebaseAuth.currentUser?.uid,
            tokens: [],
            type: NotificationType.deny_request,
            groupId: group.id,
            prayerId: '',
            receiverId: receiverId,
            modifiedBy: _firebaseAuth.currentUser?.uid,
            createdBy: _firebaseAuth.currentUser?.uid,
            createdDate: DateTime.now(),
            modifiedDate: DateTime.now(),
          ).toJson();

          batch.set(_notificationCollectionReference.doc(notifId), denyDoc);
        }

      batch.commit();

      // final createdDate =
      //     Timestamp.fromDate(request.createdDate ?? DateTime.now());
      // final modifiedDate =
      //     Timestamp.fromDate(request.modifiedDate ?? DateTime.now());

      // _groupDataCollectionReference.doc(group.id).update({
      //   'requests': FieldValue.arrayRemove([
      //     {
      //       'id': request.id,
      //       'userId': request.userId,
      //       'createdBy': request.createdBy,
      //       'createdDate': createdDate,
      //       'modifiedBy': request.modifiedBy,
      //       'modifiedDate': modifiedDate,
      //       'status': request.status
      //     }
      //   ])
      // });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> removeGroupUser(
      {required String userId, required String groupId}) async {
    try {
      UserDataModel user = await _userService.getUserByIdFuture(userId);
      GroupDataModel group = await getGroup(groupId);
      final groupUsers = group.users;
      final userToRemove = (groupUsers ?? []).firstWhere(
          (element) => element.userId == userId,
          orElse: () => GroupUserDataModel());

      final userGroups = user.groups;
      final userPrayers = user.prayers;

      final groupIdToRemove = (userGroups ?? [])
          .firstWhere((element) => element == groupId, orElse: () => '');

      final prayerToRemove = (userPrayers ?? [])
          .where((element) => element.groupId == groupId)
          .toList();
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (final element in prayerToRemove) {
        PrayerDataModel prayer =
            await _prayerService.getPrayerFuture(element.prayerId ?? '');
        FollowerModel follower = (prayer.followers ?? []).firstWhere(
          (e) => e.userId == userId,
          orElse: () => FollowerModel(),
        );

        final createdDate =
            Timestamp.fromDate(follower.createdDate ?? DateTime.now());
        final modifiedDate =
            Timestamp.fromDate(follower.modifiedDate ?? DateTime.now());

        final newFollowedPrayer = FollowedPrayer(
            prayerId: element.prayerId, groupId: element.groupId);

        batch.update(_userDataCollectionReference.doc(userId), {
          'prayers': FieldValue.arrayRemove([newFollowedPrayer.toJson()])
        });
        batch.update(_prayerDataCollectionReference.doc(element.prayerId), {
          'followers': FieldValue.arrayRemove([
            {
              'id': follower.id,
              'userId': follower.userId,
              'prayerStatus': follower.prayerStatus,
              'createdBy': follower.createdBy,
              'createdDate': createdDate,
              'modifiedBy': follower.modifiedBy,
              'modifiedDate': modifiedDate,
              'status': follower.status
            }
          ])
        });
      }
      final notifications = await _notificationCollectionReference
          .where('groupId', isEqualTo: groupId)
          .where('receiverId', isEqualTo: userId)
          .get()
          .then((value) =>
              value.docs.map((e) => NotificationModel.fromJson(e.data())));

      for (final not in notifications) {
        batch.update(_notificationCollectionReference.doc(not.id),
            {'status': Status.inactive});
      }

      batch.update(_groupDataCollectionReference.doc(groupId), {
        'users': FieldValue.arrayRemove([
          {
            'id': userToRemove.id,
            'userId': userToRemove.userId,
            'role': userToRemove.role,
            'enableNotificationForNewPrayers':
                userToRemove.enableNotificationForNewPrayers,
            'enableNotificationForUpdates':
                userToRemove.enableNotificationForUpdates,
            'notifyMeOfFlaggedPrayers': userToRemove.notifyMeOfFlaggedPrayers,
            'notifyWhenNewMemberJoins': userToRemove.notifyWhenNewMemberJoins,
            'createdBy': userToRemove.createdBy,
            'createdDate':
                Timestamp.fromDate(userToRemove.createdDate ?? DateTime.now()),
            'modifiedBy': userToRemove.modifiedBy,
            'modifiedDate':
                Timestamp.fromDate(userToRemove.modifiedDate ?? DateTime.now()),
            'status': userToRemove.status
          }
        ])
      });

      batch.update(_userDataCollectionReference.doc(user.id), {
        'groups': FieldValue.arrayRemove([groupIdToRemove])
      });

      batch.commit();
      updateGroupUsers(
          userIds: (group.users ?? []).map((e) => e.id ?? '').toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> updateGroupUserSettings(
      GroupDataModel group, String key, dynamic value) async {
    try {
      final mappedUsers = (group.users ?? []).map((e) {
        if (e.userId == _firebaseAuth.currentUser?.uid) {
          final x = e.toJson();
          x[key] = value;
          return x;
        }
        return e.toJson();
      }).toList();
      _groupDataCollectionReference
          .doc(group.id)
          .update({'users': mappedUsers});
      updateGroupUsers(
          userIds: (group.users ?? []).map((e) => e.id ?? '').toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }
}
