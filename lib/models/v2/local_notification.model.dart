class LocalNotificationDataModel {
  String? id;
  String? userId;
  String? prayerId;
  String? message;
  String? title;
  int? localNotificationId;
  String? type;
  String? frequency;
  DateTime? scheduleDate;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? status;

  LocalNotificationDataModel(
      {this.id,
      this.userId,
      this.prayerId,
      this.message,
      this.title,
      this.localNotificationId,
      this.type,
      this.frequency,
      this.scheduleDate,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  LocalNotificationDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    prayerId = json['prayerId'];
    message = json['message'];
    title = json['title'];
    localNotificationId = json['localNotificationId'];
    type = json['type'];
    frequency = json['frequency'];
    scheduleDate = json['scheduleDate'].toDate();
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
    data['prayerId'] = this.prayerId;
    data['message'] = this.message;
    data['title'] = this.title;
    data['localNotificationId'] = this.localNotificationId;
    data['type'] = this.type;
    data['frequency'] = this.frequency;
    data['scheduleDate'] = this.scheduleDate;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
