import 'dart:async';

import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/filter.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:contacts_service/contacts_service.dart';
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

  Future setPrayers(String userId, String sortBy) async {
    _prayerService.getPrayers(userId).asBroadcastStream().listen(
      (data) {
        _prayers = data.toList();
        filterPrayers(
            isAnswered: _filterOptions.isAnswered,
            isArchived: _filterOptions.isArchived,
            isSnoozed: _filterOptions.isSnoozed,
            status: _filterOptions.status,
            sortBy: sortBy);
        notifyListeners();
      },
    );
  }

  Future searchPrayers(String searchQuery, String sortBy) async {
    if (searchQuery == '') {
      filterPrayers(
          isAnswered: _filterOptions.isAnswered,
          isArchived: _filterOptions.isArchived,
          isSnoozed: _filterOptions.isSnoozed,
          status: _filterOptions.status,
          sortBy: sortBy);
    } else {
      List<CombinePrayerStream> filteredPrayers = _prayers
          .where((CombinePrayerStream data) => data.prayer.description
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
      _filteredPrayers = filteredPrayers;
      _filteredPrayers
          .sort((a, b) => b.prayer.modifiedOn.compareTo(a.prayer.modifiedOn));
    }
    notifyListeners();
  }

  Future setPrayer(String id) async {
    _prayerService.getPrayer(id).asBroadcastStream().listen((prayer) {
      _currentPrayer = prayer;
      notifyListeners();
    });
    return;
  }

  Future filterPrayers({
    String status,
    bool isSnoozed,
    bool isArchived,
    bool isAnswered,
    String sortBy,
  }) async {
    var favoritePrayers = [];
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

    var prayersToUnsnooze = prayers.where((e) =>
        e.userPrayer.snoozeEndDate.isBefore(DateTime.now()) &&
        e.userPrayer.isSnoozed == true);
    // .toList();

    prayersToUnsnooze.forEach((data) => {
          locator<PrayerService>().unSnoozePrayer(
              data.prayer.id, DateTime.now(), data.userPrayer.id),
          print(data.prayer.id)
        });

    if (status == Status.active) {
      favoritePrayers = prayers
          .where((CombinePrayerStream data) => data.userPrayer.isFavorite)
          .toList();

      snoozedPrayers = prayers
          .where(
              (CombinePrayerStream data) => data.userPrayer.isSnoozed == false)
          .toList();

      activePrayers = prayers
          .where((CombinePrayerStream data) =>
              data.prayer.status.toLowerCase() == status.toLowerCase())
          .toList();
    }
    if (isAnswered == true) {
      favoritePrayers = [];

      answeredPrayers = prayers
          .where((CombinePrayerStream data) => data.prayer.isAnswer == true)
          .toList();
    }
    if (isArchived == true) {
      favoritePrayers = [];
      archivedPrayers = prayers
          .where((CombinePrayerStream data) => data.prayer.isArchived == true)
          .toList();
    }
    if (isSnoozed == true) {
      favoritePrayers = [];

      snoozedPrayers = prayers
          .where((CombinePrayerStream data) =>
              data.userPrayer.isSnoozed == true &&
              data.userPrayer.snoozeEndDate.isAfter(DateTime.now()))
          .toList();
    }
    _filteredPrayers = [
      ...activePrayers,
      ...archivedPrayers,
      ...snoozedPrayers,
      ...answeredPrayers
    ];
    await _sortBySettings(sortBy);
    _filteredPrayers = [...favoritePrayers, ..._filteredPrayers];
    List<CombinePrayerStream> _distinct = [];
    var idSet = <String>{};
    for (var e in _filteredPrayers) {
      if (idSet.add(e.prayer.id)) {
        _distinct.add(e);
      }
    }
    _filteredPrayers = _distinct;
    notifyListeners();
  }

  _sortBySettings(sortBy) {
    if (sortBy == SortType.date) {
      _filteredPrayers
          .sort((a, b) => b.prayer.modifiedOn.compareTo(a.prayer.modifiedOn));
    } else if (sortBy == SortType.tag) {
      var hasTags = _filteredPrayers.where((e) => e.tags.length > 0).toList();
      var noTags = _filteredPrayers.where((e) => e.tags.length == 0).toList();
      hasTags.sort(
          (a, b) => a.tags[0].displayName.compareTo(b.tags[0].displayName));
      _filteredPrayers = [...hasTags, ...noTags];
    } else {
      var answered = _filteredPrayers.where((e) => e.prayer.isAnswer).toList();
      var unAnswered =
          _filteredPrayers.where((e) => !e.prayer.isAnswer).toList();
      _filteredPrayers = [...answered, ...unAnswered];
    }
  }

  Future addPrayer(
    PrayerModel prayerData,
    String _userID,
  ) async {
    await _prayerService.addPrayer(prayerData, _userID);
  }

  Future addUserPrayer(String prayerId, String prayerDesc, String userId,
      String creatorId, String creator) async {
    await _prayerService.addUserPrayer(
        prayerId, prayerDesc, userId, creatorId, creator);
  }

  Future addPrayerTag(List<Contact> contactData, UserModel user, String message,
      List<PrayerTagModel> oldTags) async {
    await _prayerService.addPrayerTag(contactData, user, message, oldTags);
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

  Future snoozePrayer(
      String prayerID, DateTime snoozeEndDate, String userPrayerID) async {
    await _prayerService.snoozePrayer(prayerID, snoozeEndDate, userPrayerID);
  }

  Future unSnoozePrayer(
      String prayerID, DateTime snoozeEndDate, String userPrayerID) async {
    await _prayerService.unSnoozePrayer(prayerID, snoozeEndDate, userPrayerID);
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
