import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user_prayer.model.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class PrayerProvider with ChangeNotifier {
  PrayerService _prayerService = locator<PrayerService>();

  Stream<List<CombinePrayerStream>> getPrayers(
      String userId, PrayerActiveScreen activeScreen, String groupId) {
    _prayerService.fetchPrayers(userId).listen((data) {
      final activePrayers = data
          .where((e) =>
              e.prayer.status == 'Active' &&
              e.prayer.isAnswer == false &&
              e.prayer.groupId == '0')
          .toList();
      final archivedPrayers =
          data.where((e) => e.prayer.status == 'Inactive').toList();
      final answeredPrayers =
          data.where((e) => e.prayer.isAnswer == true).toList();
      // final groupPrayers = data
      //     .where((e) =>
      //         e.prayer.status == 'Active' &&
      //         e.prayer.isAnswer == false &&
      //         e.prayer.groupId == groupId )
      //     .toList();
    });
    return _prayerService.fetchPrayers(userId);
  }

  Future addprayer(PrayerModel prayerData, String _userID) async {
    return await _prayerService.addPrayer(prayerData, _userID);
  }

  Future editprayer(String description, String prayerID) async {
    return await _prayerService.editPrayer(description, prayerID);
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

  Future hidePrayer(String prayerId) async {
    return await _prayerService.hidePrayer(prayerId);
  }

  Future hidePrayerFromAllMembers(String prayerId, String groupId) async {
    return await _prayerService.hideFromAllMembers(prayerId, groupId);
  }

  Future flagAsInappropriate(String prayerId) async {
    return await _prayerService.flagAsInappropriate(prayerId);
  }

  Stream<DocumentSnapshot> fetchPrayer(String id) {
    return _prayerService.fetchPrayer(id);
  }
}
