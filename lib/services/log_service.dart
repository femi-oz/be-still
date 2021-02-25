import 'package:be_still/models/error_log.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogService {
  final CollectionReference _errorLogCollectionReference =
      FirebaseFirestore.instance.collection("ErrorLog");
  Future createLog(String code, String message, String userId) async {
    await _errorLogCollectionReference.doc().set(ErrorLog(
            code: code,
            message: message,
            createdBy: userId,
            modifiedBy: userId,
            createdOn: DateTime.now(),
            modifiedOn: DateTime.now())
        .toJson());
  }
}
