import 'dart:async';

import 'package:be_still/locator.dart';
import 'package:be_still/models/v2/bible.model.dart';
import 'package:be_still/models/v2/devotional.model.dart';
import 'package:be_still/services/v2/devotional_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class DevotionalProviderV2 with ChangeNotifier {
  DevotionalServiceV2 _devotionalService = locator<DevotionalServiceV2>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<BibleDataModel> _bibles = [];
  List<DevotionalDataModel> _devotionals = [];
  List<BibleDataModel> get bibles => _bibles;
  List<DevotionalDataModel> get devotionals => _devotionals;

  Future<void> getBibles() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _devotionalService.getBibles().then((bibles) {
        bibles.sort((a, b) => (a.name ?? '').compareTo((b.name ?? '')));
        _bibles = bibles;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getDevotionals() async {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _devotionalService.getDevotionals().then((devotionals) {
        _devotionals = devotionals;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }
}
