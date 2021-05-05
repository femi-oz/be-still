import 'package:cloud_firestore/cloud_firestore.dart';

class BibleModel {
  String id;
  String name;
  String link;
  String shortName;
  String recommendedFor;

  BibleModel({
    this.id,
    this.name,
    this.link,
    this.shortName,
    this.recommendedFor,
  });
  BibleModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        name = snapshot['name'],
        recommendedFor = snapshot['recommendedFor'],
        link = snapshot['link'],
        shortName = snapshot['shortName'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'recommendedFor': recommendedFor,
      'link': link,
      'shortName': shortName,
    };
  }
}
