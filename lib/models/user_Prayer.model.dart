// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class UserPrayerModel {
//   final String id;
//   final String prayerId;
//   final String userId;
//   final String sequence;
//   final bool isFavorite;
//   final String status;
//   final String createdBy;
//   final DateTime createdOn;
//   final String modifiedBy;
//   final DateTime modifiedOn;

//   const UserPrayerModel({
//     this.id,
//     @required this.prayerId,
//     @required this.userId,
//     @required this.sequence,
//     @required this.isFavorite,
//     @required this.status,
//     @required this.createdBy,
//     @required this.createdOn,
//     @required this.modifiedBy,
//     @required this.modifiedOn,
//   });

//   UserPrayerModel.fromData(DocumentSnapshot snapshot)
//       : id = snapshot.documentID,
//         prayerId = snapshot.data['PrayerId'],
//         userId = snapshot.data['UserId'],
//         sequence = snapshot.data['Sequence'],
//         isFavorite = snapshot.data['IsFavourite'],
//         status = snapshot.data['Status'],
//         createdBy = snapshot.data['CreatedBy'],
//         createdOn = snapshot.data['CreatedOn'].toDate(),
//         modifiedBy = snapshot.data['ModifiedBy'],
//         modifiedOn = snapshot.data['ModifiedOn'].toDate();

//   Map<String, dynamic> toJson() {
//     return {
//       'PrayerId': prayerId,
//       'UserId': userId,
//       'Sequence': sequence,
//       'IsFavourite': isFavorite,
//       'Status': status,
//       'CreatedBy': createdBy,
//       'CreatedOn': createdOn,
//       'ModifiedBy': modifiedBy,
//       'ModifiedOn': modifiedOn,
//     };
//   }
// }
