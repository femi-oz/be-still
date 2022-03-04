import 'package:be_still/enums/request_status.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/models/follower.model.dart';
import 'package:be_still/models/models/group.model.dart';
import 'package:be_still/models/models/group_user.model.dart';
import 'package:be_still/models/models/request.model.dart';
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
      {required String userId,
      required String name,
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
            userId: userId,
            status: Status.active,
            createdBy: userId,
            modifiedBy: userId,
            createdDate: DateTime.now(),
            modifiedDate: DateTime.now(),
          )
        ],
        status: Status.active,
        createdBy: userId,
        modifiedBy: userId,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
      ).toJson();
      await _groupDataCollectionReference.add(doc);
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<GroupDataModel>> getUserGroups(String userId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _groupDataCollectionReference
          .where('users.userId', isEqualTo: userId)
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
    required String userId,
    required String description,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final docId = Uuid().v1();
      currentRequests = currentRequests
        ..add(RequestModel(
          id: docId,
          userId: userId,
          status: Status.active,
          createdBy: userId,
          createdDate: DateTime.now(),
          modifiedBy: userId,
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
    required String userId,
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
          modifiedBy: userId,
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
    required String userId,
    required String description,
  }) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final docId = Uuid().v1();
      currentUsers = currentUsers
        ..add(GroupUserDataModel(
          id: docId,
          userId: userId,
          role: GroupUserRole.member,
          enableNotificationForUpdates: true,
          notifyMeOfFlaggedPrayers: true,
          notifyWhenNewMemberJoins: true,
          status: Status.active,
          createdBy: userId,
          createdDate: DateTime.now(),
          modifiedBy: userId,
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
      String sender, String senderId, String userId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final dio = Dio(BaseOptions(followRedirects: false));

      final data = {
        'groupName': groupName,
        'groupId': groupId,
        'userId': userId,
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
      required String userId,
      required GroupDataModel groupData}) async {
    try {
      await groupReference.update({
        'purpose': groupData.purpose,
        'name': groupData.name,
        'organization': groupData.organization,
        'location': groupData.location,
        'type': groupData.type,
        'requireAdminApproval': groupData.requireAdminApproval,
        'modifiedBy': userId,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> denyJoinRequest(
      {required DocumentReference groupReference,
      required String userId,
      required String requestId,
      required List<RequestModel> requests}) async {
    try {
      List<RequestModel> requestToUpdate =
          requests.where((element) => element.id == requestId).toList();
      requestToUpdate.map((e) {
        e.status = RequestStatus.denied;
        e.modifiedBy = userId;
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
    required String userId,
  }) async {
    try {
      groupUsers.removeWhere((element) => element.userId == userId);
      groupUsers.map((e) {
        e.modifiedBy = userId;
        e.modifiedDate = DateTime.now();
      });
      followers.removeWhere((element) => element.userId == userId);
      followers.map((e) {
        e.modifiedBy = userId;
        e.modifiedDate = DateTime.now();
      });
      await groupReference.update({'users': groupUsers});
      await prayerReference.update({'followers': followers});
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }

  Future<void> updateGroupSettings(
      {required DocumentReference groupReference,
      required bool enableNotificationForUpdates,
      required bool notifyMeofFlaggedPrayers,
      required bool notifyWhenNewMemberJoins,
      required String userId}) async {
    try {
      await groupReference.update({
        'enableNotificationForUpdates': enableNotificationForUpdates,
        'notifyMeofFlaggedPrayers': notifyMeofFlaggedPrayers,
        'notifyWhenNewMemberJoins': notifyWhenNewMemberJoins,
        'modifiedBy': userId,
        'modifiedDate': DateTime.now()
      });
    } catch (e) {
      StringUtils.getErrorMessage(e);
    }
  }
}
