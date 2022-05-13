import 'package:be_still/models/error_log.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class LogService {
  final CollectionReference<Map<String, dynamic>> _errorLogCollectionReference =
      FirebaseFirestore.instance.collection("ErrorLog");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future createLog(String message, String userId, String location) async {
    final _logId = Uuid().v1();
    try {
      if (_firebaseAuth.currentUser == null) return null;
      _errorLogCollectionReference.doc(_logId).set(ErrorLog(
              location: location,
              id: _logId,
              message: message,
              createdBy: userId,
              modifiedBy: userId,
              createdOn: DateTime.now(),
              modifiedOn: DateTime.now())
          .toJson());
    } catch (e) {
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }
}
