import 'dart:async';
import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
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
  String _filterOption = Status.active;

  List<CombinePrayerStream> get prayers => _prayers;
  List<CombinePrayerStream> get filteredPrayers => _filteredPrayers;

  List<CombinePrayerStream> get filteredPrayerTimeList =>
      _filteredPrayerTimeList;
  PrayerType get currentPrayerType => _currentPrayerType;
  CombinePrayerStream get currentPrayer => _currentPrayer;
  String get filterOption => _filterOption;

  Future<void> setPrayers(String userId) async {
    _prayerService.getPrayers(userId).asBroadcastStream().listen(
      (data) {
        _prayers = data.where((e) => e.userPrayer.deleteStatus > -1).toList();
        filterPrayers();
        notifyListeners();
      },
    );
  }

  Future<void> checkPrayerValidity(String userId) async {
    if (prayers.length > 0) {
      await _autoDeleteArchivePrayers(userId, prayers);
      await _unSnoozePrayerPast(prayers);
    }
  }

  Future<void> setPrayerTimePrayers(String userId) async =>
      _prayerService.getPrayers(userId).asBroadcastStream().listen(
        (data) {
          _prayers = data.where((e) => e.userPrayer.deleteStatus > -1).toList();
          _prayers.sort(
              (a, b) => b.prayer.modifiedOn.compareTo(a.prayer.modifiedOn));

          _filteredPrayerTimeList = _prayers
              .where((e) =>
                  e.userPrayer.status.toLowerCase() ==
                  Status.active.toLowerCase())
              .toList();
          var favoritePrayers = _prayers
              .where((CombinePrayerStream e) => e.userPrayer.isFavorite)
              .toList();

          _filteredPrayerTimeList = [
            ...favoritePrayers,
            ..._filteredPrayerTimeList
          ];
          List<CombinePrayerStream> _distinct = [];
          var idSet = <String>{};
          for (var e in _filteredPrayerTimeList) {
            if (idSet.add(e.prayer.id)) {
              _distinct.add(e);
            }
          }
          _filteredPrayerTimeList = _distinct;
          // notifyListeners();
        },
      );

  Future<void> searchPrayers(String searchQuery, String userId) async {
    if (searchQuery == '') {
      filterPrayers();
    } else {
      filterPrayers();

      List<CombinePrayerStream> filteredPrayers = _filteredPrayers
          .where((CombinePrayerStream data) => data.prayer.description
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
      for (int i = 0; i < _filteredPrayers.length; i++) {
        var hasMatch = _filteredPrayers[i].updates.any((u) =>
            u.description.toLowerCase().contains(searchQuery.toLowerCase()));
        if (hasMatch) filteredPrayers.add(_filteredPrayers[i]);
      }
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

  void setPrayerFilterOptions(String option) {
    _filterOption = option;
    notifyListeners();
  }

  Future<void> filterPrayers() async {
    List<CombinePrayerStream> prayers = _prayers.toList();
    List<CombinePrayerStream> activePrayers = [];
    List<CombinePrayerStream> answeredPrayers = [];
    List<CombinePrayerStream> snoozedPrayers = [];
    List<CombinePrayerStream> favoritePrayers = [];
    List<CombinePrayerStream> archivedPrayers = [];
    List<CombinePrayerStream> allPrayers = [];
    if (_filterOption == Status.all) {
      favoritePrayers = prayers
          .where((CombinePrayerStream data) => data.userPrayer.isFavorite)
          .toList();
      allPrayers = prayers;
    }
    if (_filterOption == Status.active) {
      favoritePrayers = prayers
          .where((CombinePrayerStream data) => data.userPrayer.isFavorite)
          .toList();
      activePrayers = prayers
          .where((CombinePrayerStream data) =>
              data.userPrayer.status.toLowerCase() ==
              Status.active.toLowerCase())
          .toList();
    }
    if (_filterOption == Status.answered) {
      answeredPrayers = prayers
          .where((CombinePrayerStream data) => data.prayer.isAnswer == true)
          .toList();
    }
    if (_filterOption == Status.archived) {
      archivedPrayers = prayers
          .where(
              (CombinePrayerStream data) => data.userPrayer.isArchived == true)
          .toList();
    }
    if (_filterOption == Status.snoozed) {
      snoozedPrayers = prayers
          .where((CombinePrayerStream data) =>
              data.userPrayer.isSnoozed == true &&
              data.userPrayer.snoozeEndDate.isAfter(DateTime.now()))
          .toList();
    }
    _filteredPrayers = [
      ...allPrayers,
      ...activePrayers,
      ...archivedPrayers,
      ...snoozedPrayers,
      ...answeredPrayers
    ];
    // await _sortBySettings();
    _filteredPrayers
        .sort((a, b) => b.prayer.modifiedOn.compareTo(a.prayer.modifiedOn));
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

  Future<void> _unSnoozePrayerPast(List<CombinePrayerStream> data) async {
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

  Future<void> addPrayer(
    String prayerDesc,
    String userId,
    String creatorName,
    String prayerDescBackup,
  ) async =>
      await _prayerService.addPrayer(
          prayerDesc, userId, creatorName, prayerDescBackup);

  Future<void> addUserPrayer(String prayerId, String prayerDesc,
          String recieverId, String senderId, String sender) async =>
      await _prayerService.addUserPrayer(
          prayerId, prayerDesc, recieverId, senderId, sender);

  Future<void> addPrayerTag(
          List<Contact> contactData, UserModel user, String message) async =>
      await _prayerService.addPrayerTag(contactData, user, message);

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
      String prayerID, DateTime snoozeEndDate, String userPrayerID) async {
    await _prayerService.snoozePrayer(snoozeEndDate, userPrayerID);
    // var duration = snoozeEndDate.difference(DateTime.now());
    // Future.delayed(duration.);
    // setPrayers(userPrayerID, '');
  }

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

  Future<void> unMarkPrayerAsAnswered(
          String prayerId, String userPrayerId) async =>
      await _prayerService.unMarkPrayerAsAnswered(prayerId, userPrayerId);

  Future<void> deletePrayer(String userPrayeId) async {
    await _prayerService.deletePrayer(userPrayeId);
  }

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
