import 'dart:async';

import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/filter.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';

class PrayerProvider with ChangeNotifier {
  PrayerService _prayerService = locator<PrayerService>();

  List<CombinePrayerStream> _prayers = [];
  PrayerType _currentPrayerType = PrayerType.userPrayers;
  List<CombinePrayerStream> _filteredPrayers = [];
  List<CombinePrayerStream> _filteredPrayerTimeList = [];
  CombinePrayerStream _currentPrayer;
  FilterType _filterOptions = FilterType(
    isAnswered: false,
    isArchived: false,
    isSnoozed: false,
    status: Status.active,
  );

  List<CombinePrayerStream> get prayers => _prayers;
  List<CombinePrayerStream> get filteredPrayers => _filteredPrayers;

  List<CombinePrayerStream> get filteredPrayerTimeList =>
      _filteredPrayerTimeList;
  PrayerType get currentPrayerType => _currentPrayerType;
  CombinePrayerStream get currentPrayer => _currentPrayer;
  FilterType get filterOptions => _filterOptions;

  Future<void> setPrayers(String userId, String sortBy) async {
    _prayerService.getPrayers(userId).asBroadcastStream().listen(
      (data) {
        _prayers = data.toList();
        filterPrayers(
          userId: userId,
          isAnswered: _filterOptions.isAnswered,
          isArchived: _filterOptions.isArchived,
          isSnoozed: _filterOptions.isSnoozed,
          status: _filterOptions.status,
          sortBy: sortBy,
        );
        notifyListeners();
      },
    );
    checkPrayerValidity(userId, prayers);
  }

  Future<void> checkPrayerValidity(
      String userId, List<CombinePrayerStream> prayers) async {
    await _autoDeleteArchivePrayers(userId, prayers);
    await _unSnoozePrayerPast(prayers);
  }

  Future<void> setPrayerTimePrayers(String userId, String sortBy) async =>
      _prayerService.getPrayers(userId).asBroadcastStream().listen(
        (data) {
          _filteredPrayerTimeList = data
              .where((e) =>
                  e.userPrayer.status.toLowerCase() ==
                  Status.active.toLowerCase())
              .toList();
          List<CombinePrayerStream> _distinct = [];
          var idSet = <String>{};
          for (var e in _filteredPrayerTimeList) {
            if (idSet.add(e.prayer.id)) {
              _distinct.add(e);
            }
          }
          _filteredPrayerTimeList = _distinct;
          notifyListeners();
        },
      );

  Future<void> searchPrayers(
      String searchQuery, String sortBy, String userId) async {
    if (searchQuery == '') {
      filterPrayers(
        userId: userId,
        isAnswered: _filterOptions.isAnswered,
        isArchived: _filterOptions.isArchived,
        isSnoozed: _filterOptions.isSnoozed,
        status: _filterOptions.status,
        sortBy: sortBy,
      );
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

  Future<void> setPrayer(String id) async =>
      _prayerService.getPrayer(id).asBroadcastStream().listen((prayer) {
        _currentPrayer = prayer;
        notifyListeners();
      });

  Future<void> filterPrayers({
    String status,
    bool isSnoozed,
    bool isArchived,
    bool isAnswered,
    String sortBy,
    String userId,
  }) async {
    _filterOptions = FilterType(
      isAnswered: isAnswered,
      isArchived: isArchived,
      isSnoozed: isSnoozed,
      status: status,
    );
    List<CombinePrayerStream> prayers = _prayers.toList();
    List<CombinePrayerStream> activePrayers = [];
    List<CombinePrayerStream> answeredPrayers = [];
    List<CombinePrayerStream> snoozedPrayers = [];
    List<CombinePrayerStream> favoritePrayers = [];
    List<CombinePrayerStream> archivedPrayers = [];
    if (status == Status.active) {
      favoritePrayers = prayers
          .where((CombinePrayerStream data) => data.userPrayer.isFavorite)
          .toList();
      activePrayers = prayers
          .where((CombinePrayerStream data) =>
              data.userPrayer.status.toLowerCase() == status.toLowerCase())
          .toList();

      print(archivedPrayers.length);
    }
    if (isAnswered == true) {
      answeredPrayers = prayers
          .where((CombinePrayerStream data) => data.prayer.isAnswer == true)
          .toList();
    }
    if (isArchived == true) {
      archivedPrayers = prayers
          .where(
              (CombinePrayerStream data) => data.userPrayer.isArchived == true)
          .toList();
    }
    if (isSnoozed == true) {
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

  Future<void> _unSnoozePrayerPast(data) async {
    var prayersToUnsnooze = data
        .where((e) =>
            e.userPrayer.snoozeEndDate.isBefore(DateTime.now()) &&
            e.userPrayer.isSnoozed == true)
        .toList();

    for (int i = 0; i < prayersToUnsnooze.length; i++) {
      await locator<PrayerService>()
          .unSnoozePrayer(DateTime.now(), prayersToUnsnooze[i].userPrayer.id);
    }
  }

  Future<void> _sortBySettings(sortBy) async {
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

  Future<void> addPrayer(
    String prayerDesc,
    String userId,
    String creatorName,
  ) async =>
      await _prayerService.addPrayer(prayerDesc, userId, creatorName);

  Future<void> addUserPrayer(String prayerId, String prayerDesc,
          String recieverId, String senderId, String sender) async =>
      await _prayerService.addUserPrayer(
          prayerId, prayerDesc, recieverId, senderId, sender);

  Future<void> addPrayerTag(List<Contact> contactData, UserModel user,
          String message, List<PrayerTagModel> oldTags) async =>
      await _prayerService.addPrayerTag(contactData, user, message, oldTags);

  Future<void> removePrayerTag(String tagId) async =>
      await _prayerService.removePrayerTag(tagId);

  Future<void> addPrayerUpdate(
          String userId, String prayer, String prayerId) async =>
      await _prayerService.addPrayerUpdate(userId, prayer, prayerId);

  Future<void> editprayer(String description, String prayerID) async =>
      await _prayerService.editPrayer(description, prayerID);

  Future<void> archivePrayer(String userPrayerId) async =>
      await _prayerService.archivePrayer(userPrayerId);

  Future<void> unArchivePrayer(String userPrayerId) async =>
      await _prayerService.unArchivePrayer(userPrayerId);

  Future<void> snoozePrayer(
          String prayerID, DateTime snoozeEndDate, String userPrayerID) async =>
      await _prayerService.snoozePrayer(snoozeEndDate, userPrayerID);

  Future<void> unSnoozePrayer(
          String prayerID, DateTime snoozeEndDate, String userPrayerID) async =>
      await _prayerService.unSnoozePrayer(snoozeEndDate, userPrayerID);

  Future<void> _autoDeleteArchivePrayers(
      String userId, List<CombinePrayerStream> data) async {
    final archivedPrayers = data
        .where((CombinePrayerStream data) => data.userPrayer.isArchived == true)
        .toList();
    final settings = await locator<SettingsService>().getSettings(userId);
    final autoDeleteAnswered = settings.includeAnsweredPrayerAutoDelete;
    final autoDeleteDuration = settings.defaultSnoozeDurationMins;
    List<CombinePrayerStream> toDelete = archivedPrayers;
    if (!autoDeleteAnswered) {
      toDelete = archivedPrayers
          .where((CombinePrayerStream e) => e.prayer.isAnswer == false)
          .toList();
    }
    for (int i = 0; i < toDelete.length; i++) {
      if (toDelete[i]
              .userPrayer
              .archivedDate
              .add(Duration(minutes: autoDeleteDuration))
              .isBefore(DateTime.now()) &&
          autoDeleteDuration != 0) {
        deletePrayer(toDelete[i].userPrayer.id);
      }
    }
  }

  Future<void> favoritePrayer(String prayerID) async =>
      await _prayerService.favoritePrayer(prayerID);

  Future<void> unfavoritePrayer(String prayerID) async =>
      await _prayerService.unFavoritePrayer(prayerID);

  Future<void> markPrayerAsAnswered(
          String prayerId, String userPrayerId) async =>
      await _prayerService.markPrayerAsAnswered(prayerId, userPrayerId);

  Future<void> deletePrayer(String userPrayeId) async =>
      await _prayerService.deletePrayer(userPrayeId);

  Future<void> setCurrentPrayerType(PrayerType type) async {
    _currentPrayerType = type;
    notifyListeners();
  }

//Group Prayers
  Future<void> setGroupPrayers(
          String userId, String groupId, bool isGroupAdmin) async =>
      _prayerService
          .getGroupPrayers(groupId)
          .asBroadcastStream()
          .listen((data) {
        // if (!isGroupAdmin) {
        //   _prayers = _prayers.where((e) => !e.prayer.hideFromMe).toList();
        // }
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

  Future<void> messageRequestor(
          PrayerRequestMessageModel prayerRequestData) async =>
      await _prayerService.messageRequestor(prayerRequestData);

  Future<void> addPrayerWithGroups(BuildContext context, PrayerModel prayerData,
          List groups, String _userID) async =>
      await _prayerService.addPrayerWithGroup(
          context, prayerData, groups, _userID);

  Future<void> addGroupPrayer(
          BuildContext context, PrayerModel prayerData) async =>
      await _prayerService.addGroupPrayer(context, prayerData);

  Future<void> hidePrayer(String prayerId, UserModel user) async =>
      await _prayerService.hidePrayer(prayerId, user);

  Future<void> hidePrayerFromAllMembers(String prayerId, bool value) async =>
      await _prayerService.hideFromAllMembers(prayerId, value);

  Future<void> addPrayerToMyList(UserPrayerModel userPrayer) async =>
      await _prayerService.addPrayerToMyList(userPrayer);
}
