import 'package:be_still/models/models/bible.model.dart';
import 'package:be_still/models/models/devotional.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DevotionalService {
  final CollectionReference<Map<String, dynamic>> _bibleCollectionReference =
      FirebaseFirestore.instance.collection("Bible");
  final CollectionReference<Map<String, dynamic>>
      _devotionalCollectionReference =
      FirebaseFirestore.instance.collection("DevotionalAndPlan");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<List<BibleDataModel>> getBibles() {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      final bibles = _bibleCollectionReference.snapshots();
      return bibles.map(
          (e) => e.docs.map((e) => BibleDataModel.fromJson(e.data())).toList());
    } catch (err) {
      throw HttpException(StringUtils.getErrorMessage(err));
    }
  }

  Stream<List<DevotionalDataModel>> getDevotionals() {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      var devotionals = _devotionalCollectionReference.snapshots();
      return devotionals.map((e) =>
          e.docs.map((e) => DevotionalDataModel.fromJson(e.data())).toList());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }
}
