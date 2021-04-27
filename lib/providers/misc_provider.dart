import 'package:flutter/material.dart';

class MiscProvider with ChangeNotifier {
  String _pageTitle = 'MY LIST';
  String get pageTitle => _pageTitle;
  int _currentPage = 0;
  int get currentPage => _currentPage;

  setPageTitle(String title) {
    _pageTitle = title;
    notifyListeners();
  }

  setCurrentPage(int index) {
    _currentPage = index;
    notifyListeners();
  }
}
