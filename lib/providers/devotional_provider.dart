import 'package:be_still/locator.dart';
import 'package:be_still/models/bible.model.dart';
import 'package:be_still/models/devotionals.model.dart';
import 'package:be_still/services/devotional_service.dart';
import 'package:flutter/cupertino.dart';

class DevotionalProvider with ChangeNotifier {
  DevotionalService _devotionalService = locator<DevotionalService>();
  List<BibleModel> _bibles = [];
  List<DevotionalModel> _devotionals = [];
  List<BibleModel> get bibles => _bibles;
  List<DevotionalModel> get devotionals => _devotionals;
  Future getBibles() async {
    _devotionalService
        .getBibles()
        .asBroadcastStream()
        .listen((bibles) => _bibles = bibles);
    notifyListeners();
  }

  Future getDevotionals() async {
    _devotionalService
        .getDevotionals()
        .asBroadcastStream()
        .listen((devotionals) => _devotionals = devotionals);
    notifyListeners();
  }
}
