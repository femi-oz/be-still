class MessageTemplate {
  final String? id;
  final String? templateSubject;
  final String? templateBody;
  final String? createdBy;
  final DateTime? createdOn;
  final String? modifiedBy;
  final DateTime? modifiedOn;

  const MessageTemplate({
    this.id,
    this.templateSubject,
    this.templateBody,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });
  MessageTemplate.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        templateSubject = snapshot['templateSubject'] ?? '',
        templateBody = snapshot['templateBody'] ?? '',
        createdBy = snapshot['createdBy'] ?? '',
        createdOn = snapshot['createdOn']?.toDate() ?? DateTime.now(),
        modifiedBy = snapshot['modifiedBy'] ?? '',
        modifiedOn = snapshot['modifiedOn']?.toDate() ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'templateSubject': templateSubject,
      'templateBody': templateBody,
      'createdBy': createdBy,
      'createdOn': createdOn,
      'modifiedBy': modifiedBy,
      'modifiedOn': modifiedOn,
    };
  }
}
