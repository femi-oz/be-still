import 'package:be_still/models/v2/group_user.model.dart';
import 'package:be_still/models/v2/request.model.dart';

class GroupDataModel {
  String? id;
  String? purpose;
  String? name;
  String? organization;
  String? location;
  String? type;
  bool? requireAdminApproval;
  List<GroupUserDataModel>? users;
  List<RequestModel>? requests;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? status;

  GroupDataModel(
      {this.id,
      this.purpose,
      this.name,
      this.organization,
      this.location,
      this.type,
      this.requireAdminApproval,
      this.users,
      this.requests,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  GroupDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    purpose = json['purpose'];
    name = json['name'];
    organization = json['organization'];
    location = json['location'];
    type = json['type'];
    requireAdminApproval = json['requireAdminApproval'];
    if (json['users'] != null) {
      users = <GroupUserDataModel>[];
      json['users'].forEach((v) {
        users!.add(new GroupUserDataModel.fromJson(v));
      });
    }
    if (json['requests'] != null) {
      requests = <RequestModel>[];
      json['requests'].forEach((v) {
        requests!.add(new RequestModel.fromJson(v));
      });
    }
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdDate = json['createdDate'];
    modifiedDate = json['modifiedDate'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['purpose'] = this.purpose;
    data['name'] = this.name;
    data['organization'] = this.organization;
    data['location'] = this.location;
    data['type'] = this.type;
    data['requireAdminApproval'] = this.requireAdminApproval;
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    if (this.requests != null) {
      data['requests'] = this.requests!.map((v) => v.toJson()).toList();
    }
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
