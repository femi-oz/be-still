import 'package:be_still/models/group.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrayerModel {
  final String id;
  final String groupId;
  final String userId;
  final String type;
  final String title;
  final String status;
  final String description;
  final String descriptionBackup;
  final bool isAnswer;
  final bool isInappropriate;
  final String creatorName;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const PrayerModel({
    this.id,
    @required this.groupId,
    @required this.userId,
    @required this.type,
    @required this.title,
    @required this.status,
    @required this.description,
    @required this.descriptionBackup,
    @required this.isAnswer,
    @required this.isInappropriate,
    @required this.creatorName,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  PrayerModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        groupId = snapshot['GroupId'] ?? 'N/A',
        userId = snapshot['UserId'] ?? 'N/A',
        type = snapshot['Type'] ?? 'N/A',
        title = snapshot['Title'] ?? 'N/A',
        status = snapshot['Status'] ?? 'N/A',
        description = snapshot['Description'] ?? 'N/A',
        descriptionBackup = snapshot['DescriptionBackup'] ?? 'N/A',
        isAnswer = snapshot['IsAnswer'] ?? 'N/A',
        isInappropriate = snapshot['IsInappropriate'] ?? 'N/A',
        creatorName = snapshot['CreatorName'] ?? 'N/A',
        createdBy = snapshot['CreatedBy'] ?? 'N/A',
        createdOn = snapshot['CreatedOn']?.toDate(),
        modifiedBy = snapshot['ModifiedBy'] ?? 'N/A',
        modifiedOn = snapshot['ModifiedOn']?.toDate();

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

  const PrayerUpdateModel({
    this.id,
    @required this.prayerId,
    @required this.userId,
    @required this.title,
    @required this.description,
    @required this.descriptionBackup,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  PrayerUpdateModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        prayerId = snapshot.id,
        userId = snapshot['UserId'],
        title = snapshot['Title'],
        description = snapshot['Description'],
        descriptionBackup = snapshot['DescriptionBackup'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

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
  final int deleteStatus;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;
  final DateTime snoozeEndDate;
  final DateTime archivedDate;
  final bool isSnoozed;

  const UserPrayerModel({
    this.id,
    @required this.prayerId,
    @required this.userId,
    @required this.sequence,
    @required this.isFavorite,
    @required this.status,
    @required this.deleteStatus,
    @required this.isArchived,
    @required this.isSnoozed,
    @required this.snoozeEndDate,
    @required this.archivedDate,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  UserPrayerModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        prayerId = snapshot['PrayerId'],
        userId = snapshot['UserId'],
        sequence = snapshot['Sequence'],
        isFavorite = snapshot['IsFavourite'],
        status = snapshot['Status'],
        deleteStatus = snapshot['DeleteStatus'] ?? 0,
        archivedDate = snapshot['ArchivedDate']?.toDate() ?? DateTime.now(),
        isArchived = snapshot['IsArchived'] ?? false,
        isSnoozed = snapshot['IsSnoozed'] ?? false,
        snoozeEndDate = snapshot['SnoozeEndDate']?.toDate() ?? DateTime.now(),
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'Sequence': sequence,
      'IsFavourite': isFavorite,
      'Status': status,
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
    this.id,
    @required this.prayerId,
    @required this.userId,
    @required this.tagger,
    @required this.displayName,
    @required this.identifier,
    @required this.phoneNumber,
    @required this.email,
    @required this.message,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });
  PrayerTagModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        prayerId = snapshot['PrayerId'],
        userId = snapshot['UserId'],
        tagger = snapshot['Tagger'],
        displayName = snapshot['DisplayName'],
        identifier = snapshot['Identifier'],
        phoneNumber = snapshot['PhoneNumber'],
        message = snapshot['Message'],
        email = snapshot['Email'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();
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
  final String id;
  final UserPrayerModel userPrayer;
  final GroupPrayerModel groupPrayer;
  @required
  final PrayerModel prayer;
  @required
  final List<PrayerTagModel> tags;
  @required
  final List<PrayerUpdateModel> updates;

  CombinePrayerStream({
    this.id,
    this.userPrayer,
    this.groupPrayer,
    this.prayer,
    this.tags,
    this.updates,
  });
}

class PrayerRequestMessageModel {
  final String senderId;
  final String receiverId;
  final String message;
  final String email;
  final String sender;
  final String receiver;

  const PrayerRequestMessageModel(
      {@required this.senderId,
      @required this.receiverId,
      @required this.message,
      @required this.email,
      @required this.sender,
      @required this.receiver});

  PrayerRequestMessageModel.fromData(DocumentSnapshot snapshot)
      : senderId = snapshot.id,
        receiverId = snapshot['ReceiverId'],
        message = snapshot['Message'],
        email = snapshot['Email'],
        sender = snapshot['Sender'],
        receiver = snapshot['Receiver'];

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
    this.id,
    @required this.prayerId,
    @required this.userId,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  HiddenPrayerModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        prayerId = snapshot['PrayerId'],
        userId = snapshot['UserId'],
        createdBy = snapshot['CreatedBy'],
        createdOn = snapshot['CreatedOn'].toDate(),
        modifiedBy = snapshot['ModifiedBy'],
        modifiedOn = snapshot['ModifiedOn'].toDate();

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
