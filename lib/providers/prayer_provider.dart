import 'dart:async';

import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user_prayer.model.dart';
import 'package:be_still/services/group_service.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class PrayerProvider with ChangeNotifier {
  PrayerService _prayerService = locator<PrayerService>();
  GroupService _groupService = locator<GroupService>();

  Stream<List<PrayerModel>> getPrayers(
      String userId, PrayerActiveScreen activeList, String groupId) {
    if (activeList == PrayerActiveScreen.group) {
      return _groupService.fetchGroupPrayers(groupId).asyncMap((data) => data
          .map((e) => e.prayer)
          .where((p) => !p.hideFromAllMembers)
          .toList());
    } else {
      return _prayerService.fetchPrayers(userId).asyncMap(
        (data) {
          List<CombinePrayerStream> prayers = activeList ==
                  PrayerActiveScreen.personal
              ? data
                  .where((p) =>
                      p.prayer.isAnswer == false &&
                      p.prayer.status.toLowerCase() == 'active')
                  .toList()
              : activeList == PrayerActiveScreen.archived
                  ? data
                      .where((p) => p.prayer.status.toLowerCase() == 'inactive')
                      .toList()
                  : activeList == PrayerActiveScreen.answered
                      ? data
                          .where((p) =>
                              p.prayer.isAnswer == true &&
                              p.prayer.status.toLowerCase() == 'active')
                          .toList()
                      : [];
          return prayers.map((e) => e.prayer).toList();
        },
      );
    }
  }

  Future addPrayer(PrayerModel prayerData, String _userID) async {
    return await _prayerService.addPrayer(prayerData, _userID);
  }

  Future addPrayerUpdate(PrayerUpdateModel prayerUpdateData) async {
    return await _prayerService.addPrayerUpdate(prayerUpdateData);
  }

  Future addGroupPrayer(PrayerModel prayerData) async {
    return await _prayerService.addGroupPrayer(prayerData);
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

  Future hidePrayer(String prayerId, bool value) async {
    return await _prayerService.hidePrayer(prayerId, value);
  }

  Future hidePrayerFromAllMembers(String prayerId, bool value) async {
    return await _prayerService.hideFromAllMembers(prayerId, value);
  }
  // Future hidePrayerFromAllMembers(String prayerId, String groupId) async {
  //   return await _prayerService.hideFromAllMembers(prayerId, groupId);
  // }

  Future flagAsInappropriate(String prayerId) async {
    return await _prayerService.flagAsInappropriate(prayerId);
  }

  Future addPrayerToMyList(UserPrayerModel userPrayer) async {
    return await _prayerService.addPrayerToMyList(userPrayer);
  }

  Stream<DocumentSnapshot> fetchPrayer(String id) {
    return _prayerService.fetchPrayer(id);
  }

  Stream<List<PrayerUpdateModel>> fetchPrayerUpdate(
    String prayerId,
  ) {
    return _prayerService.fetchPrayerUpdate(prayerId);
  }
}
