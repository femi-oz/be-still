class PrayerModel {
  String id;
  String groupId;
  String userId;
  String type;
  String title;
  String status;
  String description;
  String descriptionBackup;
  String creatorName;
  String createdBy;
  String modifiedBy;
  bool isAnswer;
  bool isGroup;
  bool isInappropriate;
  DateTime createdOn;
  DateTime modifiedOn;

  PrayerModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.type,
    required this.title,
    required this.status,
    required this.description,
    required this.descriptionBackup,
    required this.isAnswer,
    required this.isGroup,
    required this.isInappropriate,
    required this.creatorName,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
  });

  factory PrayerModel.defaultValue() => PrayerModel(
        createdOn: DateTime.now(),
        modifiedOn: DateTime.now(),
        id: '',
        groupId: '',
        userId: '',
        type: '',
        title: '',
        status: '',
        description: '',
        descriptionBackup: '',
        isAnswer: false,
        isGroup: false,
        isInappropriate: false,
        creatorName: '',
        createdBy: '',
        modifiedBy: '',
      );

  factory PrayerModel.fromData(Map<String, dynamic> snapshot, String did) {
    final id = did;
    final groupId = snapshot['GroupId'] ?? 'N/A';
    final userId = snapshot['UserId'] ?? 'N/A';
    final type = snapshot['Type'] ?? 'N/A';
    final title = snapshot['Title'] ?? 'N/A';
    final status = snapshot['Status'] ?? 'N/A';
    final description = snapshot['Description'] ?? 'N/A';
    final descriptionBackup = snapshot['DescriptionBackup'] ?? 'N/A';
    final isAnswer = snapshot['IsAnswer'] ?? false;
    final isGroup = snapshot['IsGroup'] ?? false;
    final isInappropriate = snapshot['IsInappropriate'] ?? false;
    final creatorName = snapshot['CreatorName'] ?? 'N/A';
    final createdBy = snapshot['CreatedBy'] ?? 'N/A';
    final createdOn = snapshot['CreatedOn']?.toDate();
    final modifiedBy = snapshot['ModifiedBy'] ?? 'N/A';
    final modifiedOn = snapshot['ModifiedOn']?.toDate();
    return PrayerModel(
        id: id,
        groupId: groupId,
        userId: userId,
        type: type,
        title: title,
        status: status,
        description: description,
        descriptionBackup: descriptionBackup,
        isAnswer: isAnswer,
        isGroup: isGroup,
        isInappropriate: isInappropriate,
        creatorName: creatorName,
        createdBy: createdBy,
        createdOn: createdOn,
        modifiedBy: modifiedBy,
        modifiedOn: modifiedOn);
  }

  Map<String, dynamic> toJson() {
    return {
      'GroupId': groupId,
      'UserId': userId,
      'Type': type,
      'Title': title,
      'Status': status,
      'Description': description,
      'DescriptionBackup': descriptionBackup,
      'IsAnswer': isAnswer,
      'IsGroup': isGroup,
      'IsInappropriate': isInappropriate,
      'CreatorName': creatorName,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class PrayerUpdateModel {
  final String id;
  final String prayerId;
  final String userId;
  final String title;
  final String description;
  final String descriptionBackup;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;
  final int deleteStatus;

  const PrayerUpdateModel({
    required this.id,
    required this.prayerId,
    required this.userId,
    required this.title,
    required this.description,
    required this.descriptionBackup,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
    required this.deleteStatus,
  });

  PrayerUpdateModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        prayerId = snapshot['PrayerId'] ?? '',
        userId = snapshot['UserId'] ?? '',
        title = snapshot['Title'] ?? '',
        description = snapshot['Description'] ?? '',
        descriptionBackup = snapshot['DescriptionBackup'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate() ?? DateTime.now(),
        deleteStatus = snapshot['DeleteStatus'] ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'Title': title,
      'Description': description,
      'DescriptionBackup': descriptionBackup,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
      'DeleteStatus': deleteStatus,
    };
  }
}

class UserPrayerModel {
  final String id;
  final String prayerId;
  final String userId;
  final bool isArchived;
  final String sequence;
  final bool isFavorite;
  final String status;
  final int snoozeDuration;
  final String snoozeFrequency;
  final int deleteStatus;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;
  final DateTime snoozeEndDate;
  final DateTime? archivedDate;
  final bool isSnoozed;

  const UserPrayerModel({
    required this.id,
    required this.prayerId,
    required this.userId,
    required this.sequence,
    required this.isFavorite,
    required this.status,
    required this.snoozeDuration,
    required this.snoozeFrequency,
    required this.deleteStatus,
    required this.isArchived,
    required this.isSnoozed,
    required this.snoozeEndDate,
    this.archivedDate,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
  });

  UserPrayerModel.defaultValue()
      : id = '',
        prayerId = '',
        userId = '',
        sequence = '',
        isFavorite = false,
        status = '',
        snoozeDuration = 0,
        snoozeFrequency = '',
        deleteStatus = 0,
        archivedDate = DateTime.now(),
        isArchived = false,
        isSnoozed = false,
        snoozeEndDate = DateTime.now(),
        createdBy = '',
        createdOn = DateTime.now(),
        modifiedBy = '',
        modifiedOn = DateTime.now();

  UserPrayerModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        prayerId = snapshot['PrayerId'] ?? '',
        userId = snapshot['UserId'] ?? '',
        sequence = snapshot['Sequence'] ?? '',
        isFavorite = snapshot['IsFavourite'] ?? '',
        status = snapshot['Status'] ?? '',
        snoozeDuration = snapshot['SnoozeDuration'] ?? 0,
        snoozeFrequency = snapshot['SnoozeFrequency'] ?? '',
        deleteStatus = snapshot['DeleteStatus'] ?? 0,
        archivedDate = snapshot['ArchivedDate']?.toDate() ?? DateTime.now(),
        isArchived = snapshot['IsArchived'] ?? false,
        isSnoozed = snapshot['IsSnoozed'] ?? false,
        snoozeEndDate = snapshot['SnoozeEndDate']?.toDate() ?? DateTime.now(),
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate() ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'Sequence': sequence,
      'IsFavourite': isFavorite,
      'Status': status,
      'SnoozeFrequency': snoozeFrequency,
      'SnoozeDuration': snoozeDuration,
      'DeleteStatus': deleteStatus,
      'IsArchived': isArchived,
      'ArchivedDate': archivedDate,
      'IsSnoozed': isSnoozed,
      'SnoozeEndDate': snoozeEndDate,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class PrayerTagModel {
  final String id;
  final String prayerId;
  final String userId;
  final String tagger;
  final String displayName;
  final String phoneNumber;
  final String email;
  final String message;
  final String identifier;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const PrayerTagModel({
    required this.id,
    required this.prayerId,
    required this.userId,
    required this.tagger,
    required this.displayName,
    required this.identifier,
    required this.phoneNumber,
    required this.email,
    required this.message,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
  });
  PrayerTagModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        prayerId = snapshot['PrayerId'] ?? '',
        userId = snapshot['UserId'] ?? '',
        tagger = snapshot['Tagger'] ?? '',
        displayName = snapshot['DisplayName'] ?? '',
        identifier = snapshot['Identifier'] ?? '',
        phoneNumber = snapshot['PhoneNumber'] ?? '',
        message = snapshot['Message'] ?? '',
        email = snapshot['Email'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate() ?? DateTime.now();
  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'Tagger': tagger,
      'DisplayName': displayName,
      'Identifier': identifier,
      'PhoneNumber': phoneNumber,
      'Message': message,
      'Email': email,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class CombinePrayerStream {
  UserPrayerModel userPrayer;
  // GroupPrayerModel groupPrayer;
  PrayerModel prayer;
  List<PrayerTagModel> tags;
  List<PrayerUpdateModel> updates;

  CombinePrayerStream({
    required this.userPrayer,
    // required this.groupPrayer,
    required this.prayer,
    required this.tags,
    required this.updates,
  });

  factory CombinePrayerStream.defaultValue() => CombinePrayerStream(
      // groupPrayer: GroupPrayerModel.defaultValue(),
      prayer: PrayerModel.defaultValue(),
      tags: [],
      userPrayer: UserPrayerModel.defaultValue(),
      updates: []);
}

class PrayerRequestMessageModel {
  final String senderId;
  final String receiverId;
  final String message;
  final String email;
  final String sender;
  final String receiver;

  const PrayerRequestMessageModel(
      {required this.senderId,
      required this.receiverId,
      required this.message,
      required this.email,
      required this.sender,
      required this.receiver});

  PrayerRequestMessageModel.fromData(Map<String, dynamic> snapshot, String did)
      : senderId = did,
        receiverId = snapshot['ReceiverId'] ?? '',
        message = snapshot['Message'] ?? '',
        email = snapshot['Email'] ?? '',
        sender = snapshot['Sender'] ?? '',
        receiver = snapshot['Receiver'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'SenderId': senderId,
      'ReceiverId': receiverId,
      'Message': message,
      'Email': email,
      'Sender': sender,
      'Receiver': receiver,
    };
  }
}

class HiddenPrayerModel {
  final String id;
  final String prayerId;
  final String userId;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const HiddenPrayerModel({
    required this.id,
    required this.prayerId,
    required this.userId,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
  });

  HiddenPrayerModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        prayerId = snapshot['PrayerId'] ?? '',
        userId = snapshot['UserId'] ?? '',
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate() ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class FollowedPrayerModel {
  final String id;
  final String prayerId;
  final String groupId;
  final String userPrayerId;
  final String userId;
  final bool isFollowedByAdmin;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const FollowedPrayerModel({
    required this.id,
    required this.prayerId,
    required this.groupId,
    required this.userPrayerId,
    required this.userId,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
    required this.isFollowedByAdmin,
  });

  FollowedPrayerModel.defaultValue()
      : id = '',
        prayerId = '',
        groupId = '',
        userPrayerId = '',
        userId = '',
        isFollowedByAdmin = false,
        createdBy = '',
        createdOn = DateTime.now(),
        modifiedBy = '',
        modifiedOn = DateTime.now();

  FollowedPrayerModel.fromData(Map<String, dynamic> snapshot, String did)
      : id = did,
        prayerId = snapshot['PrayerId'] ?? '',
        groupId = snapshot['GroupId'] ?? '',
        userPrayerId = snapshot['UserPrayerId'] ?? '',
        userId = snapshot['UserId'] ?? '',
        isFollowedByAdmin = snapshot['IsFollowedByAdmin'] ?? false,
        createdBy = snapshot['CreatedBy'] ?? '',
        createdOn = snapshot['CreatedOn'].toDate() ?? DateTime.now(),
        modifiedBy = snapshot['ModifiedBy'] ?? '',
        modifiedOn = snapshot['ModifiedOn'].toDate() ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'GroupId': groupId,
      'UserPrayerId': userPrayerId,
      'UserId': userId,
      'IsFollowedByAdmin': isFollowedByAdmin,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class SaveOptionModel {
  final String id;
  final String name;

  const SaveOptionModel({
    required this.id,
    required this.name,
  });
}
