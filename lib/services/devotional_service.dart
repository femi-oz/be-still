import 'package:be_still/models/bible.model.dart';
import 'package:be_still/models/devotionals.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DevotionalService {
  final CollectionReference _bibleCollectionReference =
      FirebaseFirestore.instance.collection("Bible");
  final CollectionReference _devotionalCollectionReference =
      FirebaseFirestore.instance.collection("DevotionalAndPlan");
  Stream<List<BibleModel>> getBibles() {
    var bibles = _bibleCollectionReference.snapshots();
    return bibles
        .map((e) => e.docs.map((e) => BibleModel.fromData(e)).toList());
  }

  Stream<List<DevotionalModel>> getDevotionals() {
    var devotionals = _devotionalCollectionReference.snapshots();
    return devotionals
        .map((e) => e.docs.map((e) => DevotionalModel.fromData(e)).toList());
  }
}
