class LocalNotificationDataModel {
  String? id;
  String? userId;
  String? message;
  int? localNotificationId;
  String? type;
  DateTime? scheduleDate;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? status;

  LocalNotificationDataModel(
      {this.id,
      this.userId,
      this.message,
      this.localNotificationId,
      this.type,
      this.scheduleDate,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  LocalNotificationDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    message = json['message'];
    localNotificationId = json['localNotificationId'];
    type = json['type'];
    scheduleDate = json['scheduleDate'];
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
    data['message'] = this.message;
    data['localNotificationId'] = this.localNotificationId;
    data['type'] = this.type;
    data['scheduleDate'] = this.scheduleDate;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
