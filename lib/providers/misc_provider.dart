import 'package:flutter/material.dart';

class MiscProvider with ChangeNotifier {
  String _pageTitle = 'MY LIST';
  String get pageTitle => _pageTitle;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  bool _initialLoad = false;
  bool get initialLoad => _initialLoad;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

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

  setLoadStatus(bool value) {
    _initialLoad = value;
    notifyListeners();
  }
}
