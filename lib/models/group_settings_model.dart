class GroupSettings {
  final String? id;
  final String? userId;
  final String? groupId;
  final bool? enableNotificationFormNewPrayers;
  final bool? enableNotificationForUpdates;
  final bool? notifyOfMembershipRequest;
  final bool? notifyMeofFlaggedPrayers;
  final bool? notifyWhenNewMemberJoins;
  final String? createdBy;
  final bool? requireAdminApproval;
  final DateTime? createdOn;
  final String? modifiedBy;
  final DateTime? modifiedOn;

  const GroupSettings({
    this.id,
    this.userId,
    this.requireAdminApproval,
    this.groupId,
    this.enableNotificationFormNewPrayers,
    this.enableNotificationForUpdates,
    this.notifyOfMembershipRequest,
    this.notifyMeofFlaggedPrayers,
    this.notifyWhenNewMemberJoins,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });

  factory GroupSettings.defaultValue() {
    DateTime now = DateTime.now();
    final createdOn = now;
    final modifiedOn = now;
    final id = '';
    final userId = '';
    final groupId = '';
    final createdBy = '';
    final modifiedBy = '';
    final requireAdminApproval = false;
    final enableNotificationFormNewPrayers = false;
    final enableNotificationForUpdates = false;
    final notifyOfMembershipRequest = false;
    final notifyMeofFlaggedPrayers = false;
    final notifyWhenNewMemberJoins = false;
    return GroupSettings(
        id: id,
        userId: userId,
        requireAdminApproval: requireAdminApproval,
        groupId: groupId,
        enableNotificationFormNewPrayers: enableNotificationFormNewPrayers,
        enableNotificationForUpdates: enableNotificationForUpdates,
        notifyOfMembershipRequest: notifyOfMembershipRequest,
        notifyMeofFlaggedPrayers: notifyMeofFlaggedPrayers,
        notifyWhenNewMemberJoins: notifyWhenNewMemberJoins,
        createdBy: createdBy,
        createdOn: createdOn,
        modifiedBy: modifiedBy,
        modifiedOn: modifiedOn);
  }
  factory GroupSettings.fromData(Map<String, dynamic> data, String did) {
    final String id = did;
    final String userId = data['UserId'] ?? '';
    final String groupId = data['GroupId'] ?? '';
    final bool enableNotificationFormNewPrayers =
        data['EnableNotificationFormNewPrayers'] ?? false;
    final bool requireAdminApproval = data['RequireAdminApproval'] ?? true;
    final bool enableNotificationForUpdates =
        data['EnableNotificationForUpdates'] ?? false;
    final bool notifyOfMembershipRequest =
        data['NotifyOfMembershipRequest'] ?? false;
    final bool notifyMeofFlaggedPrayers =
        data['NotifyMeofFlaggedPrayers'] ?? false;
    final bool notifyWhenNewMemberJoins =
        data['NotifyWhenNewMemberJoins'] ?? false;
    final String createdBy = data['CreatedBy'] ?? '';
    final DateTime createdOn = data['CreatedOn']?.toDate() ?? DateTime.now();
    final String modifiedBy = data['ModifiedBy'] ?? '';
    final DateTime modifiedOn = data['ModifiedOn']?.toDate() ?? DateTime.now();

    return GroupSettings(
        id: id,
        userId: userId,
        requireAdminApproval: requireAdminApproval,
        groupId: groupId,
        enableNotificationFormNewPrayers: enableNotificationFormNewPrayers,
        enableNotificationForUpdates: enableNotificationForUpdates,
        notifyOfMembershipRequest: notifyOfMembershipRequest,
        notifyMeofFlaggedPrayers: notifyMeofFlaggedPrayers,
        notifyWhenNewMemberJoins: notifyWhenNewMemberJoins,
        createdBy: createdBy,
        createdOn: createdOn,
        modifiedBy: modifiedBy,
        modifiedOn: modifiedOn);
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'GroupId': groupId,
      'EnableNotificationFormNewPrayers': enableNotificationFormNewPrayers,
      'EnableNotificationForUpdates': enableNotificationForUpdates,
      'NotifyOfMembershipRequest': notifyOfMembershipRequest,
      'RequireAdminApproval': requireAdminApproval,
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
  final String? id;
  final String? userId;
  final bool? enableNotificationForAllGroups;

  const GroupPreferenceSettings({
    this.id,
    this.userId,
    this.enableNotificationForAllGroups,
  });

  factory GroupPreferenceSettings.defaultValue() => GroupPreferenceSettings(
      id: '', userId: '', enableNotificationForAllGroups: false);

  factory GroupPreferenceSettings.fromData(
      Map<String, dynamic> data, String did) {
    final id = did;
    final userId = data['UserId'];
    final enableNotificationForAllGroups =
        data['EnableNotificationForAllGroups'];
    return GroupPreferenceSettings(
        id: id,
        userId: userId,
        enableNotificationForAllGroups: enableNotificationForAllGroups);
  }
  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'EnableNotificationForAllGroups': enableNotificationForAllGroups,
    };
  }
}
