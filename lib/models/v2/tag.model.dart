class TagModel {
  String? id;
  String? phoneNumber;
  String? email;
  String? displayName;
  String? contactIdentifier;
  String? createdBy;
  String? modifiedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? status;

  TagModel(
      {this.id,
      this.phoneNumber,
      this.email,
      this.displayName,
      this.contactIdentifier,
      this.createdBy,
      this.modifiedBy,
      this.createdDate,
      this.modifiedDate,
      this.status});

  TagModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    displayName = json['displayName'];
    contactIdentifier = json['contactIdentifier'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdDate = json['createdDate']?.toDate();
    modifiedDate = json['modifiedDate']?.toDate();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['phoneNumber'] = this.phoneNumber;
    data['email'] = this.email;
    data['displayName'] = this.displayName;
    data['contactIdentifier'] = this.contactIdentifier;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdDate'] = this.createdDate;
    data['modifiedDate'] = this.modifiedDate;
    data['status'] = this.status;
    return data;
  }
}
