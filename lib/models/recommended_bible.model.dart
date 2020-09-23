import 'package:flutter/material.dart';

class RecommendedBibleModel {
  final String id;
  final String title;
  final String abbreviation;
  final String subTitle;
  final String description;
  final String link;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const RecommendedBibleModel(
      {@required this.id,
      @required this.title,
      @required this.abbreviation,
      @required this.subTitle,
      @required this.description,
      @required this.link,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});
}
