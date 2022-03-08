import 'dart:io';

import 'package:be_still/enums/request_status.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/user_role.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/request.model.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class GroupServiceV2 {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>>
      _groupDataCollectionReference =
      FirebaseFirestore.instance.collection("groups");

  final CollectionReference<Map<String, dynamic>>
      _prayerDataCollectionReference =
      FirebaseFirestore.instance.collection("prayers");

  final CollectionReference<Map<String, dynamic>> _userDataCollectionReference =
      FirebaseFirestore.instance.collection("users");

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

      final group = await _groupDataCollectionReference.add(doc);
      await _userDataCollectionReference
          .doc(_firebaseAuth.currentUser?.uid)
          .update({
        'groups': FieldValue.arrayUnion([group.id])
      });
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
      await _groupDataCollectionReference.doc(groupId).update({
        'purpose': purpose,
        'name': name,
        'organization': organization,
        'location': location,
        'type': type,
        'requireAdminApproval': requireAdminApproval,
        'modifiedBy': _firebaseAuth.currentUser?.uid,
        'modifiedDate': DateTime.now()
      });
      return true;
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<GroupDataModel>> getUserGroups(List<String> userGroupsId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      if (userGroupsId.isEmpty) return Stream.value([]);
      return _groupDataCollectionReference
          .where('status', isEqualTo: Status.active)
          .where(FieldPath.documentId, whereIn: userGroupsId)
          .snapshots()
          .map((event) => event.docs
              .map((e) => GroupDataModel.fromJson(e.data()))
              .toList());
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
      return GroupDataModel.fromJson(doc.data()!);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
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
      await _groupDataCollectionReference.doc(group.id).update(group.toJson());
      await _userDataCollectionReference.doc(request.userId).set({
        'groups': FieldValue.arrayUnion([group.id])
      });
      //todo send push notification
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> autoJoinGroup({
    required GroupDataModel group,
    required String message,
  }) async {
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
      await _groupDataCollectionReference.doc(group.id).update(group.toJson());
      await _userDataCollectionReference
          .doc(_firebaseAuth.currentUser?.uid)
          .set({
        'groups': FieldValue.arrayUnion([group.id])
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _groupDataCollectionReference
          .doc(groupId)
          .update({'status': Status.deleted});
      //remove all followed prayers from user lists

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

  Stream<List<GroupDataModel>> getGroups() {
    try {
      return _groupDataCollectionReference
          .where('status', isNotEqualTo: Status.deleted)
          .snapshots()
          .map((event) => event.docs
              .map((e) => GroupDataModel.fromJson(e.data()))
              .toList());
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
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

  Future<void> deleteGroupUser({
    required String userId,
    required String groupId,
    required List<GroupUserDataModel> groupUsers,
    required List<FollowerModel> followers,
  }) async {
    try {
      groupUsers.removeWhere((element) => element.userId == userId);
      groupUsers.map((e) {
        e.modifiedBy = _firebaseAuth.currentUser?.uid;
        e.modifiedDate = DateTime.now();
      });
      followers.removeWhere(
          (element) => element.userId == _firebaseAuth.currentUser?.uid);
      followers.map((e) {
        e.modifiedBy = _firebaseAuth.currentUser?.uid;
        e.modifiedDate = DateTime.now();
      });
      await _groupDataCollectionReference
          .doc(groupId)
          .update({'users': groupUsers});
      removePrayerFromUserList(userId);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> removePrayerFromUserList(String userId) async {
    final prayers = await _prayerDataCollectionReference
        .where('followers.userId', isEqualTo: _firebaseAuth.currentUser?.uid)
        .where('status', isNotEqualTo: Status.deleted)
        .get();

    for (final prayer in prayers.docs) {
      final followers =
          (PrayerDataModel.fromJson(prayer.data()).followers ?? [])
              .where((element) => element.userId != userId);
      prayer.reference.update({'': followers});
    }
  }

  Future<void> updateGroupSettings({
    required String groupId,
    required bool enableNotificationForUpdates,
    required bool notifyMeofFlaggedPrayers,
    required bool notifyWhenNewMemberJoins,
  }) async {
    try {
      await _groupDataCollectionReference.doc(groupId).update({
        'enableNotificationForUpdates': enableNotificationForUpdates,
        'notifyMeofFlaggedPrayers': notifyMeofFlaggedPrayers,
        'notifyWhenNewMemberJoins': notifyWhenNewMemberJoins,
        'modifiedBy': _firebaseAuth.currentUser?.uid,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  leaveGroup(
      {required String groupId,
      required List<GroupUserDataModel> users,
      required String userId}) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      users = users..where((element) => element.userId != userId).toList();
      _groupDataCollectionReference.doc(groupId).update({'users': users});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }
}
