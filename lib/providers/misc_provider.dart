import 'package:flutter/material.dart';

class MiscProvider with ChangeNotifier {
  String _pageTitle = 'MY LIST';
  String get pageTitle => _pageTitle;
  int _currentPage = 0;
  int get currentPage => _currentPage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  GlobalKey _keyButton = GlobalKey();
  GlobalKey _keyButton2 = GlobalKey();
  GlobalKey _keyButton3 = GlobalKey();
  GlobalKey _keyButton4 = GlobalKey();
  GlobalKey _keyButton5 = GlobalKey();

  GlobalKey get keyButton => _keyButton;
  GlobalKey get keyButton2 => _keyButton2;
  GlobalKey get keyButton3 => _keyButton3;
  GlobalKey get keyButton4 => _keyButton4;
  GlobalKey get keyButton5 => _keyButton5;

  bool _search = false;
  bool get search => _search;

  setPageTitle(String title) {
    _pageTitle = title;
    notifyListeners();
  }

  setSearchMode(bool searchMode) {
    _search = searchMode;
    notifyListeners();
  }

  setSearchQuery(String searchText) {
    _searchQuery = searchText;
    notifyListeners();
  }

  setCurrentPage(int index) {
    _currentPage = index;
    notifyListeners();
  }
}
