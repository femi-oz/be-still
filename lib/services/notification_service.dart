import 'package:be_still/enums/status.dart';
import 'package:be_still/flavor_config.dart';
import 'package:be_still/locator.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/message_template.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/services/log_service.dart';
import 'package:be_still/services/user_service.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  final CollectionReference<Map<String, dynamic>>
      _localNotificationCollectionReference =
      FirebaseFirestore.instance.collection("LocalNotification");
  final CollectionReference<Map<String, dynamic>>
      _pushNotificationCollectionReference =
      FirebaseFirestore.instance.collection("PushNotification");
  final CollectionReference<Map<String, dynamic>> _smsCollectionReference =
      FirebaseFirestore.instance.collection("SMSMessage");
  final CollectionReference<Map<String, dynamic>> _emailCollectionReference =
      FirebaseFirestore.instance.collection("MailMessage");
  final CollectionReference<Map<String, dynamic>>
      _prayerTimeCollectionReference =
      FirebaseFirestore.instance.collection("PrayerTime");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserService userService = locator<UserService>();

  init(String token, String userId, UserModel currentUser) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      userService.addUserToken(token: token, userId: userId, user: currentUser);
    } catch (e) {
      locator<LogService>().createLog(
          StringUtils.getErrorMessage(e), userId, 'NOTIFICATION/service/init');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  disablePushNotifications(String userId, UserModel currentUser) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      userService.addUserToken(token: '', userId: userId, user: currentUser);
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'NOTIFICATION/service/getNotificationToken');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  enablePushNotification(
      String token, String userId, UserModel currentUser) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      userService.addUserToken(token: token, userId: userId, user: currentUser);
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'NOTIFICATION/service/getNotificationToken');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  sendPushNotification({
    required String message,
    required String messageType,
    required String sender,
    required String senderId,
    required String recieverId,
    required String title,
    required List<String> tokens,
    required String prayerId,
    required String groupId,
  }) async {
    final _notificationId = Uuid().v1();
    // var tokens = await getNotificationToken(recieverId);

    var data = PushNotificationModel(
      id: _notificationId,
      messageType: messageType,
      message: message,
      sender: sender,
      title: title,
      tokens: tokens,
      createdBy: senderId,
      createdOn: DateTime.now(),
      modifiedBy: senderId,
      modifiedOn: DateTime.now(),
      isSent: 0,
      recieverId: recieverId,
      status: Status.active,
      prayerId: prayerId,
      groupId: groupId,
    );
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _pushNotificationCollectionReference
          .doc(_notificationId)
          .set(data.toJson());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), senderId,
          'NOTIFICATION/service/addPushNotification');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  addSMS({
    String? senderId,
    String? message,
    String? sender,
    String? phoneNumber,
    String? title,
    MessageTemplate? template,
    String? receiver,
  }) async {
    final _smsId = Uuid().v1();
    var _templateBody = template?.templateBody ?? '';
    _templateBody = (_templateBody).replaceAll('{Sender}', sender ?? '');
    _templateBody = _templateBody.replaceAll("{Receiver}", receiver ?? '');
    _templateBody = _templateBody.replaceAll('{message}', message ?? '');
    _templateBody = _templateBody.replaceAll('<br/>', "\n");
    _templateBody =
        _templateBody.replaceAll("{Link}", 'https://www.bestillapp.com/');
    var data = MessageModel(
        id: _smsId,
        email: '',
        phoneNumber: phoneNumber,
        isSent: 0,
        senderId: senderId,
        title: title,
        message: _templateBody,
        sender: sender,
        createdBy: senderId,
        createdOn: DateTime.now(),
        modifiedBy: senderId,
        modifiedOn: DateTime.now(),
        receiver: receiver,
        subject: '',
        country: FlavorConfig.instance.values.country);
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _smsCollectionReference.doc(_smsId).set(data.toJson());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          senderId ?? '', 'NOTIFICATION/service/addSMS');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  addEmail({
    String? senderId,
    String? message,
    String? sender,
    String? email,
    String? title,
    String? receiver,
    MessageTemplate? template,
  }) async {
    final _emailId = Uuid().v1();
    var templateSubject = template?.templateSubject ?? '';
    var templateBody = template?.templateBody;
    templateSubject = (templateSubject).replaceAll("{Sender}", sender ?? '');
    templateBody = templateBody ?? ''.replaceAll("{Receiver}", receiver ?? '');
    templateBody = templateBody.replaceAll("{Sender}", sender ?? '');
    templateBody = templateBody.replaceAll("{message}", message ?? '');
    templateBody = templateBody.replaceAll(
        "{Link}", "<a href='https://www.bestillapp.com/'>Learn more.</a>");

    var data = MessageModel(
        id: _emailId,
        email: email,
        phoneNumber: '',
        isSent: 0,
        senderId: senderId,
        title: title,
        message: templateBody,
        sender: sender,
        createdBy: senderId,
        createdOn: DateTime.now(),
        modifiedBy: senderId,
        modifiedOn: DateTime.now(),
        receiver: receiver,
        subject: templateSubject,
        country: '');
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _emailCollectionReference.doc(_emailId).set(data.toJson());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          senderId ?? '', 'NOTIFICATION/service/addEmail');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  addLocalNotification(
    int localId,
    String entityId,
    String notificationText,
    String userId,
    String payload,
    String title,
    String description,
    String frequency,
    String type,
    DateTime scheduledDate,
    String selectedDay,
    String period,
    String selectedHour,
    String selectedMinute,
    String selectedYear,
    String selectedMonth,
    String selectedDayOfMonth,
  ) async {
    final _notificationId = Uuid().v1();
    String deviceId = '';
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _localNotificationCollectionReference.doc(_notificationId).set(
            LocalNotificationModel(
              id: _notificationId,
              type: type,
              description: description,
              frequency: frequency,
              scheduledDate: scheduledDate,
              title: title,
              payload: payload,
              userId: userId,
              localNotificationId: localId,
              entityId: entityId,
              notificationText: notificationText,
              selectedDay: selectedDay,
              selectedHour: selectedHour,
              selectedMinute: selectedMinute,
              period: period,
              selectedYear: selectedYear,
              selectedMonth: selectedMonth,
              selectedDayOfMonth: selectedDayOfMonth,
            ).toJson(),
          );
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), deviceId,
          'NOTIFICATION/service/addLocalNotification');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  updateLocalNotification(
    String frequency,
    DateTime scheduledDate,
    String selectedDay,
    String period,
    String selectedHour,
    String selectedMinute,
    String notificationId,
    String notificationText,
    String selectedYear,
    String selectedMonth,
    String selectedDayOfMonth,
  ) async {
    String deviceId = '';
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _localNotificationCollectionReference.doc(notificationId).update({
        'Frequency': frequency,
        'Period': period,
        'SelectedDay': selectedDay,
        'SelectedHour': selectedHour,
        'SelectedMinute': selectedMinute,
        'ScheduledDate': scheduledDate,
        'NotificationText': notificationText,
        'SelectedYear': selectedYear,
        'SelectedMonth': selectedMonth,
        'SelectedDayOfMonth': selectedDayOfMonth,
      });
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), deviceId,
          'NOTIFICATION/service/updateLocalNotification');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  updatePushNotification(String _notificationId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _pushNotificationCollectionReference
          .doc(_notificationId)
          .update({'Status': Status.inactive});
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          _notificationId, 'NOTIFICATION/service/updatePushNotification');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future deletePrayerTime(String prayerTimeId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _prayerTimeCollectionReference.doc(prayerTimeId).delete();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          prayerTimeId, 'PRAYER/service/deletePrayerTime');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  removeLocalNotification(String notificationId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      _localNotificationCollectionReference.doc(notificationId).delete();
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e),
          notificationId, 'NOTIFICATION/service/removeLocalNotification');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<LocalNotificationModel>> getLocalNotifications(String userId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _localNotificationCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .map((e) => e.docs
              .map((doc) => LocalNotificationModel.fromData(doc.data(), doc.id))
              .toList());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'NOTIFICATION/service/getLocalNotifications');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<List<LocalNotificationModel>> getLocalNotificationsFuture(
      String userId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return _localNotificationCollectionReference
          .where('UserId', isEqualTo: userId)
          .get()
          .then((e) => e.docs
              .map((doc) => LocalNotificationModel.fromData(doc.data(), doc.id))
              .toList());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'NOTIFICATION/service/getLocalNotifications');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Stream<List<PushNotificationModel>> getUserNotifications(String userId) {
    try {
      if (_firebaseAuth.currentUser == null)
        return Stream.error(StringUtils.unathorized);
      return _pushNotificationCollectionReference
          .where('RecieverId', isEqualTo: userId)
          .where('Status', isEqualTo: Status.active)
          .snapshots()
          .map((e) => e.docs
              .map((doc) => PushNotificationModel.fromData(doc.data(), doc.id))
              .toList());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), userId,
          'NOTIFICATION/service/getUserNotifications');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future<List<PushNotificationModel>> getAllNotifications(
      String prayerId) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      return _pushNotificationCollectionReference
          .where('Status', isEqualTo: Status.active)
          .where('PrayerId', isEqualTo: prayerId)
          .get()
          .then((e) => e.docs
              .map((doc) => PushNotificationModel.fromData(doc.data(), doc.id))
              .toList());
    } catch (e) {
      locator<LogService>().createLog(StringUtils.getErrorMessage(e), '',
          'NOTIFICATION/service/getotifications');
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }

  Future clearNotification(List<String> ids) async {
    try {
      if (_firebaseAuth.currentUser == null)
        return Future.error(StringUtils.unathorized);
      for (int i = 0; i < ids.length; i++) {
        await _pushNotificationCollectionReference
            .doc(ids[i])
            .update({'Status': Status.inactive});
      }
    } catch (e) {
      for (int i = 0; i < ids.length; i++) {
        locator<LogService>().createLog(StringUtils.getErrorMessage(e), ids[i],
            'NOTIFICATION/service/clearNotification');
      }
      throw HttpException(StringUtils.getErrorMessage(e));
    }
  }
}
