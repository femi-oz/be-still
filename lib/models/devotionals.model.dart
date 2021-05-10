import 'package:cloud_firestore/cloud_firestore.dart';

class DevotionalModel {
  String id;
  String title;
  String link;
  String period;
  String type;
  String description;

  DevotionalModel({
    this.id,
    this.title,
    this.link,
    this.type,
    this.description,
    this.period,
  });
  DevotionalModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        title = snapshot.data()['title'],
        type = snapshot.data()['type'],
        description = snapshot.data()['description'],
        period = snapshot.data()['period'],
        link = snapshot.data()['link'];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'description': description,
      'period': period,
      'link': link,
    };
  }
}
