import 'dart:async';

import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/followed_prayer.model.dart';
import 'package:be_still/models/v2/follower.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/tag.model.dart';
import 'package:be_still/models/v2/update.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/services/v2/notification_service.dart';
import 'package:be_still/services/v2/prayer_service.dart';
import 'package:be_still/services/v2/user_service.dart';
import 'package:be_still/utils/settings.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'notification_provider.dart';

class PrayerProviderV2 with ChangeNotifier {
  PrayerServiceV2 _prayerService = locator<PrayerServiceV2>();
  UserServiceV2 _userService = locator<UserServiceV2>();
  NotificationServiceV2 _notificationService = locator<NotificationServiceV2>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late StreamSubscription<List<PrayerDataModel>> prayerStream;
  late StreamSubscription<List<PrayerDataModel>> groupPrayerStream;

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

  PrayerDataModel _prayer = PrayerDataModel();
  PrayerDataModel get prayer => _prayer;

  String _filterOption = Status.active;
  String get filterOption => _filterOption;

  String _groupFilterOption = Status.active;
  String get groupFilterOption => _groupFilterOption;

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

  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> setPrayers() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;

      prayerStream = _prayerService
          .getUserPrayers()
          .asBroadcastStream()
          .listen((event) async {
        final user = await _userService
            .getUserByIdFuture(_firebaseAuth.currentUser?.uid ?? '');
        List<String> newPrayerIds =
            (user.prayers ?? []).map((e) => e.prayerId ?? '').toList();
        _prayers = event;
        _followedPrayers =
            await _prayerService.getUserFollowedPrayers(newPrayerIds);
        _prayers = [...prayers, ...followedPrayers];

        Provider.of<MiscProviderV2>(Get.context!, listen: false)
            .setLoadStatus(false);

        filterPrayers();
        // notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeOldReminders() async {
    try {
      final localNotifications =
          await _notificationService.getLocalNotificationsFuture();

      final pendingLocalNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      final notificationsToRemove = pendingLocalNotifications
          .where((element) => !localNotifications
              .map((e) => e.localNotificationId)
              .toList()
              .contains(element.id))
          .toList()
          .map((e) => e.id)
          .toList();
      notificationsToRemove.forEach((id) {
        _flutterLocalNotificationsPlugin.cancel(id);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setGroupPrayers() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      final groupId = Provider.of<GroupProviderV2>(Get.context!, listen: false)
              .currentGroup
              .id ??
          '';
      groupPrayerStream = _prayerService
          .getGroupPrayers(groupId)
          .asBroadcastStream()
          .listen((event) {
        print(groupId);
        _groupPrayers = event;
        filterGroupPrayers();
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  closeGroupPrayers() {
    groupPrayerStream.cancel();
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

  Future<void> checkPrayerValidity() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      // await _autoDeleteArchivePrayers();
      await _unSnoozePrayerPast();
      await removeOldReminders();
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
        // filterPrayers();

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

  Future<void> getPrayer({required String prayerId}) async {
    try {
      _prayerService.getPrayer(prayerId).asBroadcastStream().listen((prayer) {
        _prayer = prayer;
        notifyListeners();
      });
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

  void setGroupPrayerFilterOptions(String option) {
    try {
      _groupFilterOption = option;
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

  Future<void> autoDeleteArchivePrayers(
      int value, bool includeAnsweredPrayerAutoDelete) async {
    try {
      await _prayerService.autoDeleteArchivePrayers(
          value, includeAnsweredPrayerAutoDelete);
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

  Future<void> archivePrayer(String prayerId, List<FollowerModel> followers,
      String type, String groupId, String description) async {
    try {
      await _prayerService.archivePrayer(
        prayerId: prayerId,
        followers: followers,
        type: type,
        groupId: groupId,
        description: description,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unArchivePrayer(
      String prayerId, List<FollowerModel> followers, bool isAdmin) async {
    try {
      await _prayerService.unArchivePrayer(
          currentFollowers: followers, isAdmin: isAdmin, prayerId: prayerId);
      notifyListeners();
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
        await setPrayers();
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

  Future<void> _unSnoozePrayerPast() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _prayerService.autoUnSnoozePrayers();
    } catch (e) {
      rethrow;
    }
  }

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

  Future<void> markPrayerAsAnswered(
    String prayerId,
    List<FollowerModel> followers,
    String type,
    String groupId,
    String message,
  ) async {
    try {
      await _prayerService.markPrayerAsAnswered(
        prayerId: prayerId,
        followers: followers,
        message: message,
        type: type,
        groupId: groupId,
        tokens: [],
      );
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

  Future<void> deletePrayer(
      String prayerId, String groupId, List<FollowerModel> followers) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _prayerService.deletePrayer(
          groupId: groupId, prayerId: prayerId, followers: followers);

      final notifications =
          await Provider.of<NotificationProviderV2>(Get.context!, listen: false)
              .getLocalNotificationsByPrayerId(prayerId);

      for (var e in notifications) {
        await Provider.of<NotificationProviderV2>(Get.context!, listen: false)
            .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0);
      }
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

    if (_groupFilterOption == Status.all) {
      allGroupPrayers = groupPrayers;
    }

    if (_groupFilterOption == Status.active) {
      activeGroupPrayers = groupPrayers
          .where((PrayerDataModel data) =>
              (data.status ?? '').toLowerCase() == Status.active.toLowerCase())
          .toList();
    }

    if (_groupFilterOption == Status.answered) {
      answeredGroupPrayers = groupPrayers
          .where((PrayerDataModel data) =>
              (data.status == Status.archived) &&
              (data.isAnswered ?? false) == true)
          .toList();
    }

    if (_groupFilterOption == Status.archived) {
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

    _filteredGroupPrayers.sort((a, b) => (b.createdDate ?? DateTime.now())
        .compareTo(a.createdDate ?? DateTime.now()));

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

  Future<void> updatePrayerAutoDelete(bool isInit) async {
    _prayerService.updatePrayerAutoDelete(isInit);
  }

  Future<void> updateAnsweredPrayerAutoDelete() async {
    _prayerService.updateAnsweredPrayerAutoDelete();
  }

  void filterPrayers() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      List<PrayerDataModel> prayers = _prayers.toList();
      List<PrayerDataModel> activePrayers = [];
      List<PrayerDataModel> answeredPrayers = [];
      List<PrayerDataModel> snoozedPrayers = [];
      List<PrayerDataModel> archivedPrayers = [];
      List<PrayerDataModel> followingPrayers = [];
      List<PrayerDataModel> allPrayers = [];
      List<PrayerDataModel> archivePrayersWithDelete = [];
      List<PrayerDataModel> archivePrayersWithoutDelete = [];

      final user = await _userService
          .getUserByIdFuture(_firebaseAuth.currentUser?.uid ?? '');
      if (_filterOption == Status.all) {
        allPrayers = prayers
            .where((PrayerDataModel data) =>
                data.autoDeleteDate == null ||
                (data.autoDeleteDate ?? DateTime.now()).isAfter(DateTime.now()))
            .toList();
      }

      if (_filterOption == Status.active) {
        activePrayers = prayers
            .where((PrayerDataModel data) =>
                (data.status ?? '').toLowerCase() ==
                Status.active.toLowerCase())
            .toList();
      }
      if (_filterOption == Status.answered) {
        if (user.includeAnsweredPrayerAutoDelete ?? false) {
          answeredPrayers = prayers
              .where((PrayerDataModel data) =>
                  (data.isAnswered ?? false) == true &&
                  (data.autoDeleteDate == null ||
                      (data.autoDeleteDate ?? DateTime.now())
                          .isAfter(DateTime.now())))
              .toList();
        } else {
          answeredPrayers = prayers
              .where((PrayerDataModel data) =>
                  (data.isAnswered ?? false) == true &&
                  data.autoDeleteAnsweredDate != null)
              .toList();
        }
      }
      if (_filterOption == Status.archived) {
        for (var prayer in prayers) {
          if (prayer.autoDeleteDate != null) {
            archivePrayersWithDelete = prayers
                .where((PrayerDataModel data) =>
                    data.status == Status.archived &&
                    (data.autoDeleteDate ?? DateTime.now())
                        .isAfter(DateTime.now()))
                .toList();
          }
        }
        archivePrayersWithoutDelete = prayers
            .where((PrayerDataModel data) =>
                data.status == Status.archived && data.autoDeleteDate == null)
            .toList();
        archivedPrayers = [
          ...archivePrayersWithDelete,
          ...archivePrayersWithoutDelete
        ];
      }
      if (_filterOption == Status.snoozed) {
        snoozedPrayers = prayers
            .where((PrayerDataModel data) => data.status == Status.snoozed)
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

      _filteredPrayers = [
        ..._filteredPrayers
            .where((element) => element.isFavorite ?? false)
            .toList(),
        ..._filteredPrayers
            .where((element) => !(element.isFavorite ?? false))
            .toList(),
      ];

      _filteredPrayers = distinctPrayers(_filteredPrayers);
      _filteredPrayerTimeList =
          prayers.where((element) => element.status == Status.active).toList();
      _filteredPrayerTimeList.sort((a, b) => (b.modifiedDate ?? DateTime.now())
          .compareTo(a.modifiedDate ?? DateTime.now()));
      _filteredPrayerTimeList = [
        ..._filteredPrayerTimeList
            .where((element) => element.isFavorite ?? false)
            .toList(),
        ..._filteredPrayerTimeList
            .where((element) => !(element.isFavorite ?? false))
            .toList(),
      ];
      _filteredPrayerTimeList =
          distinctPrayers(_filteredPrayerTimeList).toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  List<PrayerDataModel> distinctPrayers(List<PrayerDataModel> prayers) {
    List<PrayerDataModel> _distinct = [];
    var idSet = <String>{};
    for (var e in prayers) {
      if (idSet.add(e.id ?? '')) {
        _distinct.add(e);
      }
    }
    return _distinct;
  }

  Future<void> followPrayer(
      String prayerId, String groupId, List<String> prayersIds) async {
    await _prayerService.followPrayer(prayerId: prayerId, groupId: groupId);
  }

  Future<void> unFollowPrayer(
      String prayerId,
      String groupId,
      List<String> prayersIds,
      FollowedPrayer prayer,
      FollowerModel follower) async {
    await _prayerService.unFollowPrayer(
        prayerId: prayerId,
        groupId: groupId,
        follower: follower,
        prayer: prayer);
  }

  Future flush() async {
    _prayers = [];
    _userPrayers = [];
    _filteredPrayers = [];
    _groupPrayers = [];
    _filteredPrayerTimeList = [];

    if (prayers.isNotEmpty) {
      await prayerStream.cancel();
    }
    if (groupPrayers.isNotEmpty) {
      await groupPrayerStream.cancel();
    }
    notifyListeners();
  }
}
