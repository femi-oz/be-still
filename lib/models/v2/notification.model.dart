class NotificationModel {
  String? id;
  String? receiverId;
  String? senderId;
  String? groupId;
  String? prayerId;
  String? message;
  List<String>? tokens;
  String? type;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? status;

  NotificationModel(
      {this.id,
      this.receiverId,
      this.senderId,
      this.groupId,
      this.prayerId,
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
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    groupId = json['groupId'];
    prayerId = json['prayerId'];
    message = json['message'];
    tokens = json['tokens'].cast<String>();
    type = json['type'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdDate = json['createdDate']?.toDate();
    modifiedDate = json['modifiedDate']?.toDate();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['receiverId'] = this.receiverId;
    data['senderId'] = this.senderId;
    data['groupId'] = this.groupId;
    data['prayerId'] = this.prayerId;
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
