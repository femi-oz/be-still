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
  List<HiddenPrayerModel> _hiddenPrayers = [];
  PrayerType _currentPrayerType = PrayerType.userPrayers;
  List<PrayerUpdateModel> _prayerUpdates = [];
  List<CombinePrayerStream> _filteredPrayers = [];
  PrayerModel _currentPrayer;
  FilterType _filterOptions = FilterType(
    isAnswered: false,
    isArchived: false,
    isSnoozed: false,
    status: Status.active,
  );

  List<CombinePrayerStream> get prayers => _prayers;
  List<CombinePrayerStream> get filteredPrayers => _filteredPrayers;
  List<PrayerUpdateModel> get prayerUpdates => _prayerUpdates;
  PrayerType get currentPrayerType => _currentPrayerType;
  List<HiddenPrayerModel> get hiddenPrayers => _hiddenPrayers;
  PrayerModel get currentPrayer => _currentPrayer;
  FilterType get filterOptions => _filterOptions;

  Future setPrayers(
    String userId,
  ) async {
    _prayerService.getPrayers(userId).asBroadcastStream().listen(
      (data) {
        _prayers = data.toList();
        _filteredPrayers = _prayers.where((p) =>
            p.prayer.status == Status.active &&
            !p.prayer.isArchived &&
            !p.prayer.isAnswer &&
            !p.prayer.isSnoozed);
        _filteredPrayers
            .sort((a, b) => b.prayer.modifiedOn.compareTo(a.prayer.modifiedOn));

        notifyListeners();
      },
    );
  }

  Future setGroupPrayers(
      String userId, String groupId, bool isGroupAdmin) async {
    _prayerService.getGroupPrayers(groupId).asBroadcastStream().listen((data) {
      var hiddenPrayersId =
          _hiddenPrayers.map((prayer) => prayer.prayerId).toList();
      _prayers =
          data.where((e) => !hiddenPrayersId.contains(e.prayer.id)).toList();
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

    List<CombinePrayerStream> filteredPrayers = _prayers
        .where((CombinePrayerStream data) =>
            data.prayer.status.toLowerCase() == status.toLowerCase())
        .toList();

    if (isAnswered == true) {
      filteredPrayers = filteredPrayers
          .where((CombinePrayerStream data) => data.prayer.isAnswer == true)
          .toList();
    }
    if (isArchived == true) {
      filteredPrayers = filteredPrayers
          .where((CombinePrayerStream data) => data.prayer.isArchived == true)
          .toList();
    }
    if (isSnoozed == true) {
      filteredPrayers = filteredPrayers
          .where((CombinePrayerStream data) => data.prayer.isSnoozed == true)
          .toList();
    }
    _filteredPrayers = filteredPrayers;
    _filteredPrayers
        .sort((a, b) => b.prayer.modifiedOn.compareTo(a.prayer.modifiedOn));
    notifyListeners();
  }

  Future addPrayer(PrayerModel prayerData, String _userID) async {
    await _prayerService.addPrayer(prayerData, _userID);
  }

  Future messageRequestor(PrayerRequestMessageModel prayerRequestData) async {
    return await _prayerService.messageRequestor(prayerRequestData);
  }

  Future tagPrayer(
      String userId, String prayerId, String tagger, String taggerId) async {
    return await _prayerService.tagPrayer(prayerId, userId, tagger, taggerId);
  }

  Future addPrayerWithGroups(BuildContext context, PrayerModel prayerData,
      List groups, String _userID) async {
    return await _prayerService.addPrayerWithGroup(
        context, prayerData, groups, _userID);
  }

  Future addPrayerUpdate(PrayerUpdateModel prayerUpdateData) async {
    return await _prayerService.addPrayerUpdate(prayerUpdateData);
  }

  Future addGroupPrayer(BuildContext context, PrayerModel prayerData) async {
    return await _prayerService.addGroupPrayer(context, prayerData);
  }

  Future editprayer(String description, String prayerID) async {
    return await _prayerService.editPrayer(description, prayerID);
  }

  Future archivePrayer(String prayerID) async {
    return await _prayerService.archivePrayer(prayerID);
  }

  Future unArchivePrayer(String prayerID) async {
    return await _prayerService.unArchivePrayer(prayerID);
  }

  Future markPrayerAsAnswered(String prayerID) async {
    return await _prayerService.markPrayerAsAnswered(prayerID);
  }

  Future deletePrayer(String prayerID) async {
    return await _prayerService.deletePrayer(prayerID);
  }

  Future hidePrayer(String prayerId, UserModel user) async {
    return await _prayerService.hidePrayer(prayerId, user);
  }

  Future setHiddenPrayers(String userId) async {
    _prayerService
        .getHiddenPrayers(userId)
        .asBroadcastStream()
        .listen((prayers) {
      _hiddenPrayers = prayers;
      notifyListeners();
    });
  }

  Future hidePrayerFromAllMembers(String prayerId, bool value) async {
    return await _prayerService.hideFromAllMembers(prayerId, value);
  }

  Future setCurrentPrayerType(PrayerType type) async {
    _currentPrayerType = type;
    notifyListeners();
  }

  Future addPrayerToMyList(UserPrayerModel userPrayer) async {
    return await _prayerService.addPrayerToMyList(userPrayer);
  }

  Future setPrayer(String id) async {
    _prayerService.getPrayer(id).asBroadcastStream().listen((prayer) {
      _currentPrayer = PrayerModel.fromData(prayer);
      notifyListeners();
    });
  }

  Future setPrayerUpdates(String prayerId) async {
    _prayerService
        .getPrayerUpdates(prayerId)
        .asBroadcastStream()
        .listen((prayerUpdates) {
      _prayerUpdates = prayerUpdates;
      notifyListeners();
    });
  }
}
