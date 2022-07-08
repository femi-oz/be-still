import 'dart:async';

import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/device.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/group.provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/services/v2/user_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UserProviderV2 with ChangeNotifier {
  UserServiceV2 _userService = locator<UserServiceV2>();

  UserDataModel _currentUser = UserDataModel();
  UserDataModel get currentUser => _currentUser;

  UserDataModel _selectedUser = UserDataModel();
  UserDataModel get selectedUser => _selectedUser;

  List<UserDataModel> _allUsers = <UserDataModel>[];
  List<UserDataModel> get allUsers => _allUsers;

  late StreamSubscription<List<UserDataModel>> usersStream;
  late StreamSubscription<UserDataModel> userStream;

  Future<void> setCurrentUser() async {
    try {
      final _firebaseUserId = FirebaseAuth.instance.currentUser?.uid;
      userStream = _userService
          .getUserById(_firebaseUserId ?? '')
          .asBroadcastStream()
          .listen((event) async {
        _currentUser = event;
        if (_currentUser.email != FirebaseAuth.instance.currentUser?.email) {
          await _userService.revertEmail();
        }
        await Provider.of<PrayerProviderV2>(Get.context!, listen: false)
            .checkPrayerValidity();
        await Provider.of<PrayerProviderV2>(Get.context!, listen: false)
            .setPrayers();
        // (event.prayers ?? []).map((e) => e.prayerId ?? '').toList()
        await Provider.of<GroupProviderV2>(Get.context!, listen: false)
            .setUserGroups(event.groups ?? <String>[]);

        // await Provider.of<GroupProviderV2>(Get.context!, listen: false)
        //     .onGroupChanges(event.groups ?? <String>[]);

        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<UserDataModel> getUserDataById(String userId) async {
    try {
      return _userService.getUserByIdFuture(userId).then((user) async {
        _selectedUser = user;
        notifyListeners();
        return user;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> returnUserToken(String userId) async {
    try {
      return await _userService.getUserByIdFuture(userId).then((value) {
        return (value.devices ?? []).map((e) => e.token ?? '').toList();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setAllUsers() async {
    try {
      final _firebaseUserId = FirebaseAuth.instance.currentUser?.uid;

      usersStream =
          _userService.getAllUsers().asBroadcastStream().listen((users) async {
        _allUsers = users.where((e) => e.id != _firebaseUserId).toList();
        await Provider.of<GroupProviderV2>(Get.context!, listen: false)
            .setAllGroups();
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  String getPrayerCreatorName(String userId) {
    final _firebaseUserId = FirebaseAuth.instance.currentUser?.uid;

    final user = userId == _firebaseUserId
        ? currentUser
        : _allUsers.firstWhere((element) => element.id == userId,
            orElse: () => UserDataModel());
    final userName = (user.firstName ?? '') + ' ' + (user.lastName ?? '');
    return userName;
  }

  Future<void> updateEmail(String newEmail, String userId) async {
    try {
      await _userService.updateEmail(newEmail: newEmail);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserSettings(String key, dynamic value) async {
    try {
      await _userService.updateUserSettings(key: key, value: value);
      // await setCurrentUser();
      // if (key == 'archiveAutoDeleteMinutes') {
      //   setAutoDelete(value);
      // }
    } catch (e) {
      rethrow;
    }
  }

  // late Timer autoDeleteTimer;
  // //on app load, set a time with value of autoDeleteDate
  // //on update of autoDelete date, cancel and set new timer
  // //when timer ends, call autoDelete method
  // Future<void> setAutoDeleteTimer(int value) async {
  //   try {
  //     autoDeleteTimer = Timer.periodic(Duration(minutes: value), (timer) async {
  //       if (value == 0) {
  //         timer.cancel();
  //       } else {
  //         await _prayerService.autoDeleteArchivePrayers(
  //             value, currentUser.includeAnsweredPrayerAutoDelete ?? false);
  //       }
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<void> cancelAutoDeleteTimer() async {
  //   autoDeleteTimer.cancel();
  // }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _userService.updatePassword(newPassword);
      //await setCurrentUser(false);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePushToken(List<DeviceModel> devices) async {
    try {
      await _userService.deletePushToken(devices);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPushToken(List<DeviceModel> userDevices) async {
    try {
      await _userService.addPushToken(userDevices);
    } catch (e) {
      rethrow;
    }
  }

  Future flush() async {
    _currentUser = UserDataModel();
    _selectedUser = UserDataModel();
    _allUsers = [];
    await userStream.cancel();
    await usersStream.cancel();
    notifyListeners();
  }
}
