import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final CollectionReference _notificationCollectionReference =
      FirebaseFirestore.instance.collection("MobileNotification");
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    try {
      return _notificationCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((e) =>
              e.docs.map((doc) => NotificationModel.fromData(doc)).toList());
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
