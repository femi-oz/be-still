class FollowerModel {
  String? id;
  String? userId;
  String? prayerStatus;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? status;

  FollowerModel(
      {this.id,
      this.userId,
      this.prayerStatus,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  FollowerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    prayerStatus = json['prayerStatus'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdDate = json['createdDate'].toDate();
    modifiedDate = json['modifiedDate'].toDate();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['prayerStatus'] = this.prayerStatus;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
