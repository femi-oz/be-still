import 'dart:io';

import 'package:be_still/enums/request_status.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/group.model.dart';
import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/models/v2/request.model.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class GroupService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>>
      _groupDataCollectionReference =
      FirebaseFirestore.instance.collection("groups_v2");

  Future<void> createGroup(
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
        type: type,
        users: [
          GroupUserDataModel(
            enableNotificationForUpdates: true,
            notifyMeOfFlaggedPrayers: true,
            notifyWhenNewMemberJoins: true,
            role: GroupUserRole.admin,
            userId: _firebaseAuth.currentUser?.uid,
            status: Status.active,
            createdBy: _firebaseAuth.currentUser?.uid,
            modifiedBy: _firebaseAuth.currentUser?.uid,
            createdDate: DateTime.now(),
            modifiedDate: DateTime.now(),
          )
        ],
        status: Status.active,
        createdBy: _firebaseAuth.currentUser?.uid,
        modifiedBy: _firebaseAuth.currentUser?.uid,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();
      await _groupDataCollectionReference.add(doc);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<GroupDataModel>> getUserGroups() {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _groupDataCollectionReference
          .where('users.userId', isEqualTo: _firebaseAuth.currentUser?.uid)
          .snapshots()
          .map((event) => event.docs
              .map((e) => GroupDataModel.fromJson(e.data()))
              .toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> requestToJoinGroup({
    required DocumentReference groupReference,
    required List<RequestModel> currentRequests,
    required String description,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final docId = Uuid().v1();
      currentRequests = currentRequests
        ..add(RequestModel(
          id: docId,
          userId: _firebaseAuth.currentUser?.uid,
          status: Status.active,
          createdBy: _firebaseAuth.currentUser?.uid,
          createdDate: DateTime.now(),
          modifiedBy: _firebaseAuth.currentUser?.uid,
          modifiedDate: DateTime.now(),
        ));

      await groupReference
          .update({"requests": currentRequests.map((e) => e.toJson())});
      //todo send push notification
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> acceptJoinRequest({
    required DocumentReference groupReference,
    required List<RequestModel> currentRequests,
    required RequestModel request,
    required String requestId,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      currentRequests[currentRequests.indexOf(request)] = RequestModel(
          id: request.id,
          userId: request.userId,
          status: request.status,
          createdBy: request.createdBy,
          createdDate: request.createdDate,
          modifiedBy: _firebaseAuth.currentUser?.uid,
          modifiedDate: DateTime.now());

      await groupReference
          .update({"requests": currentRequests.map((e) => e.toJson())});
      //todo send push notification
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> autoJoinGroup({
    required DocumentReference groupReference,
    required List<GroupUserDataModel> currentUsers,
    required String description,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final docId = Uuid().v1();
      currentUsers = currentUsers
        ..add(GroupUserDataModel(
          id: docId,
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
        ));

      await groupReference
          .update({"users": currentUsers.map((e) => e.toJson())});
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<void> deleteGroup({required DocumentReference groupReference}) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      groupReference.delete();
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
      return _groupDataCollectionReference.snapshots().map((event) =>
          event.docs.map((e) => GroupDataModel.fromJson(e.data())).toList());
    } catch (e) {
      throw StringUtils.getErrorMessage(e);
    }
  }

  Future<void> editGroup(
      {required DocumentReference groupReference,
      required String groupId,
      required GroupDataModel groupData}) async {
    try {
      await groupReference.update({
        'purpose': groupData.purpose,
        'name': groupData.name,
        'organization': groupData.organization,
        'location': groupData.location,
        'type': groupData.type,
        'requireAdminApproval': groupData.requireAdminApproval,
        'modifiedBy': _firebaseAuth.currentUser?.uid,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> denyJoinRequest(
      {required DocumentReference groupReference,
      required String requestId,
      required List<RequestModel> requests}) async {
    try {
      List<RequestModel> requestToUpdate =
          requests.where((element) => element.id == requestId).toList();
      requestToUpdate.map((e) {
        e.status = RequestStatus.denied;
        e.modifiedBy = _firebaseAuth.currentUser?.uid;
        e.modifiedDate = DateTime.now();
      });

      await groupReference.update({'requests': requestToUpdate});
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> deleteGroupUser({
    required DocumentReference groupReference,
    required DocumentReference prayerReference,
    required List<GroupUserDataModel> groupUsers,
    required List<FollowerModel> followers,
  }) async {
    try {
      groupUsers.removeWhere(
          (element) => element.userId == _firebaseAuth.currentUser?.uid);
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
      await groupReference.update({'users': groupUsers});
      await prayerReference.update({'followers': followers});
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> updateGroupSettings({
    required DocumentReference groupReference,
    required bool enableNotificationForUpdates,
    required bool notifyMeofFlaggedPrayers,
    required bool notifyWhenNewMemberJoins,
  }) async {
    try {
      await groupReference.update({
        'enableNotificationForUpdates': enableNotificationForUpdates,
        'notifyMeofFlaggedPrayers': notifyMeofFlaggedPrayers,
        'notifyWhenNewMemberJoins': notifyWhenNewMemberJoins,
        'modifiedBy': _firebaseAuth.currentUser?.uid,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }
}
