import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter(this.dateTime);
  DateTime dateTime;

  String format() {
    DateTime now = DateTime.now();
    DateTime justNow = DateTime.now().subtract(Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();

    if (now.difference(localDateTime).inDays > 30) {
      var val = now.difference(localDateTime).inDays / 30;
      return "${val.ceil()} ${val.ceil() > 1 ? 'months' : 'month'} ago";
    }

    if (now.difference(localDateTime).inDays > 6 &&
        now.difference(localDateTime).inDays < 31) {
      var val = now.difference(localDateTime).inDays / 7;
      return "${val.ceil()} ${val.ceil() > 1 ? 'weeks' : 'week'} ago";
    }
    if (!localDateTime.difference(justNow).isNegative) {
      return 'Just now';
    }

    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return 'Today';
    }
    DateTime yesterday = now.subtract(Duration(days: 1));
    if (localDateTime.day == yesterday.day &&
        localDateTime.month == yesterday.month &&
        localDateTime.year == yesterday.year) {
      return 'Yesterday';
    }

    if (now.difference(localDateTime).inDays < 7) {
      String weekday = DateFormat('EEEE').format(localDateTime);
      return '$weekday';
    }
    return 'N/A';
  }
}
