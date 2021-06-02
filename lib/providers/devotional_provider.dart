import 'package:be_still/locator.dart';
import 'package:be_still/models/bible.model.dart';
import 'package:be_still/models/devotionals.model.dart';
import 'package:be_still/services/devotional_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class DevotionalProvider with ChangeNotifier {
  DevotionalService _devotionalService = locator<DevotionalService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<BibleModel> _bibles = [];
  List<DevotionalModel> _devotionals = [];
  List<BibleModel> get bibles => _bibles;
  List<DevotionalModel> get devotionals => _devotionals;
  Future<void> getBibles() async {
    if (_firebaseAuth.currentUser == null) return null;
    _devotionalService.getBibles().asBroadcastStream().listen((bibles) {
      bibles.sort((a, b) => a.name.compareTo(b.name));
      _bibles = bibles;
      notifyListeners();
    });
  }

  Future<void> getDevotionals() async {
    if (_firebaseAuth.currentUser == null) return null;
    _devotionalService
        .getDevotionals()
        .asBroadcastStream()
        .listen((devotionals) {
      _devotionals = devotionals;
      notifyListeners();
    });
  }
}
