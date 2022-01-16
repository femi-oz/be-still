class SharingSettingsModel {
  final String id;
  final String userId;
  final bool enableSharingViaText;
  final bool enableSharingViaEmail;
  final String churchId;
  final String churchName;
  final String churchPhone;
  final String churchEmail;
  final String webFormlink;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;

  const SharingSettingsModel({
    required this.id,
    required this.userId,
    required this.enableSharingViaEmail,
    required this.enableSharingViaText,
    required this.churchId,
    required this.churchName,
    required this.churchPhone,
    required this.churchEmail,
    required this.webFormlink,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedBy,
    required this.modifiedOn,
  });

  factory SharingSettingsModel.defaultValue() => SharingSettingsModel(
      id: '',
      userId: '',
      enableSharingViaEmail: false,
      enableSharingViaText: false,
      churchId: '',
      churchName: '',
      churchPhone: '',
      churchEmail: '',
      webFormlink: '',
      createdBy: '',
      createdOn: DateTime.now(),
      modifiedBy: '',
      modifiedOn: DateTime.now());

  factory SharingSettingsModel.fromData(Map<String, dynamic> data, String did) {
    final String id = did;
    final String userId = data["UserId"] ?? '';
    final bool enableSharingViaEmail = data["EnableSharingViaEmail"] ?? false;
    final bool enableSharingViaText = data["EnableSharingViaText"] ?? false;
    final String churchId = data["ChurchId"] ?? '';
    final String churchName = data["ChurchName"] ?? '';
    final String churchPhone = data["ChurchPhone"] ?? '';
    final String churchEmail = data["ChurchEmail"] ?? '';
    final String webFormlink = data["WebFormLink"] ?? '';
    final String createdBy = data["CreatedBy"];
    final DateTime createdOn = data["CreatedOn"].toDate() ?? DateTime.now();
    final String modifiedBy = data["ModifiedBy"];
    final DateTime modifiedOn = data["ModifiedOn"].toDate() ?? DateTime.now();
    return SharingSettingsModel(
        id: id,
        userId: userId,
        enableSharingViaEmail: enableSharingViaEmail,
        enableSharingViaText: enableSharingViaText,
        churchId: churchId,
        churchName: churchName,
        churchPhone: churchPhone,
        churchEmail: churchEmail,
        webFormlink: webFormlink,
        createdBy: createdBy,
        createdOn: createdOn,
        modifiedBy: modifiedBy,
        modifiedOn: modifiedOn);
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'EnableSharingViaEmail': enableSharingViaEmail,
      'EnableSharingViaText': enableSharingViaText,
      'ChurchId': churchId,
      'ChurchName': churchName,
      'ChurchPhone': churchPhone,
      'ChurchEmail': churchEmail,
      'WebFormLink': webFormlink,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
