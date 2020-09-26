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
    notifyListeners();
  }

  Future getArchivedPrayers(UserModel user) async {
    final res = await _prayerService.fetchArchivedPrayers(user);
    if (res is String)
      print(res);
    else
      return res;
    notifyListeners();
  }

  Future getAnsweredPrayers(UserModel user) async {
    final res = await _prayerService.fetchAnsweredPrayers(user);
    if (res is String)
      print(res);
    else
      return res;
    notifyListeners();
  }

  Future addprayer(PrayerModel prayerData, String _userID) async {
    return await _prayerService.addPrayer(prayerData, _userID);
  }

  Future editprayer(PrayerModel prayerData, String prayerID) async {
    return await _prayerService.editPrayer(prayerData, prayerID);
  }

  Future archivePrayer(String prayerID) async {
    return await _prayerService.archivePrayer(prayerID);
  }

  Future markPrayerAsAnswered(String prayerID) async {
    return await _prayerService.markPrayerAsAnswered(prayerID);
  }

  Future deletePrayer(String prayerID) async {
    return await _prayerService.deletePrayer(prayerID);
  }

  Stream<DocumentSnapshot> fetchPrayer(String id) {
    return _prayerService.fetchPrayer(id);
  }
}
