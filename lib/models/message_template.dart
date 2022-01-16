class MessageTemplate {
  final String id;
  final String templateSubject;
  final String templateBody;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const MessageTemplate({
    required this.id,
    required this.templateSubject,
    required this.templateBody,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
  });
  MessageTemplate.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        templateSubject = snapshot['TemplateSubject'] ?? '',
        templateBody = snapshot['TemplateBody'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate() ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'TemplateSubject': templateSubject,
      'TemplateBody': templateBody,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
