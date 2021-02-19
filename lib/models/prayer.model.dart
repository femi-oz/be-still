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
  final bool isAnswer;
  final bool isArchived;
  final bool isSnoozed;
  final bool isInappropriate;
  final bool hideFromMe;
  final bool hideFromAllMembers;
  final DateTime snoozeEndDate;
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
    @required this.isAnswer,
    @required this.isSnoozed,
    @required this.isArchived,
    @required this.isInappropriate,
    @required this.hideFromMe,
    @required this.hideFromAllMembers,
    @required this.snoozeEndDate,
    @required this.creatorName,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  PrayerModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        groupId = snapshot.data()['GroupId'],
        userId = snapshot.data()['UserId'],
        type = snapshot.data()['Type'],
        title = snapshot.data()['Title'],
        status = snapshot.data()['Status'],
        description = snapshot.data()['Description'],
        isAnswer = snapshot.data()['IsAnswer'],
        isArchived = snapshot.data()['IsArchived'],
        isSnoozed = snapshot.data()['IsSnoozed'],
        isInappropriate = snapshot.data()['IsInappropriate'],
        hideFromMe = snapshot.data()['HideFromMe'],
        hideFromAllMembers = snapshot.data()['HideFromAllMembers'],
        snoozeEndDate = snapshot.data()['SnoozeEndDate'],
        creatorName = snapshot.data()['CreatorName'] ?? 'N/A',
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'GroupId': groupId,
      'UserId': userId,
      'Type': type,
      'Title': title,
      'Status': status,
      'Description': description,
      'IsAnswer': isAnswer,
      'IsArchived': isArchived,
      'IsSnoozed': isSnoozed,
      'IsInappropriate': isInappropriate,
      'HideFromMe': hideFromMe,
      'HideFromAllMembers': hideFromAllMembers,
      'SnoozeEndDate': snoozeEndDate,
      'CreatorName': creatorName,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}

class PrayerDisableModel {
  final String prayerId;
  final String userId;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const PrayerDisableModel(
      {@required this.prayerId,
      @required this.userId,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});

  PrayerDisableModel.fromData(DocumentSnapshot snapshot)
      : prayerId = snapshot.id,
        userId = snapshot.data()['UserId'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

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
        receiverId = snapshot.data()['ReceiverId'],
        message = snapshot.data()['Message'],
        email = snapshot.data()['Email'],
        sender = snapshot.data()['Sender'],
        receiver = snapshot.data()['Receiver'];

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

class PrayerUpdateModel {
  final String id;
  final String prayerId;
  final String userId;
  final String title;
  final String description;
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
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  PrayerUpdateModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        prayerId = snapshot.id,
        userId = snapshot.data()['UserId'],
        title = snapshot.data()['Title'],
        description = snapshot.data()['Description'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'Title': title,
      'Description': description,
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
  final String sequence;
  final bool isFavorite;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const UserPrayerModel({
    this.id,
    @required this.prayerId,
    @required this.userId,
    @required this.sequence,
    @required this.isFavorite,
    @required this.status,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
  });

  UserPrayerModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        prayerId = snapshot.data()['PrayerId'],
        userId = snapshot.data()['UserId'],
        sequence = snapshot.data()['Sequence'],
        isFavorite = snapshot.data()['IsFavourite'],
        status = snapshot.data()['Status'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'Sequence': sequence,
      'IsFavourite': isFavorite,
      'Status': status,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
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
        prayerId = snapshot.data()['PrayerId'],
        userId = snapshot.data()['UserId'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

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

class PrayerTagModel {
  final String id;
  final String prayerId;
  final String userId;
  final String tagger;
  final String displayName;
  final String phoneNumber;
  final String email;
  final String message;
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
        prayerId = snapshot.data()['PrayerId'],
        userId = snapshot.data()['UserId'],
        tagger = snapshot.data()['Tagger'],
        displayName = snapshot.data()['DisplayName'],
        phoneNumber = snapshot.data()['PhoneNumber'],
        message = snapshot.data()['Message'],
        email = snapshot.data()['Email'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();
  Map<String, dynamic> toJson() {
    return {
      'PrayerId': prayerId,
      'UserId': userId,
      'Tagger': tagger,
      'DisplayName': displayName,
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
