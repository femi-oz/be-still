import 'dart:io';

import 'package:be_still/locator.dart';
import 'package:be_still/services/v2/migration.service.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

class MiscProviderV2 with ChangeNotifier {
  MigrationService _migrationService = locator<MigrationService>();

  String _pageTitle = 'MY PRAYERS';
  String get pageTitle => _pageTitle;

  bool _initialLoad = false;
  bool get initialLoad => _initialLoad;

  bool _ranMigration = false;
  bool get ranMigration => _ranMigration;

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

  setMigrateStatus(bool value) {
    _ranMigration = value;
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
