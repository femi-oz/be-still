class NotificationMessageModel {
  final String? entityId;
  final String? type;
  final bool? isGroup;

  const NotificationMessageModel({
    this.entityId,
    this.type,
    this.isGroup,
  });

  NotificationMessageModel.defaultValue()
      : entityId = '',
        type = '',
        isGroup = false;

  NotificationMessageModel.fromData(Map<String, dynamic> data)
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
