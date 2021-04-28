import 'package:be_still/utils/settings.dart';
import 'package:flutter/material.dart';

class MiscProvider with ChangeNotifier {
  String _pageTitle = 'MY LIST';
  String get pageTitle => _pageTitle;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _disable = Settings.rememberMe ? false : true;
  bool get disable => _disable;

  bool _search = false;
  bool get search => _search;

  setPageTitle(String title) {
    _pageTitle = title;
    notifyListeners();
  }

  setVisibility(bool disable) {
    _disable = disable;
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
}
