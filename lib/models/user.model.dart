import 'package:flutter/services.dart';

class UserModel {
  String id;
  String firstName;
  String lastName;
  String email;
  String keyReference;
  int churchId;
  String dateOfBirth;
  String createdBy;
  String pushToken;
  DateTime createdOn;
  String modifiedBy;
  DateTime modifiedOn;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.keyReference,
    required this.churchId,
    required this.dateOfBirth,
    required this.pushToken,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
  });

  factory UserModel.defaultValue() => UserModel(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
      keyReference: '',
      churchId: 0,
      dateOfBirth: '',
      pushToken: '',
      createdBy: '',
      createdOn: DateTime.now(),
      modifiedBy: '',
      modifiedOn: DateTime.now());

  factory UserModel.fromData(Map<String, dynamic> data, String did) {
    final id = did;
    final firstName = data['FirstName'] ?? '';
    final pushToken = data['PushToken'] ?? '';
    final lastName = data['LastName'] ?? '';
    final email = data['Email'] ?? '';
    final keyReference = data['KeyReference'] ?? '';
    final churchId = data['ChurchId'] ?? '';
    final dateOfBirth = '';
    final createdBy = data['CreatedBy'] ?? '';
    final createdOn = data['CreatedOn'].toDate() ?? DateTime.now();
    final modifiedBy = data['ModifiedBy'] ?? '';
    final modifiedOn = data['ModifiedOn'].toDate() ?? DateTime.now();

    return UserModel(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        keyReference: keyReference,
        churchId: churchId,
        dateOfBirth: dateOfBirth,
        pushToken: pushToken,
        createdBy: createdBy,
        createdOn: createdOn,
        modifiedBy: modifiedBy,
        modifiedOn: modifiedOn);
  }

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

class UserVerify {
  final PlatformException? error;
  final bool needsVerification;
  UserVerify({required this.error, required this.needsVerification});
}
