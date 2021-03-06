import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

class MiscProviderV2 with ChangeNotifier {
  String _pageTitle = 'MY PRAYERS';
  String get pageTitle => _pageTitle;

  bool _initialLoad = false;
  bool get initialLoad => _initialLoad;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _deviceId = '';
  String get deviceId => _deviceId;

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

  setLoadStatus(bool value) {
    _initialLoad = value;
    notifyListeners();
  }

  Future setDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        _deviceId = build.androidId;
        // return build.androidId; //UUID for Android
      } else {
        var data = await deviceInfoPlugin.iosInfo;
        _deviceId = data.identifierForVendor;

        // return data.identifierForVendor; //UUID for iOS
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to get platform version');
    }
  }
}
