import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String keyReference;
  final int churchId;
  final DateTime dateOfBirth;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const UserModel({
    this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.phone,
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
      : id = snapshot.documentID,
        firstName = snapshot.data['FirstName'],
        lastName = snapshot.data['LastName'],
        phone = snapshot.data['Phone'],
        email = snapshot.data['Email'],
        keyReference = snapshot.data['KeyReference'],
        churchId = snapshot.data['ChurchId'],
        dateOfBirth = snapshot.data['DOB'].toDate(),
        createdBy = snapshot.data['CreatedBy'],
        createdOn = snapshot.data['CreatedOn'].toDate(),
        modifiedBy = snapshot.data['ModifiedBy'],
        modifiedOn = snapshot.data['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Phone': phone,
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
}
