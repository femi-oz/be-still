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

  setCountryName() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position.latitude}');
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    _countryCode = first.countryCode;
    notifyListeners();
  }
}
