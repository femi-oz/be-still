import 'package:cloud_firestore/cloud_firestore.dart';

class DevotionalModel {
  final String id;
  final String title;
  final String link;
  final String period;
  final String type;
  final String description;

  DevotionalModel({
    required this.id,
    required this.title,
    required this.link,
    required this.type,
    required this.description,
    required this.period,
  });

  factory DevotionalModel.fromData(Map<String, dynamic> data, String did) {
    final id = did;
    final title = data['title'] ?? '';
    final type = data['type'] ?? '';
    final description = data['description'] ?? '';
    final period = data['period'] ?? '';
    final link = data['link'] ?? '';
    return DevotionalModel(
        id: id,
        title: title,
        link: link,
        type: type,
        description: description,
        period: period);
  }

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
