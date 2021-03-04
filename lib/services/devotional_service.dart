import 'package:be_still/locator.dart';
import 'package:be_still/models/bible.model.dart';
import 'package:be_still/models/devotionals.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/services/log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DevotionalService {
  final CollectionReference _bibleCollectionReference =
      FirebaseFirestore.instance.collection("Bible");
  final CollectionReference _devotionalCollectionReference =
      FirebaseFirestore.instance.collection("DevotionalAndPlan");
  Stream<List<BibleModel>> getBibles() {
    try {
      var bibles = _bibleCollectionReference.snapshots();
      return bibles
          .map((e) => e.docs.map((e) => BibleModel.fromData(e)).toList());
    } catch (e) {
      locator<LogService>()
          .createLog(e.message, 'bibles', 'DEVOTIONALS/service/getBibles');
      throw HttpException(e.message);
    }
  }

  Stream<List<DevotionalModel>> getDevotionals() {
    try {
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
