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
  BibleModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        name = snapshot.data()['name'],
        recommendedFor = snapshot.data()['recommendedFor'],
        link = snapshot.data()['link'],
        shortName = snapshot.data()['shortName'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'recommendedFor': recommendedFor,
      'link': link,
      'shortName': shortName,
    };
  }
}
