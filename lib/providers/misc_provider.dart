import 'package:flutter/material.dart';

class MiscProvider with ChangeNotifier {
  String _pageTitle = 'MY LIST';
  String get pageTitle => _pageTitle;

  setPageTitle(String title) {
    _pageTitle = title;
    notifyListeners();
  }
}
