import 'dart:async';
import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/utils/settings.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class PrayerProvider with ChangeNotifier {
  PrayerService _prayerService = locator<PrayerService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<CombinePrayerStream> _prayers = [];
  PrayerType _currentPrayerType = PrayerType.userPrayers;
  List<CombinePrayerStream> _filteredPrayers = [];
  List<CombinePrayerStream> _filteredPrayerTimeList = [];
  Iterable<Contact> _localContacts = [];

  String _filterOption = Status.active;

  List<CombinePrayerStream> get prayers => _prayers;
  List<CombinePrayerStream> get filteredPrayers => _filteredPrayers;

  List<CombinePrayerStream> get filteredPrayerTimeList =>
      _filteredPrayerTimeList;

  Iterable<Contact> get localContacts => _localContacts;
  PrayerType get currentPrayerType => _currentPrayerType;
  String get filterOption => _filterOption;

  bool _isEdit = false;
  bool get isEdit => _isEdit;
  bool _showDropDown = false;
  bool get showDropDown => _showDropDown;

  PrayerModel _prayerToEdit = PrayerModel.defaultValue();
  PrayerModel get prayerToEdit => _prayerToEdit;

  List<PrayerUpdateModel> _prayerToEditUpdate = [];
  List<PrayerUpdateModel> get prayerToEditUpdate => _prayerToEditUpdate;

  List<PrayerTagModel> _prayerToEditTags = [];
  List<PrayerTagModel> get prayerToEditTags => _prayerToEditTags;

  late StreamSubscription<List<CombinePrayerStream>> prayerStream;

  Future<void> setPrayers(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      prayerStream =
          _prayerService.getPrayers(userId).asBroadcastStream().listen(
        (data) {
          _prayers = data;
          filterPrayers();
          notifyListeners();
        },
      );
    } catch (e) {
      rethrow;
    }
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

  Future<void> checkPrayerValidity(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      if (prayers.length > 0) {
        await _autoDeleteArchivePrayers(userId);
        await _unSnoozePrayerPast(userId);
        await setPrayers(userId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setPrayerTimePrayers(String userId) async {
    try {
      prayerStream =
          _prayerService.getPrayers(userId).asBroadcastStream().listen(
        (data) {
          _prayers = [...data];
          _prayers.sort((a, b) => (b.prayer?.modifiedOn ?? DateTime.now())
              .compareTo(a.prayer?.modifiedOn ?? DateTime.now()));

          _filteredPrayerTimeList = _prayers
              .where((e) =>
                  (e.userPrayer?.status ?? '').toLowerCase() ==
                  Status.active.toLowerCase())
              .toList();
          var favoritePrayers = _prayers
              .where(
                  (CombinePrayerStream e) => e.userPrayer?.isFavorite ?? false)
              .toList();

          _filteredPrayerTimeList = [
            ...favoritePrayers,
            ..._filteredPrayerTimeList
          ];
          List<CombinePrayerStream> _distinct = [];
          var idSet = <String>{};
          for (var e in _filteredPrayerTimeList) {
            if (idSet.add(e.prayer?.id ?? '')) {
              _distinct.add(e);
            }
          }
          _filteredPrayerTimeList = _distinct;
        },
      );
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

        List<CombinePrayerStream> filteredPrayers = _filteredPrayers
            .where((CombinePrayerStream data) =>
                (data.prayer?.description ?? '')
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList();
        for (int i = 0; i < _filteredPrayers.length; i++) {
          var hasMatch = _filteredPrayers[i].updates.any((u) =>
              (u.description ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()));
          if (hasMatch) filteredPrayers.add(_filteredPrayers[i]);
        }
        _filteredPrayers = filteredPrayers;
        _filteredPrayers.sort((a, b) => (b.prayer?.modifiedOn ?? DateTime.now())
            .compareTo(a.prayer?.modifiedOn ?? DateTime.now()));
        List<CombinePrayerStream> _distinct = [];
        var idSet = <String>{};
        for (var e in _filteredPrayers) {
          if (idSet.add(e.prayer?.id ?? "")) {
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

  String _currentPrayerId = '';
  String get currentPrayerId => _currentPrayerId;

  void setCurrentPrayerId(String prayerId) => _currentPrayerId = prayerId;

  Stream<CombinePrayerStream> getPrayer() {
    try {
      return _prayerService.getPrayer(_currentPrayerId);
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

  Future<void> filterPrayers() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      List<CombinePrayerStream> prayers = _prayers.toList();
      List<CombinePrayerStream> activePrayers = [];
      List<CombinePrayerStream> answeredPrayers = [];
      List<CombinePrayerStream> snoozedPrayers = [];
      List<CombinePrayerStream> favoritePrayers = [];
      List<CombinePrayerStream> archivedPrayers = [];
      List<CombinePrayerStream> followingPrayers = [];
      List<CombinePrayerStream> allPrayers = [];
      if (_filterOption == Status.all) {
        favoritePrayers = prayers
            .where((CombinePrayerStream data) =>
                data.userPrayer?.isFavorite ?? false)
            .toList();
        allPrayers = prayers;
      }
      if (_filterOption == Status.active) {
        favoritePrayers = prayers
            .where((CombinePrayerStream data) =>
                (data.userPrayer?.isFavorite ?? false) &&
                !(data.userPrayer?.isSnoozed ?? false))
            .toList();
        activePrayers = prayers
            .where((CombinePrayerStream data) =>
                (data.userPrayer?.status ?? '').toLowerCase() ==
                Status.active.toLowerCase())
            .toList();
      }
      if (_filterOption == Status.answered) {
        answeredPrayers = prayers
            .where((CombinePrayerStream data) => data.prayer?.isAnswer == true)
            .toList();
      }
      if (_filterOption == Status.archived) {
        archivedPrayers = prayers
            .where((CombinePrayerStream data) =>
                data.userPrayer?.isArchived == true)
            .toList();
      }
      if (_filterOption == Status.snoozed) {
        snoozedPrayers = prayers
            .where(
                (CombinePrayerStream data) => data.userPrayer?.isSnoozed == true
                //&&
                // (data.userPrayer?.snoozeEndDate ?? DateTime.now())
                //     .isAfter(DateTime.now())
                )
            .toList();
      }
      if (_filterOption == Status.following) {
        followingPrayers = prayers
            .where((CombinePrayerStream data) => data.prayer?.isGroup ?? false)
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
      _filteredPrayers.sort((a, b) => (b.prayer?.modifiedOn ?? DateTime.now())
          .compareTo(a.prayer?.modifiedOn ?? DateTime.now()));
      _filteredPrayers = [...favoritePrayers, ..._filteredPrayers];
      List<CombinePrayerStream> _distinct = [];
      var idSet = <String>{};
      for (var e in _filteredPrayers) {
        if (idSet.add(e.prayer?.id ?? '')) {
          _distinct.add(e);
        }
      }
      _filteredPrayers = _distinct;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _unSnoozePrayerPast(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await locator<PrayerService>().unSnoozePrayerPast(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrayer(
    String prayerDesc,
    String userId,
    String creatorName,
    String prayerDescBackup,
  ) async {
    try {
      await _prayerService.addPrayer(
          prayerDesc, userId, creatorName, prayerDescBackup);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrayerTag(List<Contact> contactData, UserModel user,
      String message, String prayerId) async {
    try {
      await _prayerService.addPrayerTag(contactData, user, message, prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePrayerTag(String tagId) async {
    try {
      await _prayerService.removePrayerTag(tagId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrayerUpdate(
      String userId, String prayer, String prayerId) async {
    try {
      await _prayerService.addPrayerUpdate(userId, prayer, prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editprayer(String description, String prayerID) async {
    try {
      await _prayerService.editPrayer(description, prayerID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editUpdate(String description, String prayerID) async {
    try {
      await _prayerService.editUpdate(description, prayerID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> archivePrayer(String userPrayerId) async {
    try {
      await _prayerService.archivePrayer(userPrayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unArchivePrayer(String userPrayerId, String prayerID) async {
    try {
      await _prayerService.unArchivePrayer(userPrayerId, prayerID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> snoozePrayer(
      String userId,
      String prayerID,
      DateTime snoozeEndDate,
      String userPrayerID,
      int duration,
      String frequency) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _prayerService.snoozePrayer(
          snoozeEndDate, userPrayerID, duration, frequency);

      Future.delayed(Duration(minutes: duration), () async {
        await _unSnoozePrayerPast(userId);
        await setPrayers(userId);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unSnoozePrayer(
      String prayerID, DateTime snoozeEndDate, String userPrayerID) async {
    try {
      await _prayerService.unSnoozePrayer(snoozeEndDate, userPrayerID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _autoDeleteArchivePrayers(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      final settings = await locator<SettingsService>().getSettings(userId);
      _prayerService.autoDeleteArchivePrayers(
          userId, settings.archiveAutoDeleteMins ?? 0);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> favoritePrayer(String prayerID) async {
    try {
      await _prayerService.favoritePrayer(prayerID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unfavoritePrayer(String prayerID) async {
    try {
      await _prayerService.unFavoritePrayer(prayerID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markPrayerAsAnswered(
    String prayerId,
    String userPrayerId,
  ) async {
    try {
      await _prayerService.markPrayerAsAnswered(prayerId, userPrayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unMarkPrayerAsAnswered(
    String prayerId,
    String userPrayerId,
  ) async {
    try {
      await _prayerService.unMarkPrayerAsAnswered(prayerId, userPrayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePrayer(String userPrayeId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _prayerService.deletePrayer(userPrayeId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUpdate(String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _prayerService.deleteUpdate(prayerId);
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
      {required PrayerModel prayer,
      required List<PrayerUpdateModel> updates,
      required List<PrayerTagModel> tags}) {
    try {
      _prayerToEdit = prayer;
      _prayerToEditUpdate = updates;
      _prayerToEditTags = tags;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void flush() {
    prayerStream.cancel();
  }
}
