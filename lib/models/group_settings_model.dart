import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GrupSettings {
  final String id;
  final bool enableNotificationFormNewPrayers;
  final bool enableNotificationForUpdates;
  final bool noityOfMembershipRequest;
  final bool notifyMeofFlaggedPrayers;
  final bool notifyWhenNewMemberJoins;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const GrupSettings({
    this.id,
    @required this.enableNotificationFormNewPrayers,
    @required this.enableNotificationForUpdates,
    @required this.noityOfMembershipRequest,
    @required this.notifyMeofFlaggedPrayers,
    @required this.notifyWhenNewMemberJoins,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  GrupSettings.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        enableNotificationFormNewPrayers =
            snapshot.data()['enableNotificationFormNewPrayers'],
        enableNotificationForUpdates =
            snapshot.data()['enableNotificationForUpdates'],
        noityOfMembershipRequest = snapshot.data()['noityOfMembershipRequest'],
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
      'noityOfMembershipRequest': noityOfMembershipRequest,
      'notifyMeofFlaggedPrayers': notifyMeofFlaggedPrayers,
      'notifyWhenNewMemberJoins': notifyWhenNewMemberJoins,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
