class BibleModel {
  final String id;
  final String name;
  final String link;
  final String shortName;
  final String recommendedFor;

  const BibleModel({
    required this.id,
    required this.name,
    required this.link,
    required this.shortName,
    required this.recommendedFor,
  });
  factory BibleModel.fromData(Map<String, dynamic> data, String did) {
    final id = did;
    final name = data['name'] ?? '';
    final recommendedFor = data['recommendedFor'] ?? '';
    final link = data['link'] ?? '';
    final shortName = data['shortName'] ?? '';
    return BibleModel(
        id: id,
        link: link,
        name: name,
        recommendedFor: recommendedFor,
        shortName: shortName);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'recommendedFor': recommendedFor,
      'link': link,
      'shortName': shortName,
    };
  }
}
