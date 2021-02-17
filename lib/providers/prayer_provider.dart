import 'dart:async';

import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/filter.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:flutter/cupertino.dart';

class PrayerProvider with ChangeNotifier {
  PrayerService _prayerService = locator<PrayerService>();

  List<CombinePrayerStream> _prayers = [];
  PrayerType _currentPrayerType = PrayerType.userPrayers;
  List<CombinePrayerStream> _filteredPrayers = [];
  CombinePrayerStream _currentPrayer;
  FilterType _filterOptions = FilterType(
    isAnswered: false,
    isArchived: false,
    isSnoozed: false,
    status: Status.active,
  );

  List<CombinePrayerStream> get prayers => _prayers;
  List<CombinePrayerStream> get filteredPrayers => _filteredPrayers;
  PrayerType get currentPrayerType => _currentPrayerType;
  CombinePrayerStream get currentPrayer => _currentPrayer;
  FilterType get filterOptions => _filterOptions;

  Future setPrayers(
    String userId,
  ) async {
    _prayerService.getPrayers(userId).asBroadcastStream().listen(
      (data) {
        _prayers = data.toList();
        filterPrayers(
            isAnswered: _filterOptions.isAnswered,
            isArchived: _filterOptions.isArchived,
            isSnoozed: _filterOptions.isSnoozed,
            status: _filterOptions.status);
        notifyListeners();
      },
    );
  }

  Future searchPrayers(String searchQuery) async {
    List<CombinePrayerStream> filteredPrayers = _prayers
        .where((CombinePrayerStream data) => data.prayer.description
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
    _filteredPrayers = filteredPrayers;
    _filteredPrayers
        .sort((a, b) => b.prayer.modifiedOn.compareTo(a.prayer.modifiedOn));
    notifyListeners();
  }

  Future filterPrayers({
    String status,
    bool isSnoozed,
    bool isArchived,
    bool isAnswered,
  }) async {
    _filterOptions = FilterType(
      isAnswered: isAnswered,
      isArchived: isArchived,
      isSnoozed: isSnoozed,
      status: status,
    );
    List<CombinePrayerStream> prayers = _prayers.toList();

    var activePrayers = [];
    var answeredPrayers = [];
    var snoozedPrayers = [];
    var archivedPrayers = [];

    if (status == Status.active) {
      activePrayers = prayers
          .where((CombinePrayerStream data) =>
              data.prayer.status.toLowerCase() == status.toLowerCase())
          .toList();
    }
    if (isAnswered == true) {
      answeredPrayers = prayers
          .where((CombinePrayerStream data) => data.prayer.isAnswer == true)
          .toList();
    }
    if (isArchived == true) {
      archivedPrayers = prayers
          .where((CombinePrayerStream data) => data.prayer.isArchived == true)
          .toList();
    }
    if (isSnoozed == true) {
      snoozedPrayers = prayers
          .where((CombinePrayerStream data) => data.prayer.isSnoozed == true)
          .toList();
    }
    _filteredPrayers = [
      ...activePrayers,
      ...archivedPrayers,
      ...snoozedPrayers,
      ...answeredPrayers
    ];
    List<CombinePrayerStream> _distinct = [];
    var idSet = <String>{};
    for (var e in _filteredPrayers) {
      if (idSet.add(e.prayer.id)) {
        _distinct.add(e);
      }
    }
    _filteredPrayers = _distinct;
    _filteredPrayers
        .sort((a, b) => b.prayer.modifiedOn.compareTo(a.prayer.modifiedOn));
    notifyListeners();
  }

  Future addPrayer(
    PrayerModel prayerData,
    String _userID,
  ) async {
    await _prayerService.addPrayer(prayerData, _userID);
  }

  Future addUserPrayer(
      String prayerId, String userId, String creatorId, String creator) async {
    await _prayerService.addUserPrayer(prayerId, userId, creatorId, creator);
  }

  Future addPrayerTag(PrayerTagModel prayerData, String countryCode,
      List<PrayerTagModel> oldTags) async {
    await _prayerService.addPrayerTag(prayerData, countryCode, oldTags);
  }

  Future removePrayerTag(String tagId) async {
    await _prayerService.removePrayerTag(tagId);
  }

  Future addPrayerUpdate(PrayerUpdateModel prayerUpdateData) async {
    await _prayerService.addPrayerUpdate(prayerUpdateData);
  }

  Future editprayer(String description, String prayerID) async {
    await _prayerService.editPrayer(description, prayerID);
  }

  Future archivePrayer(String prayerID) async {
    await _prayerService.archivePrayer(prayerID);
  }

  Future unArchivePrayer(String prayerID) async {
    await _prayerService.unArchivePrayer(prayerID);
  }

  Future favoritePrayer(String prayerID) async {
    return await _prayerService.favoritePrayer(prayerID);
  }

  Future unfavoritePrayer(String prayerID) async {
    return await _prayerService.unFavoritePrayer(prayerID);
  }

  Future markPrayerAsAnswered(String prayerID) async {
    await _prayerService.markPrayerAsAnswered(prayerID);
  }

  Future deletePrayer(String prayerID) async {
    await _prayerService.deletePrayer(prayerID);
  }

  Future setCurrentPrayerType(PrayerType type) async {
    _currentPrayerType = type;
    notifyListeners();
  }

  Future setPrayer(String id) async {
    _prayerService.getPrayer(id).asBroadcastStream().listen((prayer) {
      _currentPrayer = prayer;
      notifyListeners();
    });
    return;
  }

//Group Prayers
  Future setGroupPrayers(
      String userId, String groupId, bool isGroupAdmin) async {
    _prayerService.getGroupPrayers(groupId).asBroadcastStream().listen((data) {
      if (!isGroupAdmin) {
        _prayers = _prayers.where((e) => !e.prayer.hideFromMe).toList();
      }
      _filteredPrayers = _prayers;
      _filteredPrayers
          .sort((a, b) => b.prayer.modifiedOn.compareTo(a.prayer.modifiedOn));
      _filterOptions = FilterType(
        isAnswered: false,
        isArchived: false,
        isSnoozed: false,
        status: Status.active,
      );
      notifyListeners();
    });
  }

  Future messageRequestor(PrayerRequestMessageModel prayerRequestData) async {
    return await _prayerService.messageRequestor(prayerRequestData);
  }

  Future addPrayerWithGroups(BuildContext context, PrayerModel prayerData,
      List groups, String _userID) async {
    return await _prayerService.addPrayerWithGroup(
        context, prayerData, groups, _userID);
  }

  Future addGroupPrayer(BuildContext context, PrayerModel prayerData) async {
    return await _prayerService.addGroupPrayer(context, prayerData);
  }

  Future hidePrayer(String prayerId, UserModel user) async {
    return await _prayerService.hidePrayer(prayerId, user);
  }

  Future hidePrayerFromAllMembers(String prayerId, bool value) async {
    return await _prayerService.hideFromAllMembers(prayerId, value);
  }

  Future addPrayerToMyList(UserPrayerModel userPrayer) async {
    return await _prayerService.addPrayerToMyList(userPrayer);
  }
}
