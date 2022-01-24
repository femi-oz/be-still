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

  List<HiddenPrayerModel> _hiddenPrayers = [];
  List<FollowedPrayerModel> _followedPrayers = [];
  List<FollowedPrayerModel> _memberPrayers = [];
  List<FollowedPrayerModel> _groupFollowedPrayers = [];

  List<CombineGroupPrayerStream> get prayers => _prayers;
  List<CombineGroupPrayerStream> get filteredPrayers => _filteredPrayers;

  Iterable<Contact> get localContacts => _localContacts;
  List<HiddenPrayerModel> get hiddenPrayers => _hiddenPrayers;
  List<FollowedPrayerModel> get followedPrayers => _followedPrayers;
  List<FollowedPrayerModel> get memberPrayers => _memberPrayers;
  List<FollowedPrayerModel> get groupFollowedPrayers => _groupFollowedPrayers;

  bool _isEdit = false;
  bool get isEdit => _isEdit;

  String _newPrayerId = '';
  String get newPrayerId => _newPrayerId;

  CombineGroupPrayerStream _prayerToEdit =
      CombineGroupPrayerStream.defaultValue();
  CombineGroupPrayerStream get prayerToEdit => _prayerToEdit;

  String _filterOption = Status.active;
  String get filterOption => _filterOption;

  Future<void> setGroupPrayers(String groupId) async {
    try {
      _filteredPrayers = [];
      _prayerService.getPrayers(groupId).asBroadcastStream().listen(
        (data) {
          _prayers = data;

          _filteredPrayers = _prayers;
          filterPrayers();
          notifyListeners();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  String _currentPrayerId = '';
  String get currentPrayerId => _currentPrayerId;

  void setCurrentPrayerId(String prayerId) => _currentPrayerId = prayerId;

  Stream<CombineGroupPrayerStream> getPrayer() {
    try {
      return _prayerService.getPrayer(_currentPrayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setHiddenPrayer(String id) async {
    try {
      _prayerService.getHiddenPrayers(id).asBroadcastStream().listen((prayer) {
        _hiddenPrayers = prayer;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> setFollowedPrayer(String id) async {
  //   try {
  //     _prayerService.getFollowedPrayers(id).then((prayer) {
  //       _followedPrayers = prayer;
  //       notifyListeners();
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<void> setFollowedPrayerByGroupId(String id) async {
  //   try {
  //     _prayerService.getFollowedPrayersByGroupId(id).then((prayer) {
  //       _groupFollowedPrayers = prayer;
  //       notifyListeners();
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> setFollowedPrayerByUserId(String? id) async {
    try {
      _prayerService
          .getFollowedPrayersByUserId(id ?? '')
          .asBroadcastStream()
          .listen((prayer) {
        _followedPrayers = prayer;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FollowedPrayerModel>> setFollowedPrayers(String? prayerId) async {
    try {
      return _prayerService.getFollowedPrayers(prayerId ?? '');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrayer(
    String prayerDesc,
    String groupId,
    String creatorName,
    String prayerDescBackup,
    String userId,
  ) async {
    try {
      await _prayerService
          .addPrayer(prayerDesc, groupId, creatorName, prayerDescBackup, userId)
          .then((value) => _newPrayerId = value);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> messageRequestor(
      PrayerRequestMessageModel prayerRequestData) async {
    try {
      await _prayerService.messageRequestor(prayerRequestData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPrayerWithGroups(BuildContext context, PrayerModel prayerData,
      List groups, String _userID) async {
    try {
      await _prayerService.addPrayerWithGroup(
          context, prayerData, groups, _userID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> hidePrayer(String prayerId, UserModel user) async {
    try {
      await _prayerService.hidePrayer(prayerId, user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> hidePrayerFromAllMembers(String prayerId, bool value) async {
    try {
      await _prayerService.hideFromAllMembers(prayerId, value);
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

  Future<void> archivePrayer(String groupPrayerId, String prayerId) async {
    try {
      await _prayerService.archivePrayer(groupPrayerId, prayerId);
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

  Future<void> unSnoozePrayer(
      String prayerID, DateTime snoozeEndDate, String userPrayerID) async {
    try {
      await _prayerService.unSnoozePrayer(snoozeEndDate, userPrayerID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markPrayerAsAnswered(
    String prayerId,
    String groupPrayerId,
  ) async {
    try {
      await _prayerService.markPrayerAsAnswered(prayerId, groupPrayerId);
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

  Future<void> deletePrayer(String userPrayeId, String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      await _prayerService.deletePrayer(userPrayeId, prayerId);
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

  // Future<void> editUpdate(String description, String prayerID) async {
  //   try {
  //     await _prayerService.editUpdate(description, prayerID);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> addPrayerTag(List<Contact> contactData, UserModel user,
      String message, String prayerId) async {
    try {
      await _prayerService.addPrayerTag(contactData, user, message, prayerId);
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> editprayer(String description, String prayerID) async {
  //   try {
  //     await _prayerService.editPrayer(description, prayerID);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> removePrayerTag(String tagId) async {
    try {
      await _prayerService.removePrayerTag(tagId);
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
        List<CombineGroupPrayerStream> filteredPrayers = _filteredPrayers
            .where((CombineGroupPrayerStream data) =>
                (data.prayer?.description ?? '')
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList();
        for (int i = 0; i < _filteredPrayers.length; i++) {
          var hasMatch = (_filteredPrayers[i].updates ?? []).any((u) =>
              (u.description ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()));
          if (hasMatch) filteredPrayers.add(_filteredPrayers[i]);
        }
        _filteredPrayers = filteredPrayers;
        _filteredPrayers.sort((a, b) => (b.prayer?.modifiedOn ?? DateTime.now())
            .compareTo((a.prayer?.modifiedOn ?? DateTime.now())));
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> addPrayerUpdate(
  //     String userId, String prayer, String prayerId) async {
  //   try {
  //     await _prayerService.addPrayerUpdate(userId, prayer, prayerId);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // void setEditMode(bool value) {
  //   try {
  //     _isEdit = value;
  //     notifyListeners();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // void setEditPrayer({CombineGroupPrayerStream? data}) {
  //   try {
  //     _prayerToEdit = data ?? CombineGroupPrayerStream.defaultValue();
  //     notifyListeners();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

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
      List<CombineGroupPrayerStream> prayers = _prayers.toList();
      List<CombineGroupPrayerStream> activePrayers = [];
      List<CombineGroupPrayerStream> answeredPrayers = [];
      List<CombineGroupPrayerStream> snoozedPrayers = [];
      List<CombineGroupPrayerStream> favoritePrayers = [];
      List<CombineGroupPrayerStream> archivedPrayers = [];
      List<CombineGroupPrayerStream> allPrayers = [];
      if (_filterOption == Status.all) {
        favoritePrayers = prayers
            .where((CombineGroupPrayerStream data) =>
                (data.groupPrayer?.isFavorite ?? false))
            .toList();
        allPrayers = prayers;
      }
      if (_filterOption == Status.active) {
        favoritePrayers = prayers
            .where((CombineGroupPrayerStream data) =>
                (data.groupPrayer?.isFavorite ?? false))
            .toList();
        activePrayers = prayers
            .where((CombineGroupPrayerStream data) =>
                (data.groupPrayer?.status ?? '').toLowerCase() ==
                Status.active.toLowerCase())
            .toList();
      }
      if (_filterOption == Status.answered) {
        answeredPrayers = prayers
            .where((CombineGroupPrayerStream data) =>
                (data.prayer?.isAnswer ?? false) == true)
            .toList();
      }
      if (_filterOption == Status.archived) {
        archivedPrayers = prayers
            .where((CombineGroupPrayerStream data) =>
                (data.groupPrayer?.isArchived ?? false) == true)
            .toList();
      }
      if (_filterOption == Status.following) {
        archivedPrayers = prayers
            .where((CombineGroupPrayerStream data) =>
                (data.prayer?.isGroup ?? false) == true)
            .toList();
      }
      if (_filterOption == Status.snoozed) {
        snoozedPrayers = prayers
            .where((CombineGroupPrayerStream data) =>
                (data.groupPrayer?.isSnoozed ?? false) == true &&
                (data.groupPrayer?.snoozeEndDate ?? DateTime.now())
                    .isAfter(DateTime.now()))
            .toList();
      }
      _filteredPrayers = [
        ...allPrayers,
        ...activePrayers,
        ...archivedPrayers,
        ...snoozedPrayers,
        ...answeredPrayers
      ];
      _filteredPrayers.sort((a, b) => (b.prayer?.modifiedOn ?? DateTime.now())
          .compareTo((a.prayer?.modifiedOn ?? DateTime.now())));
      _filteredPrayers = [...favoritePrayers, ..._filteredPrayers];
      List<CombineGroupPrayerStream> _distinct = [];
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

  Future<void> flagAsInappropriate(String prayerId) async {
    try {
      await _prayerService.flagAsInappropriate(prayerId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToMyList(String prayerId, String userId, String groupId,
      bool isFollowedByAdmin) async {
    try {
      await _prayerService.addToMyList(
          prayerId, userId, groupId, isFollowedByAdmin);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromMyList(
      String followedPrayerId, String userPrayerId) async {
    try {
      await _prayerService.removeFromMyList(followedPrayerId, userPrayerId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
