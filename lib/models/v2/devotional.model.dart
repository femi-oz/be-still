class DevotionalDataModel {
  String? id;
  String? title;
  String? link;
  String? period;
  String? type;
  String? description;
  String? createdBy;
  String? modifiedBy;
  String? createdDate;
  String? modifiedDate;
  String? status;

  DevotionalDataModel(
      {this.id,
      this.title,
      this.link,
      this.period,
      this.type,
      this.description,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  DevotionalDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    link = json['link'];
    period = json['period'];
    type = json['type'];
    description = json['description'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdDate = json['createdDate']?.toDate();
    modifiedDate = json['modifiedDate']?.toDate();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['link'] = this.link;
    data['period'] = this.period;
    data['type'] = this.type;
    data['description'] = this.description;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
