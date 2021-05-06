import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactModel {
  final String id;
  final String email;
  final String phoneNumber;
  final String displayName;

  const ContactModel({
    this.id,
    @required this.email,
    @required this.phoneNumber,
    @required this.displayName,
  });
  ContactModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        email = snapshot.data()['Email'],
        phoneNumber = snapshot.data()['PhoneNumber'],
        displayName = snapshot.data()['DisplayName'];

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'PhoneNumber': phoneNumber,
      'DisplayName': displayName,
    };
  }
}
