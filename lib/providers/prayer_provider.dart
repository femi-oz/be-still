import 'package:be_still/locator.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class PrayerProvider with ChangeNotifier {
  PrayerService _prayerService = locator<PrayerService>();
  // Future<List<PrayerModel>> getPrayers() async {
  //   return null;
  // }

  Future getPrayers(UserModel user) async {
    final res = await _prayerService.fetchPrayers(user);
    if (res is String)
      print(res);
    else
      return res;
  }

  Future addprayer(PrayerModel prayerData, String _userID) async {
    return await _prayerService.addPrayer(prayerData, _userID);
  }

  Future editprayer(PrayerModel prayerData, String prayerID) async {
    return await _prayerService.editPrayer(prayerData, prayerID);
  }

  Future deletePrayer(String prayerID) async {
    print(prayerID);
    return await _prayerService.deletePrayer(prayerID);
  }

  Stream<DocumentSnapshot> fetchPrayer(String id) {
    return _prayerService.fetchPrayer(id);
  }
}
