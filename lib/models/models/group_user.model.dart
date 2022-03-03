class GroupUserModel {
  String? id;
  String? userId;
  String? role;
  bool? enableNotificationForUpdates;
  bool? notifyMeOfFlaggedPrayers;
  bool? notifyWhenNewMemberJoins;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? status;

  GroupUserModel(
      {this.id,
      this.userId,
      this.role,
      this.enableNotificationForUpdates,
      this.notifyMeOfFlaggedPrayers,
      this.notifyWhenNewMemberJoins,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  GroupUserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    role = json['role'];
    enableNotificationForUpdates = json['enableNotificationForUpdates'];
    notifyMeOfFlaggedPrayers = json['notifyMeOfFlaggedPrayers'];
    notifyWhenNewMemberJoins = json['notifyWhenNewMemberJoins'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdDate = json['createdDate'];
    modifiedDate = json['modifiedDate'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['role'] = this.role;
    data['enableNotificationForUpdates'] = this.enableNotificationForUpdates;
    data['notifyMeOfFlaggedPrayers'] = this.notifyMeOfFlaggedPrayers;
    data['notifyWhenNewMemberJoins'] = this.notifyWhenNewMemberJoins;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
