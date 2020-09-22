import 'package:flutter/foundation.dart';

class SharingSettingsModel {
  final String userId;
  final String enableSharingViaText;
  final String enableSharingViaEmail;
  final String churchId;
  final String phone;
  final String status;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const SharingSettingsModel(
      {@required this.userId,
      @required this.enableSharingViaEmail,
      @required this.enableSharingViaText,
      @required this.churchId,
      @required this.phone,
      @required this.status,
      @required this.createdBy,
      @required this.createdOn,
      @required this.modifiedBy,
      @required this.modifiedOn});
}
