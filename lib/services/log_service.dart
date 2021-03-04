import 'package:be_still/models/error_log.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class LogService {
  final CollectionReference _errorLogCollectionReference =
      FirebaseFirestore.instance.collection("ErrorLog");
  Future createLog(String message, String userId, String location) async {
    final _logId = Uuid().v1();
    try {
      _errorLogCollectionReference.doc(_logId).set(ErrorLog(
              location: location,
              message: message,
              createdBy: userId,
              modifiedBy: userId,
              createdOn: DateTime.now(),
              modifiedOn: DateTime.now())
          .toJson());
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
