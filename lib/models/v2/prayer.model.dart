import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/update.model.dart';

class PrayerDataModel {
  String? id;
  String? description;
  bool? isAnswered;
  bool? isInappropriate;
  bool? isGroup;
  bool? isFavorite;
  String? userId;
  String? groupId;
  String? snoozeEndDate;
  List<UpdateModel>? updates;
  List<TagModel>? tags;
  List<FollowerModel>? followers;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? status;

  PrayerDataModel(
      {this.id,
      this.description,
      this.isAnswered,
      this.isInappropriate,
      this.isGroup,
      this.isFavorite,
      this.userId,
      this.groupId,
      this.snoozeEndDate,
      this.updates,
      this.tags,
      this.followers,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  PrayerDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    isAnswered = json['isAnswered'];
    isInappropriate = json['isInappropriate'];
    isGroup = json['isGroup'];
    isFavorite = json['isFavorite'];
    userId = json['userId'];
    groupId = json['groupId'];
    snoozeEndDate = json['snoozeEndDate'];
    if (json['updates'] != null) {
      updates = <UpdateModel>[];
      json['updates'].forEach((v) {
        updates!.add(new UpdateModel.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      tags = <TagModel>[];
      json['tags'].forEach((v) {
        tags!.add(new TagModel.fromJson(v));
      });
    }
    if (json['followers'] != null) {
      followers = <FollowerModel>[];
      json['followers'].forEach((v) {
        followers!.add(new FollowerModel.fromJson(v));
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
    data['description'] = this.description;
    data['isAnswered'] = this.isAnswered;
    data['isInappropriate'] = this.isInappropriate;
    data['isGroup'] = this.isGroup;
    data['isFavorite'] = this.isFavorite;
    data['userId'] = this.userId;
    data['groupId'] = this.groupId;
    data['snoozeEndDate'] = this.snoozeEndDate;
    if (this.updates != null) {
      data['updates'] = this.updates!.map((v) => v.toJson()).toList();
    }
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    }
    if (this.followers != null) {
      data['followers'] = this.followers!.map((v) => v.toJson()).toList();
    }
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
