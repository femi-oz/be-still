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

  CombinePrayerStream _currentPrayer;
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

  CombinePrayerStream _prayerToEdit;
  CombinePrayerStream get prayerToEdit => _prayerToEdit;

  Future<void> setPrayers(String userId) async {
    if (_firebaseAuth.currentUser == null) return null;
    _prayerService.getPrayers(userId).asBroadcastStream().listen(
      (data) {
        _prayers = data.where((e) => e.userPrayer.deleteStatus > -1).toList();
        filterPrayers();
        notifyListeners();
      },
    );
  }

  Future<void> getContacts() async {
    var status = await Permission.contacts.status;
    Settings.enabledContactPermission = status == PermissionStatus.granted;

    if (Settings.enabledContactPermission) {
      final localContacts =
          await ContactsService.getContacts(withThumbnails: false);
      _localContacts = localContacts.where((e) => e.displayName != null);
    }
  }

  Future<void> checkPrayerValidity(
      String userId, List<LocalNotificationModel> notifications) async {
    if (_firebaseAuth.currentUser == null) return null;
    if (prayers.length > 0) {
      await _autoDeleteArchivePrayers(userId, prayers, notifications);
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
        },
      );

  Future<void> searchPrayers(String searchQuery, String userId) async {
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
    notifyListeners();
  }

  Future<void> _unSnoozePrayerPast(List<CombinePrayerStream> data) async {
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
  }

  Future<void> addPrayer(
    String prayerDesc,
    String userId,
    String creatorName,
    String prayerDescBackup,
  ) async =>
      await _prayerService.addPrayer(
          prayerDesc, userId, creatorName, prayerDescBackup);

  Future<void> addPrayerTag(List<Contact> contactData, UserModel user,
          String message, String prayerId) async =>
      await _prayerService.addPrayerTag(contactData, user, message, prayerId);

  Future<void> removePrayerTag(String tagId) async =>
      await _prayerService.removePrayerTag(tagId);

  Future<void> addPrayerUpdate(
          String userId, String prayer, String prayerId) async =>
      await _prayerService.addPrayerUpdate(userId, prayer, prayerId);

  Future<void> editprayer(String description, String prayerID) async =>
      await _prayerService.editPrayer(description, prayerID);

  Future<void> editUpdate(String description, String prayerID) async =>
      await _prayerService.editUpdate(description, prayerID);

  Future<void> archivePrayer(String userPrayerId) async =>
      await _prayerService.archivePrayer(userPrayerId);

  Future<void> unArchivePrayer(String userPrayerId, String prayerID) async =>
      await _prayerService.unArchivePrayer(userPrayerId, prayerID);

  Future<void> snoozePrayer(String prayerID, DateTime snoozeEndDate,
      String userPrayerID, int duration, String frequency) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _prayerService.snoozePrayer(
        snoozeEndDate, userPrayerID, duration, frequency);
  }

  Future<void> unSnoozePrayer(
          String prayerID, DateTime snoozeEndDate, String userPrayerID) async =>
      await _prayerService.unSnoozePrayer(snoozeEndDate, userPrayerID);

  Future<void> _autoDeleteArchivePrayers(
      String userId,
      List<CombinePrayerStream> data,
      List<LocalNotificationModel> notifications) async {
    if (_firebaseAuth.currentUser == null) return null;
    final settings = await locator<SettingsService>().getSettings(userId);
    final autoDeleteAnswered = settings.includeAnsweredPrayerAutoDelete;
    final autoDeleteDuration = settings.archiveAutoDeleteMins;
    if (autoDeleteDuration > 0) {
      final archivedPrayers = data
          .where(
              (CombinePrayerStream data) => data.userPrayer.isArchived == true)
          .toList();
      List<CombinePrayerStream> toDelete = archivedPrayers;
      if (!autoDeleteAnswered) {
        toDelete = toDelete
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
          final _notifications = notifications
              .where((e) => e.entityId == toDelete[i].userPrayer.id)
              .toList();

          _notifications.forEach((e) async {
            final notification = _notifications.firstWhere((e) => e.id == e.id);
            await LocalNotification.unschedule(
                notification.localNotificationId);
            await locator<NotificationService>().removeLocalNotification(e.id);
          });
          deletePrayer(toDelete[i].userPrayer.id);
        }
      }
    }
  }

  Future<void> favoritePrayer(String prayerID) async =>
      await _prayerService.favoritePrayer(prayerID);

  Future<void> unfavoritePrayer(String prayerID) async =>
      await _prayerService.unFavoritePrayer(prayerID);

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

  Future<void> deletePrayer(String userPrayeId) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _prayerService.deletePrayer(userPrayeId);
  }

  Future<void> deleteUpdate(String prayerId) async {
    if (_firebaseAuth.currentUser == null) return null;
    await _prayerService.deleteUpdate(prayerId);
  }

  Future<void> setCurrentPrayerType(PrayerType type) async {
    if (_firebaseAuth.currentUser == null) return null;
    _currentPrayerType = type;
    notifyListeners();
  }

  void setEditMode(bool value) {
    _isEdit = value;
    notifyListeners();
  }

  void setEditPrayer(CombinePrayerStream data) {
    _prayerToEdit = data;
    notifyListeners();
  }
}
