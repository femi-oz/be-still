import 'dart:async';
import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/notification_service.dart';
import 'package:be_still/services/prayer_service.dart';
import 'package:be_still/services/settings_service.dart';
import 'package:be_still/utils/local_notification.dart';
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

  CombinePrayerStream _currentPrayer = CombinePrayerStream.defaultValue();
  String _filterOption = Status.active;

  List<CombinePrayerStream> get prayers => _prayers;
  List<CombinePrayerStream> get filteredPrayers => _filteredPrayers;

  List<CombinePrayerStream> get filteredPrayerTimeList =>
      _filteredPrayerTimeList;

  Iterable<Contact> get localContacts => _localContacts;
  PrayerType get currentPrayerType => _currentPrayerType;
  CombinePrayerStream get currentPrayer => _currentPrayer;
  String get filterOption => _filterOption;

  bool _isEdit = false;
  bool get isEdit => _isEdit;
  bool _showDropDown = false;
  bool get showDropDown => _showDropDown;

  CombinePrayerStream _prayerToEdit = CombinePrayerStream.defaultValue();
  CombinePrayerStream get prayerToEdit => _prayerToEdit;

  Future<void> setPrayers(String userId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _prayerService.getPrayers(userId).asBroadcastStream().listen(
        (data) {
          _prayers = data.where((e) => e.userPrayer.deleteStatus > -1).toList();
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

  Future<void> checkPrayerValidity(
      String userId, List<LocalNotificationModel> notifications) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      if (prayers.length > 0) {
        await _autoDeleteArchivePrayers(userId, prayers, notifications);
        await _unSnoozePrayerPast(prayers);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setPrayerTimePrayers(String userId) async {
    try {
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
        List<CombinePrayerStream> _distinct = [];
        var idSet = <String>{};
        for (var e in _filteredPrayers) {
          if (idSet.add(e.prayer.id)) {
            _distinct.add(e);
          }
        }
        _filteredPrayers = _distinct;
      }
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> setPrayer(String id) async {
    try {
      _prayerService.getPrayer(id).asBroadcastStream().listen((prayer) {
        _currentPrayer = prayer;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  void setPrayerFilterOptions(String option) {
    try {
      _filterOption = option;
    } catch (e) {
      rethrow;
    }
    notifyListeners();
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
            .where((CombinePrayerStream data) => data.userPrayer.isFavorite)
            .toList();
        allPrayers = prayers;
      }
      if (_filterOption == Status.active) {
        favoritePrayers = prayers
            .where((CombinePrayerStream data) =>
                data.userPrayer.isFavorite && !data.userPrayer.isSnoozed)
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
            .where((CombinePrayerStream data) =>
                data.userPrayer.isArchived == true)
            .toList();
      }
      if (_filterOption == Status.snoozed) {
        snoozedPrayers = prayers
            .where((CombinePrayerStream data) =>
                data.userPrayer.isSnoozed == true &&
                data.userPrayer.snoozeEndDate.isAfter(DateTime.now()))
            .toList();
      }
      if (_filterOption == Status.following) {
        followingPrayers = prayers
            .where((CombinePrayerStream data) => data.prayer.isGroup)
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
    } catch (e) {
      rethrow;
    }

    notifyListeners();
  }

  Future<void> _unSnoozePrayerPast(List<CombinePrayerStream> data) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var prayersToUnsnooze = data
          .where((e) =>
              e.userPrayer.snoozeEndDate.isBefore(DateTime.now()) &&
              e.userPrayer.isSnoozed == true)
          .toList();

      for (int i = 0; i < prayersToUnsnooze.length; i++) {
        await locator<PrayerService>()
            .unSnoozePrayer(DateTime.now(), prayersToUnsnooze[i].userPrayer.id);
      }
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

  Future<void> snoozePrayer(String prayerID, DateTime snoozeEndDate,
      String userPrayerID, int duration, String frequency) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _prayerService.snoozePrayer(
          snoozeEndDate, userPrayerID, duration, frequency);
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

  Future<void> _autoDeleteArchivePrayers(
      String userId,
      List<CombinePrayerStream> data,
      List<LocalNotificationModel> notifications) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      final settings = await locator<SettingsService>().getSettings(userId);
      final autoDeleteAnswered = settings.includeAnsweredPrayerAutoDelete;
      final autoDeleteDuration = settings.archiveAutoDeleteMins;
      if (autoDeleteDuration > 0) {
        final archivedPrayers = data
            .where((CombinePrayerStream data) =>
                data.userPrayer.isArchived == true)
            .toList();
        List<CombinePrayerStream> toDelete = archivedPrayers;
        if (!autoDeleteAnswered) {
          toDelete = toDelete
              .where((CombinePrayerStream e) => e.prayer.isAnswer == false)
              .toList();
        }

        for (int i = 0; i < toDelete.length; i++) {
          if ((toDelete[i].userPrayer.archivedDate ?? DateTime.now())
                  .add(Duration(minutes: autoDeleteDuration))
                  .isBefore(DateTime.now()) &&
              autoDeleteDuration != 0) {
            final _notifications = notifications
                .where((e) => e.entityId == toDelete[i].userPrayer.id)
                .toList();

            _notifications.forEach((e) async {
              final notification =
                  _notifications.firstWhere((e) => e.id == e.id);
              await LocalNotification.unschedule(
                  notification.localNotificationId);
              await locator<NotificationService>()
                  .removeLocalNotification(e.id ?? '');
            });
            deletePrayer(toDelete[i].userPrayer.id);
          }
        }
      }
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
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  void setEditMode(bool value, bool showDropDown) {
    try {
      _isEdit = value;
      _showDropDown = showDropDown;
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  void setEditPrayer({CombinePrayerStream? data}) {
    try {
      _prayerToEdit = data ?? CombinePrayerStream.defaultValue();
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }
}
