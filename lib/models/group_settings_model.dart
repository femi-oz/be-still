import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupSettings {
  final String id;
  final String userId;
  final String groupId;
  final bool enableNotificationFormNewPrayers;
  final bool enableNotificationForUpdates;
  final bool notifyOfMembershipRequest;
  final bool notifyMeofFlaggedPrayers;
  final bool notifyWhenNewMemberJoins;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GroupSettings({
    this.id,
    @required this.userId,
    @required this.groupId,
    @required this.enableNotificationFormNewPrayers,
    @required this.enableNotificationForUpdates,
    @required this.notifyOfMembershipRequest,
    @required this.notifyMeofFlaggedPrayers,
    @required this.notifyWhenNewMemberJoins,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  GroupSettings.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()['UserId'],
        groupId = snapshot.data()['GroupId'],
        enableNotificationFormNewPrayers =
            snapshot.data()['EnableNotificationFormNewPrayers'],
        enableNotificationForUpdates =
            snapshot.data()['EnableNotificationForUpdates'],
        notifyOfMembershipRequest =
            snapshot.data()['NotifyOfMembershipRequest'],
        notifyMeofFlaggedPrayers = snapshot.data()['NotifyMeofFlaggedPrayers'],
        notifyWhenNewMemberJoins = snapshot.data()['NotifyWhenNewMemberJoins'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'GroupId': groupId,
      'EnableNotificationFormNewPrayers': enableNotificationFormNewPrayers,
      'EnableNotificationForUpdates': enableNotificationForUpdates,
      'NotifyOfMembershipRequest': notifyOfMembershipRequest,
      'NotifyMeofFlaggedPrayers': notifyMeofFlaggedPrayers,
      'NotifyWhenNewMemberJoins': notifyWhenNewMemberJoins,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class GroupPreferenceSettings {
  final String id;
  final String userId;
  final bool enableNotificationForAllGroups;

  const GroupPreferenceSettings({
    this.id,
    @required this.userId,
    @required this.enableNotificationForAllGroups,
  });

  GroupPreferenceSettings.fromData(
      DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()['UserId'],
        enableNotificationForAllGroups =
            snapshot.data()['EnableNotificationForAllGroups'];
  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'EnableNotificationForAllGroups': enableNotificationForAllGroups,
    };
  }
}
