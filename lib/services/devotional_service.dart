import 'package:be_still/locator.dart';
import 'package:be_still/models/bible.model.dart';
import 'package:be_still/models/devotionals.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DevotionalService {
  final CollectionReference<Map<String, dynamic>> _bibleCollectionReference =
      FirebaseFirestore.instance.collection("Bible");
  final CollectionReference<Map<String, dynamic>>
      _devotionalCollectionReference =
      FirebaseFirestore.instance.collection("DevotionalAndPlan");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Stream<List<BibleModel>> getBibles() {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var bibles = _bibleCollectionReference.snapshots();
      return bibles
          .map((e) => e.docs.map((e) => BibleModel.fromData(e)).toList());
    } catch (e) {
      locator<LogService>().createLog(
          e.message != null ? e.message : e.toString(),
          'bibles',
          'DEVOTIONALS/service/getBibles');
      throw HttpException(e.message);
    }
  }

  Stream<List<DevotionalModel>> getDevotionals() {
    try {
      if (_firebaseAuth.currentUser == null) return null;
      var devotionals = _devotionalCollectionReference.snapshots();
      return devotionals
          .map((e) => e.docs.map((e) => DevotionalModel.fromData(e)).toList());
    } catch (e) {
      locator<LogService>().createLog(
          e.message, 'devotionals', 'DEVOTIONALS/service/getDevotionals');
      throw HttpException(e.message);
    }
  }
}
