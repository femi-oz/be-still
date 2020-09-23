class NotificationModel {
  String id;
  String content;
  String group;
  DateTime date;
  String type;
  String creator;

  NotificationModel({
    this.id,
    this.content,
    this.group,
    this.type,
    this.creator,
    this.date,
  });
}
