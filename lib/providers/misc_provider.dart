import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

class MiscProvider with ChangeNotifier {
  String _pageTitle = 'MY LIST';
  String get pageTitle => _pageTitle;
  String _countryCode = 'US';
  String get countryCode => _countryCode;

  setPageTitle(String title) {
    _pageTitle = title;
    notifyListeners();
  }

  setCountryName(addresses) async {
    var first = addresses.first;
    _countryCode = first.countryCode;
    notifyListeners();
  }
}
