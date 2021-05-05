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
  ContactModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        email = snapshot['Email'],
        phoneNumber = snapshot['PhoneNumber'],
        displayName = snapshot['DisplayName'];

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'PhoneNumber': phoneNumber,
      'DisplayName': displayName,
    };
  }
}
