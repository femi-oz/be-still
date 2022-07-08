import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/utils/local_notification.dart';

class PushNotificationModel {
  final String? id;
  final String? title;
  final List<dynamic> tokens;
  final String? messageType;
  final String? message;
  final String? sender;
  final String? recieverId;
  final String? prayerId;
  final String? groupId;
  final String? status;
  final int? isSent;
  final String? createdBy;
  final DateTime? createdOn;
  final String? modifiedBy;
  final DateTime? modifiedOn;

  const PushNotificationModel({
    this.id,
    this.title,
    this.messageType,
    required this.tokens,
    this.message,
    this.status,
    this.sender,
    this.recieverId,
    this.prayerId,
    this.groupId,
    this.isSent,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });
  PushNotificationModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        title = snapshot['Title'] ?? '',
        tokens = snapshot['Tokens'] ?? [],
        message = snapshot['Message'] ?? '',
        messageType = snapshot['MessageType'] ?? NotificationType.prayer,
        isSent = snapshot['IsSent'] ?? 0,
        status = snapshot['Status'] ?? '',
        recieverId = snapshot['RecieverId'] ?? '',
        prayerId = snapshot['PrayerId'] ?? '',
        groupId = snapshot['GroupId'] ?? '',
        sender = snapshot['Sender'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn']?.toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn']?.toDate() ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Message': message,
      'MessageType': messageType,
      'Tokens': tokens,
      'Sender': sender,
      'IsSent': isSent,
      'Status': status,
      'RecieverId': recieverId,
      'PrayerId': prayerId,
      'GroupId': groupId,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class LocalNotificationModel {
  final String? id;
  final String? userId;
  final String? entityId;
  final String? description;
  final DateTime? scheduledDate;
  final String? frequency;
  final String? title;
  final String? payload;
  final String? type;
  final String? notificationText;
  final int? localNotificationId;
  final String? selectedDay;
  final String? period;
  final String? selectedHour;
  final String? selectedMinute;
  final String? selectedYear;
  final String? selectedMonth;
  final String? selectedDayOfMonth;

  const LocalNotificationModel({
    this.id,
    this.userId,
    this.entityId,
    this.payload,
    this.title,
    this.description,
    this.frequency,
    this.type,
    this.scheduledDate,
    this.notificationText,
    this.localNotificationId,
    this.selectedDay,
    this.period,
    this.selectedHour,
    this.selectedMinute,
    this.selectedYear,
    this.selectedMonth,
    this.selectedDayOfMonth,
  });

  LocalNotificationModel.defaultValue()
      : id = '',
        userId = '',
        entityId = '',
        description = '',
        scheduledDate = DateTime.now(),
        title = '',
        type = '',
        frequency = '',
        payload = '',
        notificationText = '',
        localNotificationId = 0,
        selectedDay = LocalNotification.daysOfWeek[DateTime.now().weekday - 1],
        period = 'pm',
        selectedHour = DateTime.now().hour.toString(),
        selectedMinute = DateTime.now().minute.toString(),
        selectedMonth = DateTime.now().month.toString(),
        selectedDayOfMonth = DateTime.now().day.toString(),
        selectedYear = DateTime.now().year.toString();

  LocalNotificationModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        userId = snapshot['UserId'] ?? '',
        entityId = snapshot['EntityId'] ?? '',
        description = snapshot['Description'] ?? '',
        scheduledDate = snapshot['ScheduledDate']?.toDate() ?? DateTime.now(),
        title = snapshot['Title'] ?? '',
        type = snapshot['Type'] ?? '',
        frequency = snapshot['Frequency'] ?? '',
        payload = snapshot['Payload'] ?? '',
        notificationText = snapshot['NotificationText'] ?? '',
        localNotificationId = snapshot['LocalNotificationId'] ?? 0,
        selectedDay =
            snapshot['SelectedDay'] == null || snapshot['SelectedDay'] == ''
                ? LocalNotification.daysOfWeek[DateTime.now().weekday - 1]
                : snapshot['SelectedDay'],
        period = snapshot['Period'] == '' || snapshot['Period'] == null
            ? 'pm'
            : snapshot['Period'],
        selectedHour =
            snapshot['SelectedHour'] == '' || snapshot['SelectedHour'] == null
                ? DateTime.now().hour.toString()
                : snapshot['SelectedHour'],
        selectedMinute = snapshot['SelectedMinute'] == '' ||
                snapshot['SelectedMinute'] == null
            ? DateTime.now().minute.toString()
            : snapshot['SelectedMinute'],
        selectedMonth =
            snapshot['SelectedMonth'] == '' || snapshot['SelectedMonth'] == null
                ? DateTime.now().month.toString()
                : snapshot['SelectedMonth'],
        selectedDayOfMonth = snapshot['SelectedDayOfMonth'] == '' ||
                snapshot['SelectedDayOfMonth'] == null
            ? DateTime.now().day.toString()
            : snapshot['SelectedDayOfMonth'],
        selectedYear =
            snapshot['SelectedYear'] == '' || snapshot['SelectedYear'] == null
                ? DateTime.now().year.toString()
                : snapshot['SelectedYear'];

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'EntityId': entityId,
      'Title': title,
      'Description': description,
      'Frequency': frequency,
      'ScheduledDate': scheduledDate,
      'Type': type,
      'Payload': payload,
      'NotificationText': notificationText,
      'LocalNotificationId': localNotificationId,
      'SelectedDay': selectedDay,
      'Period': period,
      'SelectedHour': selectedHour,
      'SelectedMinute': selectedMinute,
      'SelectedMonth': selectedMonth,
      'SelectedDayOfMonth': selectedDayOfMonth,
      'SelectedYear': selectedYear,
    };
  }
}

class MessageModel {
  final String? id;
  final String? title;
  final String? message;
  final String? subject;
  final String? phoneNumber;
  final String? email;
  final String? sender;
  final String? country;
  final String? receiver;
  final String? senderId;
  final int? isSent;
  final String? createdBy;
  final DateTime? createdOn;
  final String? modifiedBy;
  final DateTime? modifiedOn;

  const MessageModel({
    this.id,
    this.title,
    this.message,
    this.sender,
    this.subject,
    this.receiver,
    this.country,
    this.phoneNumber,
    this.email,
    this.senderId,
    this.isSent,
    this.createdBy,
    this.createdOn,
    this.modifiedBy,
    this.modifiedOn,
  });
  MessageModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        title = snapshot['Title'] ?? '',
        message = snapshot['Message'] ?? '',
        isSent = snapshot['IsSent'] ?? 0,
        sender = snapshot['Sender'] ?? '',
        country = snapshot['Country'] ?? '',
        subject = snapshot['Subject'] ?? '',
        receiver = snapshot['Receiver'] ?? '',
        phoneNumber = snapshot['PhoneNumber'] ?? '',
        email = snapshot['Email'] ?? '',
        senderId = snapshot['SenderId'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn']?.toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn']?.toDate() ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Message': message,
      'SenderId': senderId,
      'Sender': sender,
      'Subject': subject,
      'Country': country,
      'PhoneNumber': phoneNumber,
      'Receiver': receiver,
      'Email': email,
      'IsSent': isSent,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class NotificationMessage {
  final String? entityId;
  final String? type;
  final bool? isGroup;

  const NotificationMessage({
    this.entityId,
    this.type,
    this.isGroup,
  });

  NotificationMessage.defaultValue()
      : entityId = '',
        type = '',
        isGroup = false;

  NotificationMessage.fromData(Map<String, dynamic> data)
      : entityId = data['entityId'] ?? '',
        type = data['type'] ?? '',
        isGroup = data['isGroup'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'entityId': entityId,
      'type': type,
      'isGroup': isGroup,
    };
  }
}
