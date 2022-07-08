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
