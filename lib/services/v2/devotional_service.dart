import 'package:be_still/models/v2/bible.model.dart';
import 'package:be_still/models/v2/devotional.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DevotionalServiceV2 {
  final CollectionReference<Map<String, dynamic>> _bibleCollectionReference =
      FirebaseFirestore.instance.collection("Bible");
  final CollectionReference<Map<String, dynamic>>
      _devotionalCollectionReference =
      FirebaseFirestore.instance.collection("DevotionalAndPlan");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<List<BibleDataModel>> getBibles() {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      final bibles = _bibleCollectionReference.get();
      return bibles.then(
          (e) => e.docs.map((e) => BibleDataModel.fromJson(e.data())).toList());
    } catch (err) {
      throw HttpException(StringUtils.getErrorMessage(err));
    }
  }

  Future<List<DevotionalDataModel>> getDevotionals() {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      var devotionals = _devotionalCollectionReference.get();
      return devotionals.then((e) =>
          e.docs.map((e) => DevotionalDataModel.fromJson(e.data())).toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }
}
