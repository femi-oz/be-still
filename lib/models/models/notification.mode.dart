class NotificationModel {
  String? id;
  String? userId;
  String? message;
  List<String>? tokens;
  String? type;
  String? createdBy;
  String? modifiedBy;
  String? createdDate;
  String? modifiedDate;
  String? status;

  NotificationModel(
      {this.id,
      this.userId,
      this.message,
      this.tokens,
      this.type,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    message = json['message'];
    tokens = json['tokens'].cast<String>();
    type = json['type'];
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
    data['tokens'] = this.tokens;
    data['type'] = this.type;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
