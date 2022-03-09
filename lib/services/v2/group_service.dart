import 'dart:io';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/request_status.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/models/v2/notification.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/request.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/services/v2/notification_service.dart';
import 'package:be_still/services/v2/prayer_service.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiver/iterables.dart';
import 'package:uuid/uuid.dart';

class GroupServiceV2 {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserServiceV2 _userService = locator<UserServiceV2>();

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

  Future<bool> createGroup(
      {required String name,
      required String purpose,
      required bool requireAdminApproval,
      required String organization,
      required String location,
      required String type}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);

      final doc = GroupDataModel(
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
      final groupId = Uuid().v1();
      batch.set(_groupDataCollectionReference.doc(groupId), doc);
      batch.update(
          _userDataCollectionReference.doc(_firebaseAuth.currentUser?.uid), {
        'groups': FieldValue.arrayUnion([groupId])
      });
      batch.commit();
      return true;
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<bool> editGroup(
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
            .where((e) => e.status == Status.active)
            .toList();
        for (final req in activeRequests) {
          acceptJoinRequest(group: group, request: req);
        }
        // add each to group
        // send notification that they joined
      }
      return true;
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  // Stream<List<GroupDataModel>> getUserGroups(List<String> userGroupsId) {
  //   try {
  //     if (_firebaseAuth.currentUser == null)
  //       return Stream.error(StringUtils.unathorized);
  //     if (userGroupsId.isEmpty) return Stream.value([]);
  //     return _groupDataCollectionReference
  //         .where('status', isEqualTo: Status.active)
  //         .where(FieldPath.documentId, whereIn: userGroupsId)
  //         .snapshots()
  //         .map((event) => event.docs
  //             .map((e) => GroupDataModel.fromJson(e.data(), e.id))
  //             .toList());
  //   } catch (e) {
  //     throw HttpException(StringUtils.getErrorMessage(e));
  //   }
  // }

  Future<List<GroupDataModel>> getUserGroupsFuture() async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final user = await _userDataCollectionReference
          .doc(_firebaseAuth.currentUser?.uid)
          .get();
      List<String> userGroupsId =
          UserDataModel.fromJson(user.data()!, user.id).groups ?? [];
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

  Stream<List<GroupDataModel>> getGroups() {
    try {
      return _groupDataCollectionReference
          .where('status', isNotEqualTo: Status.deleted)
          .snapshots()
          .map((event) => event.docs
              .map((e) => GroupDataModel.fromJson(e.data(), e.id))
              .toList());
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
    }
  }

  Future<void> requestToJoinGroup({
    required String groupId,
    required String message,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final request = RequestModel(
        id: Uuid().v1(),
        userId: _firebaseAuth.currentUser?.uid,
        status: Status.active,
        createdBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedBy: _firebaseAuth.currentUser?.uid,
        modifiedDate: DateTime.now(),
      ).toJson();

      await _groupDataCollectionReference.doc(groupId).update({
        "requests": FieldValue.arrayUnion([request])
      });
      //todo send push notification
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> acceptJoinRequest(
      {required GroupDataModel group, required RequestModel request}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
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
      group = group..users?.add(user);
      group = group..requests?.where((e) => e.id == request.id);
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(_groupDataCollectionReference.doc(group.id), group.toJson());
      batch.update(_userDataCollectionReference.doc(request.userId), {
        'groups': FieldValue.arrayUnion([group.id])
      });

      final requestor =
          await _userService.getUserByIdFuture(request.userId ?? '');
      final notId = Uuid().v1();
      final doc = NotificationModel(
        id: notId,
        message: 'Your request to join this group has been accepted',
        status: Status.active,
        tokens: (requestor.devices ?? []).map((e) => e.token ?? '').toList(),
        type: NotificationType.accept_request,
        groupId: group.id,
        prayerId: '',
        userId: _firebaseAuth.currentUser?.uid,
        modifiedBy: _firebaseAuth.currentUser?.uid,
        createdBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();
      batch.set(_notificationCollectionReference.doc(notId), doc);
      final notifications = await _notificationCollectionReference
          .where('groupId', isEqualTo: group.id)
          .where('type', isEqualTo: NotificationType.request)
          .get()
          .then((value) =>
              value.docs.map((e) => NotificationModel.fromJson(e.data())));

      for (final not in notifications) {
        batch.update(_notificationCollectionReference.doc(not.id),
            {'status': Status.inactive});
      }
      batch.commit();
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
        enableNotificationForUpdates: true,
        notifyMeOfFlaggedPrayers: true,
        notifyWhenNewMemberJoins: true,
        status: Status.active,
        createdBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedBy: _firebaseAuth.currentUser?.uid,
        modifiedDate: DateTime.now(),
      );

      group = group..users?.add(user);
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(_groupDataCollectionReference.doc(group.id), group.toJson());
      batch.update(
          _userDataCollectionReference.doc(_firebaseAuth.currentUser?.uid), {
        'groups': FieldValue.arrayUnion([group.id])
      });
      batch.commit();
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> deleteGroup(
      String groupId, List<NotificationModel> notifications) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (final not in notifications) {
        batch.update(_notificationCollectionReference.doc(not.id),
            {'status': Status.inactive});
      }
      final groupPrayers = await _prayerDataCollectionReference
          .where('groupId', isEqualTo: groupId)
          .get()
          .then((value) => value.docs
              .map((e) => PrayerDataModel.fromJson(e.data(), e.id))
              .toList());
      for (final prayer in groupPrayers) {
        batch.update(_prayerDataCollectionReference.doc(prayer.id),
            {'status': Status.deleted});
      }

      batch.update(_groupDataCollectionReference.doc(groupId),
          {'status': Status.deleted});

      //remove all followed prayers from user lists
      batch.commit();
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
      {required GroupDataModel group, required String requestId}) async {
    try {
      group = group..requests?.where((e) => e.id == requestId);
      await _groupDataCollectionReference.doc(group.id).update(group.toJson());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> removeGroupUser(
      {required String userId, required String groupId}) async {
    try {
      UserDataModel user = await _userService.getUserByIdFuture(userId);
      GroupDataModel group = await getGroup(userId);
      group = group
        ..users?.where((element) => element.userId != userId).toList();
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(_groupDataCollectionReference.doc(groupId), group.toJson());

      user = user
        ..prayers?.where((element) => element.groupId != groupId).toList();
      batch.update(_userDataCollectionReference.doc(user.id), user.toJson());
      batch.commit();
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
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }
}
