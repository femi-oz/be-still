import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/update.model.dart';

class PrayerDataModel {
  String? id;
  String? description;
  String? creatorName;
  bool? isAnswered;
  bool? isInappropriate;
  bool? isGroup;
  bool? isFavorite;
  String? userId;
  String? groupId;
  DateTime? snoozeEndDate;
  String? snoozeFrequency;
  int? snoozeDuration;
  List<UpdateModel>? updates;
  List<TagModel>? tags;
  List<FollowerModel>? followers;
  DateTime? archivedDate;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? status;

  PrayerDataModel(
      {this.id,
      this.description,
      this.creatorName,
      this.isAnswered,
      this.isInappropriate,
      this.isGroup,
      this.isFavorite,
      this.userId,
      this.groupId,
      this.snoozeEndDate,
      this.snoozeFrequency,
      this.snoozeDuration,
      this.updates,
      this.tags,
      this.followers,
      this.archivedDate,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  PrayerDataModel.fromJson(Map<String, dynamic> json, String did) {
    id = did;
    description = json['description'];
    creatorName = json['creatorName'];
    isAnswered = json['isAnswered'];
    isInappropriate = json['isInappropriate'];
    isGroup = json['isGroup'];
    isFavorite = json['isFavorite'];
    userId = json['userId'];
    groupId = json['groupId'];
    archivedDate = json['archivedDate']?.toDate() == null
        ? DateTime.now().add(Duration(days: 10))
        : json['archivedDate']?.toDate();
    snoozeEndDate = json['snoozeEndDate']?.toDate();
    snoozeFrequency = json['snoozeFrequency'];
    snoozeDuration = json['snoozeDuration'];
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
    createdDate = json['createdDate']?.toDate();
    modifiedDate = json['modifiedDate']?.toDate();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    data['creatorName'] = this.creatorName;
    data['isAnswered'] = this.isAnswered;
    data['isInappropriate'] = this.isInappropriate;
    data['isGroup'] = this.isGroup;
    data['isFavorite'] = this.isFavorite;
    data['userId'] = this.userId;
    data['groupId'] = this.groupId;
    data['archivedDate'] = this.archivedDate;
    data['snoozeEndDate'] = this.snoozeEndDate;
    data['snoozeFrequency'] = this.snoozeFrequency;
    data['snoozeDuration'] = this.snoozeDuration;
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
