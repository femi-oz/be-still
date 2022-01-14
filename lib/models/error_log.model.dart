import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ErrorLog {
  final String id;
  final String message;
  final String location;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const ErrorLog({
    required this.id,
    required this.message,
    required this.location,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
  });

  factory ErrorLog.fromData(Map<String, dynamic> data, did) {
    final id = did;
    final message = data['Message'] ?? '';
    final location = data['Location'] ?? '';
    final createdBy = data['CreatedBy'] ?? '';
    final createdOn = data['CreatedOn'].toDate() ?? DateTime.now();
    final modifiedBy = data['ModifiedBy'] ?? '';
    final modifiedOn = data['ModifiedOn'].toDate() ?? DateTime.now();
    return ErrorLog(
        id: id,
        message: message,
        location: location,
        createdBy: createdBy,
        createdOn: createdOn,
        modifiedBy: modifiedBy,
        modifiedOn: modifiedOn);
  }

  Map<String, dynamic> toJson() {
    return {
      'Message': message,
      'Location': location,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
