import 'dart:async';

import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/followed_prayer.model.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/update.model.dart';
import 'package:be_still/services/v2/prayer_service.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:be_still/utils/settings.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class PrayerProviderV2 with ChangeNotifier {
  PrayerServiceV2 _prayerService = locator<PrayerServiceV2>();
  UserServiceV2 _userService = locator<UserServiceV2>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late StreamSubscription<List<PrayerDataModel>> prayerStream;
  late StreamSubscription<List<PrayerDataModel>> groupPrayerStream;
  late StreamSubscription<List<PrayerDataModel>> followedPrayerStream;
  late StreamSubscription<List<PrayerDataModel>> prayerTimeStream;

  PrayerType _currentPrayerType = PrayerType.userPrayers;
  PrayerType get currentPrayerType => _currentPrayerType;

  Iterable<Contact> _localContacts = [];
  Iterable<Contact> get localContacts => _localContacts;

  List<PrayerDataModel> get filteredPrayerTimeList => _filteredPrayerTimeList;
  List<PrayerDataModel> _filteredPrayerTimeList = [];

  //======================= user prayers =================================

  List<PrayerDataModel> _prayers = [];
  List<PrayerDataModel> get prayers => _prayers;

  List<PrayerDataModel> _filteredPrayers = [];
  List<PrayerDataModel> get filteredPrayers => _filteredPrayers;

  //======================= group prayers =================================

  List<PrayerDataModel> _groupPrayers = [];
  List<PrayerDataModel> get groupPrayers => _groupPrayers;

  List<PrayerDataModel> _filteredGroupPrayers = [];
  List<PrayerDataModel> get filteredGroupPrayers => _filteredGroupPrayers;

  //=======================================================================

  List<PrayerDataModel> _followedPrayers = [];
  List<PrayerDataModel> get followedPrayers => _followedPrayers;

  List<FollowedPrayer> _userPrayers = [];
  List<FollowedPrayer> get userPrayers => _userPrayers;

  String _filterOption = Status.active;
  String get filterOption => _filterOption;

  String _currentPrayerId = '';
  String get currentPrayerId => _currentPrayerId;

  bool _isEdit = false;
  bool get isEdit => _isEdit;
  bool _showDropDown = false;
  bool get showDropDown => _showDropDown;

  PrayerDataModel _prayerToEdit = PrayerDataModel();
  PrayerDataModel get prayerToEdit => _prayerToEdit;

  List<UpdateModel> _prayerToEditUpdate = [];
  List<UpdateModel> get prayerToEditUpdate => _prayerToEditUpdate;

  List<TagModel> _prayerToEditTags = [];
  List<TagModel> get prayerToEditTags => _prayerToEditTags;

  Future<void> setPrayers(List<String> prayersIds) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;

      prayerStream = _prayerService
          .getUserPrayers()
          .asBroadcastStream()
          .listen((event) async {
        await _prayerService.getUserFollowedPrayers(prayersIds).then((event) {
          _followedPrayers = event;
        });
        _prayers = [...followedPrayers, ...event];
        filterPrayers();
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setGroupPrayers(String groupId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      groupPrayerStream = _prayerService
          .getGroupPrayers(groupId)
          .asBroadcastStream()
          .listen((event) {
        _groupPrayers = event;
        filterGroupPrayers();
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future setCurrentPrayerId(String prayerId) async {
    _currentPrayerId = prayerId;
    notifyListeners();
  }

  Future<void> getContacts() async {
    try {
      var status = await Permission.contacts.status;
      Settings.enabledContactPermission = status == PermissionStatus.granted;

      if (Settings.enabledContactPermission) {
        final localContacts =
            await ContactsService.getContacts(withThumbnails: false);
        _localContacts = localContacts.where((e) => e.displayName != null);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkPrayerValidity(
      String userId, List<String> prayersIds) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      if (prayers.length > 0) {
        // await _autoDeleteArchivePrayers(userId);
        // await _unSnoozePrayerPast(userId);
        await setPrayers(prayersIds);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setPrayerTimePrayers() async {
    try {
      // setPrayers();

      prayerTimeStream =
          _prayerService.getUserPrayers().asBroadcastStream().listen(
        (data) {
          data.sort((a, b) => (b.modifiedDate ?? DateTime.now())
              .compareTo(a.modifiedDate ?? DateTime.now()));

          _filteredPrayerTimeList = data
              .where((e) =>
                  (e.status ?? '').toLowerCase() == Status.active.toLowerCase())
              .toList();
          var favoritePrayers =
              data.where((PrayerDataModel e) => e.isFavorite ?? false).toList();

          _filteredPrayerTimeList = [
            ...favoritePrayers,
            ..._filteredPrayerTimeList
          ];
          List<PrayerDataModel> _distinct = [];
          var idSet = <String>{};
          for (var e in _filteredPrayerTimeList) {
            if (idSet.add(e.id ?? '')) {
              _distinct.add(e);
            }
          }
          _filteredPrayerTimeList = _distinct;
          notifyListeners();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> searchGroupPrayers(String searchQuery, String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      if (searchQuery == '') {
        filterGroupPrayers();
      } else {
        filterGroupPrayers();

        List<PrayerDataModel> filteredGroupPrayers = _filteredGroupPrayers
            .where((PrayerDataModel data) => (data.description ?? '')
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();
        for (int i = 0; i < _filteredGroupPrayers.length; i++) {
          bool hasMatch = (_filteredGroupPrayers[i].updates ?? <UpdateModel>[])
              .any((u) => (u.description ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()));
          if (hasMatch) _filteredGroupPrayers.add(_filteredPrayers[i]);
        }
        _filteredGroupPrayers = filteredGroupPrayers;
        _filteredGroupPrayers.sort((a, b) => (b.modifiedDate ?? DateTime.now())
            .compareTo(a.modifiedDate ?? DateTime.now()));
        List<PrayerDataModel> _distinct = [];
        var idSet = <String>{};
        for (var e in _filteredGroupPrayers) {
          if (idSet.add(e.id ?? "")) {
            _distinct.add(e);
          }
        }
        _filteredGroupPrayers = _distinct;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> searchPrayers(String searchQuery, String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      if (searchQuery == '') {
        filterPrayers();
      } else {
        filterPrayers();

        List<PrayerDataModel> filteredPrayers = _filteredPrayers
            .where((PrayerDataModel data) => (data.description ?? '')
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();
        for (int i = 0; i < _filteredPrayers.length; i++) {
          bool hasMatch = (_filteredPrayers[i].updates ?? <UpdateModel>[]).any(
              (u) => (u.description ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()));
          if (hasMatch) filteredPrayers.add(_filteredPrayers[i]);
        }
        _filteredPrayers = filteredPrayers;
        _filteredPrayers.sort((a, b) => (b.modifiedDate ?? DateTime.now())
            .compareTo(a.modifiedDate ?? DateTime.now()));
        List<PrayerDataModel> _distinct = [];
        var idSet = <String>{};
        for (var e in _filteredPrayers) {
          if (idSet.add(e.id ?? "")) {
            _distinct.add(e);
          }
        }
        _filteredPrayers = _distinct;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<PrayerDataModel> getPrayer({required String prayerId}) {
    try {
      return _prayerService.getPrayer(prayerId);
    } catch (e) {
      rethrow;
    }
  }

  void setPrayerFilterOptions(String option) {
    try {
      _filterOption = option;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unSnoozePrayerPast(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _prayerService.autoUnSnoozePrayers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrayer(String groupId, String prayerDesc, bool isGroup,
      List<Contact> contacts) async {
    try {
      await _prayerService.createPrayer(
          groupId: groupId,
          description: prayerDesc,
          isGroup: isGroup,
          contacts: contacts);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrayerTag(List<Contact> contactData, String username,
      String description, String prayerId) async {
    try {
      await _prayerService.createPrayerTag(
          contactData: contactData,
          username: username,
          description: description,
          prayerId: prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePrayerTag(TagModel tag, String prayerId) async {
    try {
      await _prayerService.removePrayerTag(currentTag: tag, prayerId: prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrayerUpdate(
      List<UpdateModel> updates, String prayerId, String description) async {
    try {
      await _prayerService.createPrayerUpdate(
          prayerId: prayerId, description: description);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editprayer(String description, String prayerId) async {
    try {
      await _prayerService.editPrayer(
          prayerId: prayerId, description: description);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editUpdate(
      String description, String prayerId, UpdateModel update) async {
    try {
      await _prayerService.editPrayerUpdate(
        description: description,
        prayerId: prayerId,
        update: update,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> archivePrayer(String prayerId) async {
    try {
      await _prayerService.archivePrayer(prayerId: prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unArchivePrayer(
      String prayerId, List<FollowerModel> followers, bool isAdmin) async {
    try {
      await _prayerService.unArchivePrayer(
          currentFollowers: followers, isAdmin: isAdmin, prayerId: prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> snoozePrayer(String userId, String prayerID, int duration,
      DateTime snoozeEndDate, List<String> prayersIds) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _prayerService.snoozePrayer(
          prayerId: prayerID, snoozeEndDate: snoozeEndDate);

      Future.delayed(Duration(minutes: duration), () async {
        await unSnoozePrayerPast(userId);
        await setPrayers(prayersIds);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unSnoozePrayer(String prayerId) async {
    try {
      await _prayerService.unSnoozePrayer(prayerId: prayerId);
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> autoDeleteArchivePrayers(String userId) async {
  //   try {
  //     if (_firebaseAuth.currentUser == null) return null;
  //     _prayerService.autoDeleteArchivePrayers(
  //         userId, settings.archiveAutoDeleteMins ?? 0);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> favoritePrayer(String prayerID) async {
    try {
      await _prayerService.favoritePrayer(prayerId: prayerID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unfavoritePrayer(String prayerID) async {
    try {
      await _prayerService.unFavoritePrayer(prayerId: prayerID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markPrayerAsAnswered(String prayerId) async {
    try {
      await _prayerService.markPrayerAsAnswered(prayerId: prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unMarkPrayerAsAnswered(String prayerId) async {
    try {
      await _prayerService.unMarkPrayerAsAnswered(prayerId: prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePrayer(String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _prayerService.deletePrayer(prayerId: prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUpdate(String prayerId, UpdateModel update) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _prayerService.deleteUpdate(
        currentUpdate: update,
        prayerId: prayerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setCurrentPrayerType(PrayerType type) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _currentPrayerType = type;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void setEditMode(bool value, bool showDropDown) {
    try {
      _isEdit = value;
      _showDropDown = showDropDown;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void setEditPrayer(
      {required PrayerDataModel prayer,
      required List<UpdateModel> updates,
      required List<TagModel> tags}) {
    try {
      _prayerToEdit = prayer;
      _prayerToEditUpdate = updates;
      _prayerToEditTags = tags;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void filterGroupPrayers() {
    if (_firebaseAuth.currentUser == null) return null;
    List<PrayerDataModel> groupPrayers = _groupPrayers.toList();
    List<PrayerDataModel> activeGroupPrayers = [];
    List<PrayerDataModel> answeredGroupPrayers = [];
    List<PrayerDataModel> archivedGroupPrayers = [];
    List<PrayerDataModel> allGroupPrayers = [];

    if (_filterOption == Status.all) {
      allGroupPrayers = groupPrayers;
    }

    if (_filterOption == Status.active) {
      activeGroupPrayers = groupPrayers
          .where((PrayerDataModel data) =>
              (data.status ?? '').toLowerCase() == Status.active.toLowerCase())
          .toList();
    }

    if (_filterOption == Status.answered) {
      answeredGroupPrayers = groupPrayers
          .where((PrayerDataModel data) =>
              (data.status == Status.archived) &&
              (data.isAnswered ?? false) == true)
          .toList();
    }

    if (_filterOption == Status.archived) {
      archivedGroupPrayers = groupPrayers
          .where((PrayerDataModel data) => data.status == Status.archived)
          .toList();
    }

    _filteredGroupPrayers = [
      ...allGroupPrayers,
      ...activeGroupPrayers,
      ...archivedGroupPrayers,
      ...answeredGroupPrayers
    ];

    _filteredGroupPrayers.sort((a, b) => (b.modifiedDate ?? DateTime.now())
        .compareTo(a.modifiedDate ?? DateTime.now()));

    List<PrayerDataModel> _groupDistinct = [];
    var idSet = <String>{};

    for (var e in _filteredGroupPrayers) {
      if (idSet.add(e.id ?? '')) {
        _groupDistinct.add(e);
      }
    }

    _filteredGroupPrayers = _groupDistinct;
    notifyListeners();
  }

  void filterPrayers() {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      List<PrayerDataModel> prayers = _prayers.toList();
      List<PrayerDataModel> activePrayers = [];
      List<PrayerDataModel> answeredPrayers = [];
      List<PrayerDataModel> snoozedPrayers = [];
      List<PrayerDataModel> favoritePrayers = [];
      List<PrayerDataModel> archivedPrayers = [];
      List<PrayerDataModel> followingPrayers = [];
      List<PrayerDataModel> allPrayers = [];
      if (_filterOption == Status.all) {
        favoritePrayers = prayers
            .where((PrayerDataModel data) =>
                (data.isFavorite ?? false) && (data.status != Status.active))
            .toList();
        allPrayers = prayers;
      }

      if (_filterOption == Status.active) {
        favoritePrayers = prayers
            .where((PrayerDataModel data) =>
                (data.isFavorite ?? false) &&
                !(data.status == Status.snoozed) &&
                (data.status == Status.active))
            .toList();
        activePrayers = prayers
            .where((PrayerDataModel data) =>
                (data.status ?? '').toLowerCase() ==
                Status.active.toLowerCase())
            .toList();
      }
      if (_filterOption == Status.answered) {
        answeredPrayers = prayers
            .where((PrayerDataModel data) =>
                (data.status == Status.archived) &&
                (data.isAnswered ?? false) == true)
            .toList();
      }
      if (_filterOption == Status.archived) {
        archivedPrayers = prayers
            .where((PrayerDataModel data) => data.status == Status.archived)
            .toList();
      }
      if (_filterOption == Status.snoozed) {
        snoozedPrayers = prayers
            .where((PrayerDataModel data) => data.status == Status.snoozed
                //&&
                // (data.userPrayer?.snoozeEndDate ?? DateTime.now())
                //     .isAfter(DateTime.now())
                )
            .toList();
      }
      if (_filterOption == Status.following) {
        followingPrayers = prayers
            .where((PrayerDataModel data) => (data.isGroup ?? false))
            .toList();
      }
      _filteredPrayers = [
        ...allPrayers,
        ...activePrayers,
        ...archivedPrayers,
        ...snoozedPrayers,
        ...answeredPrayers,
        ...followingPrayers
      ];

      _filteredPrayers.sort((a, b) => (b.modifiedDate ?? DateTime.now())
          .compareTo(a.modifiedDate ?? DateTime.now()));

      _filteredPrayers = [...favoritePrayers, ..._filteredPrayers];
      List<PrayerDataModel> _distinct = [];
      var idSet = <String>{};
      for (var e in _filteredPrayers) {
        if (idSet.add(e.id ?? '')) {
          _distinct.add(e);
        }
      }

      _filteredPrayers = _distinct;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> followPrayer(
      String prayerId, String groupId, List<String> prayersIds) async {
    _prayerService.followPrayer(prayerId: prayerId, groupId: groupId);
    await setPrayers(prayersIds);
  }

  Future<void> unFollowPrayer(
      String prayerId, String groupId, List<String> prayersIds) async {
    _prayerService.unFollowPrayer(prayerId: prayerId, groupId: groupId);
    await setPrayers(prayersIds);
  }

  void flush() {
    prayerStream.cancel();
    // followedPrayerStream.cancel();
    // groupPrayerStream.cancel();
    prayerTimeStream.cancel();
  }
}
