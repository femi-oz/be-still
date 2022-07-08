// import 'dart:async';

// import 'package:be_still/locator.dart';
// import 'package:be_still/models/bible.model.dart';
// import 'package:be_still/models/devotionals.model.dart';
// import 'package:be_still/services/devotional_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';

// class DevotionalProvider with ChangeNotifier {
//   DevotionalService _devotionalService = locator<DevotionalService>();
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   List<BibleModel> _bibles = [];
//   List<DevotionalModel> _devotionals = [];
//   List<BibleModel> get bibles => _bibles;
//   List<DevotionalModel> get devotionals => _devotionals;
//   late StreamSubscription<List<DevotionalModel>> devotionalStream;

//   Future<void> getBibles() async {
//     try {
//       if (_firebaseAuth.currentUser == null) return null;
//       _devotionalService.getBibles().asBroadcastStream().listen((bibles) {
//         bibles.sort((a, b) => (a.name ?? '').compareTo((b.name ?? '')));
//         _bibles = bibles;
//         notifyListeners();
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> getDevotionals() async {
//     try {
//       if (_firebaseAuth.currentUser == null) return null;
//       devotionalStream = _devotionalService
//           .getDevotionals()
//           .asBroadcastStream()
//           .listen((devotionals) {
//         _devotionals = devotionals;
//         notifyListeners();
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }

//   void flush() async {
//     devotionalStream.cancel();
//   }
// }
