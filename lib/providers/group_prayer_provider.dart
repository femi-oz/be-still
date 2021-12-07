import 'dart:async';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/group_prayer_service.dart';
import 'package:be_still/utils/settings.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupPrayerProvider with ChangeNotifier {
  GroupPrayerService _prayerService = locator<GroupPrayerService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<CombineGroupPrayerStream> _prayers = [];
  List<CombineGroupPrayerStream> _filteredPrayers = [];
  Iterable<Contact> _localContacts = [];

  CombineGroupPrayerStream _currentPrayer;
  List<HiddenPrayerModel> _hiddenPrayers = [];
  List<FollowedPrayerModel> _followedPrayers = [];

  List<CombineGroupPrayerStream> get prayers => _prayers;
  List<CombineGroupPrayerStream> get filteredPrayers => _filteredPrayers;

  Iterable<Contact> get localContacts => _localContacts;
  CombineGroupPrayerStream get currentPrayer => _currentPrayer;
  List<HiddenPrayerModel> get hiddenPrayers => _hiddenPrayers;
  List<FollowedPrayerModel> get followedPrayers => _followedPrayers;

  bool _isEdit = false;
  bool get isEdit => _isEdit;

  String _newPrayerId = '';
  String get newPrayerId => _newPrayerId;

  CombineGroupPrayerStream _prayerToEdit;
  CombineGroupPrayerStream get prayerToEdit => _prayerToEdit;

  String _filterOption = Status.active;
  String get filterOption => _filterOption;

  Future<void> setGroupPrayers(String groupId) async {
    _filteredPrayers = [];
    _prayerService.getPrayers(groupId).asBroadcastStream().listen(
      (data) {
        _prayers = data.where((e) => e.groupPrayer.deleteStatus > -1).toList();
        _filteredPrayers = _prayers;
        filterPrayers();
        notifyListeners();
      },
    );
  }

  Future<void> setPrayer(String id) async =>
      _prayerService.getPrayer(id).asBroadcastStream().listen((prayer) {
        _currentPrayer = prayer;
        notifyListeners();
      });

  Future<CombineGroupPrayerStream> setPrayerFuture(String id) async =>
      _prayerService.getPrayerFuture(id).then((prayer) {
        _currentPrayer = prayer;
        notifyListeners();
        return _currentPrayer;
      });

  Future<void> setHiddenPrayer(String id) async =>
      _prayerService.getHiddenPrayers(id).asBroadcastStream().listen((prayer) {
        _hiddenPrayers = prayer;
        notifyListeners();
      });

  Future<void> setFollowedPrayer(String id) async => _prayerService
          .getFollowedPrayers(id)
          .asBroadcastStream()
          .listen((prayer) {
        _followedPrayers = prayer;
        notifyListeners();
      });

  Future<void> addPrayer(
    String prayerDesc,
    String groupId,
    String creatorName,
    String prayerDescBackup,
    String userId,
  ) async =>
      await _prayerService
          .addPrayer(prayerDesc, groupId, creatorName, prayerDescBackup, userId)
          .then((value) => _newPrayerId = value);

  Future<void> messageRequestor(
          PrayerRequestMessageModel prayerRequestData) async =>
      await _prayerService.messageRequestor(prayerRequestData);

  Future<void> addPrayerWithGroups(BuildContext context, PrayerModel prayerData,
          List groups, String _userID) async =>
      await _prayerService.addPrayerWithGroup(
          context, prayerData, groups, _userID);

  Future<void> hidePrayer(String prayerId, UserModel user) async =>
      await _prayerService.hidePrayer(prayerId, user);

  Future<void> hidePrayerFromAllMembers(String prayerId, bool value) async =>
      await _prayerService.hideFromAllMembers(prayerId, value);

  Future<void> getContacts() async {
    var status = await Permission.contacts.status;
    Settings.enabledContactPermission = status == PermissionStatus.granted;

    if (Settings.enabledContactPermission) {
      final localContacts =
          await ContactsService.getContacts(withThumbnails: false);
      _localContacts = localContacts.where((e) => e.displayName != null);
    }
  }

  Future<void> archivePrayer(String userPrayerId) async =>
      await _prayerService.archivePrayer(userPrayerId);

  Future<void> unArchivePrayer(String userPrayerId, String prayerID) async =>
      await _prayerService.unArchivePrayer(userPrayerId, prayerID);

  Future<void> unSnoozePrayer(
          String prayerID, DateTime snoozeEndDate, String userPrayerID) async =>
      await _prayerService.unSnoozePrayer(snoozeEndDate, userPrayerID);

  Future<void> markPrayerAsAnswered(
    String prayerId,
    String userPrayerId,
  ) async =>
      await _prayerService.markPrayerAsAnswered(prayerId, userPrayerId);

  Future<void> unMarkPrayerAsAnswered(
    String prayerId,
    String userPrayerId,
  ) async =>
      await _prayerService.unMarkPrayerAsAnswered(prayerId, userPrayerId);

  Future<void> favoritePrayer(String prayerID) async =>
      await _prayerService.favoritePrayer(prayerID);

  Future<void> unfavoritePrayer(String prayerID) async =>
      await _prayerService.unFavoritePrayer(prayerID);

  Future<void> deletePrayer(String userPrayeId, String prayerId) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _prayerService.deletePrayer(userPrayeId, prayerId);
  }

  Future<void> deleteUpdate(String prayerId) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _prayerService.deleteUpdate(prayerId);
  }

  Future<void> editUpdate(String description, String prayerID) async =>
      await _prayerService.editUpdate(description, prayerID);

  Future<void> addPrayerTag(List<Contact> contactData, UserModel user,
          String message, String prayerId) async =>
      await _prayerService.addPrayerTag(contactData, user, message, prayerId);

  Future<void> editprayer(String description, String prayerID) async =>
      await _prayerService.editPrayer(description, prayerID);

  Future<void> removePrayerTag(String tagId) async =>
      await _prayerService.removePrayerTag(tagId);

  Future<void> searchPrayers(String searchQuery, String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    if (searchQuery == '') {
      filterPrayers();
    } else {
      filterPrayers();
      List<CombineGroupPrayerStream> filteredPrayers = _filteredPrayers
          .where((CombineGroupPrayerStream data) => data.prayer.description
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

  Future<void> addPrayerUpdate(
          String userId, String prayer, String prayerId) async =>
      await _prayerService.addPrayerUpdate(userId, prayer, prayerId);
  void setEditMode(bool value) {
    _isEdit = value;
    notifyListeners();
  }

  void setEditPrayer(CombineGroupPrayerStream data) {
    _prayerToEdit = data;
    notifyListeners();
  }

  void setPrayerFilterOptions(String option) {
    _filterOption = option;
    notifyListeners();
  }

  Future<void> filterPrayers() async {
    if (_firebaseAuth.currentUser == null) return null;
    List<CombineGroupPrayerStream> prayers = _prayers.toList();
    List<CombineGroupPrayerStream> activePrayers = [];
    List<CombineGroupPrayerStream> answeredPrayers = [];
    List<CombineGroupPrayerStream> snoozedPrayers = [];
    List<CombineGroupPrayerStream> favoritePrayers = [];
    List<CombineGroupPrayerStream> archivedPrayers = [];
    List<CombineGroupPrayerStream> allPrayers = [];
    if (_filterOption == Status.all) {
      favoritePrayers = prayers
          .where((CombineGroupPrayerStream data) => data.groupPrayer.isFavorite)
          .toList();
      allPrayers = prayers;
    }
    if (_filterOption == Status.active) {
      favoritePrayers = prayers
          .where((CombineGroupPrayerStream data) => data.groupPrayer.isFavorite)
          .toList();
      activePrayers = prayers
          .where((CombineGroupPrayerStream data) =>
              data.groupPrayer.status.toLowerCase() ==
              Status.active.toLowerCase())
          .toList();
    }
    if (_filterOption == Status.answered) {
      answeredPrayers = prayers
          .where(
              (CombineGroupPrayerStream data) => data.prayer.isAnswer == true)
          .toList();
    }
    if (_filterOption == Status.archived) {
      archivedPrayers = prayers
          .where((CombineGroupPrayerStream data) =>
              data.groupPrayer.isArchived == true)
          .toList();
    }
    if (_filterOption == Status.following) {
      archivedPrayers = prayers
          .where((CombineGroupPrayerStream data) => data.prayer.isGroup == true)
          .toList();
    }
    if (_filterOption == Status.snoozed) {
      snoozedPrayers = prayers
          .where((CombineGroupPrayerStream data) =>
              data.groupPrayer.isSnoozed == true &&
              data.groupPrayer.snoozeEndDate.isAfter(DateTime.now()))
          .toList();
    }
    _filteredPrayers = [
      ...allPrayers,
      ...activePrayers,
      ...archivedPrayers,
      ...snoozedPrayers,
      ...answeredPrayers
    ];
    _filteredPrayers
        .sort((a, b) => b.prayer.modifiedOn.compareTo(a.prayer.modifiedOn));
    _filteredPrayers = [...favoritePrayers, ..._filteredPrayers];
    List<CombineGroupPrayerStream> _distinct = [];
    var idSet = <String>{};
    for (var e in _filteredPrayers) {
      if (idSet.add(e.prayer.id)) {
        _distinct.add(e);
      }
    }
    _filteredPrayers = _distinct;
    notifyListeners();
  }

  Future<void> flagAsInappropriate(String prayerId) async =>
      await _prayerService.flagAsInappropriate(prayerId);
  Future<void> addToMyList(String prayerId, String userId) async =>
      await _prayerService.addToMyList(prayerId, userId);
  Future<void> removeFromMyList(
          String followedPrayerId, String userPrayerId) async =>
      await _prayerService.removeFromMyList(followedPrayerId, userPrayerId);
}
