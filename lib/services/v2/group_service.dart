import 'package:be_still/enums/status.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/http_exception.dart';
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
}
