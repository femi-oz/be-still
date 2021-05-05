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
  MessageTemplate.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        templateSubject = snapshot.data()['TemplateSubject'],
        templateBody = snapshot.data()['TemplateBody'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

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
