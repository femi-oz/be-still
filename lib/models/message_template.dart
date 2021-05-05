import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageTemplate {
  final String id;
  final String templateSubject;
  final String templateBody;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const MessageTemplate({
    this.id,
    @required this.templateSubject,
    @required this.templateBody,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });
  MessageTemplate.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        templateSubject = snapshot['TemplateSubject'],
        templateBody = snapshot['TemplateBody'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

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
