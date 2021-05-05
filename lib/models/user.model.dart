import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String keyReference;
  final int churchId;
  final String dateOfBirth;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const UserModel({
    this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.keyReference,
    @required this.churchId,
    @required this.dateOfBirth,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  UserModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        firstName = snapshot['FirstName'],
        lastName = snapshot['LastName'],
        email = snapshot['Email'],
        keyReference = snapshot['KeyReference'],
        churchId = snapshot['ChurchId'],
        dateOfBirth = '',
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
      'DOB': dateOfBirth,
      'KeyReference': keyReference,
      'ChurchId': churchId,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }

  Map<String, dynamic> toJson2() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'keyReference': keyReference,
    };
  }
}
