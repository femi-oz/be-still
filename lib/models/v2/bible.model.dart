class BibleDataModel {
  String? id;
  String? name;
  String? link;
  String? shortName;
  String? recommendedFor;
  String? createdBy;
  String? modifiedBy;
  String? createdDate;
  String? modifiedDate;
  String? status;

  BibleDataModel(
      {this.id,
      this.name,
      this.link,
      this.shortName,
      this.recommendedFor,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  BibleDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    link = json['link'];
    shortName = json['shortName'];
    recommendedFor = json['recommendedFor'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdDate = json['createdDate']?.toDate();
    modifiedDate = json['modifiedDate']?.toDate();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['link'] = this.link;
    data['shortName'] = this.shortName;
    data['recommendedFor'] = this.recommendedFor;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
