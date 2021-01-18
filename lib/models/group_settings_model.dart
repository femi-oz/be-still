import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupSettings {
  final String id;
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

  GroupSettings.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        enableNotificationFormNewPrayers =
            snapshot.data()['enableNotificationFormNewPrayers'],
        enableNotificationForUpdates =
            snapshot.data()['enableNotificationForUpdates'],
        notifyOfMembershipRequest =
            snapshot.data()['notifyOfMembershipRequest'],
        notifyMeofFlaggedPrayers = snapshot.data()['notifyMeofFlaggedPrayers'],
        notifyWhenNewMemberJoins = snapshot.data()['notifyWhenNewMemberJoins'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'enableNotificationFormNewPrayers': enableNotificationFormNewPrayers,
      'enableNotificationForUpdates': enableNotificationForUpdates,
      'notifyOfMembershipRequest': notifyOfMembershipRequest,
      'notifyMeofFlaggedPrayers': notifyMeofFlaggedPrayers,
      'notifyWhenNewMemberJoins': notifyWhenNewMemberJoins,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
