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
  String pushToken;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  UserModel({
    this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.keyReference,
    @required this.churchId,
    @required this.dateOfBirth,
    @required this.pushToken,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  UserModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        firstName = snapshot.data()['FirstName'],
        pushToken = snapshot.data()['PushToken'],
        lastName = snapshot.data()['LastName'],
        email = snapshot.data()['Email'],
        keyReference = snapshot.data()['KeyReference'],
        churchId = snapshot.data()['ChurchId'],
        dateOfBirth = '',
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
      'PushToken': pushToken,
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
