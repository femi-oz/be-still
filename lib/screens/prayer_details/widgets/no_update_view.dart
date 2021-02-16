import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoUpdateView extends StatefulWidget {
  @override
  NoUpdateView();

  @override
  _NoUpdateViewState createState() => _NoUpdateViewState();
}

class _NoUpdateViewState extends State<NoUpdateView> {
  bool get hasReminder {
    var reminders = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications;
    final prayerData =
        Provider.of<PrayerProvider>(context, listen: false).currentPrayer;
    var reminder = reminders.firstWhere(
        (reminder) => reminder.entityId == prayerData.prayer.id,
        orElse: () => null);

    if (reminder == null)
      return false;
    else
      return true;
  }

  Widget build(BuildContext context) {
    final prayerData = Provider.of<PrayerProvider>(context).currentPrayer;
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          prayerData.prayer.groupId != '0'
              ? Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(
                    prayerData.prayer.creatorName,
                    style: AppTextStyles.boldText16.copyWith(
                      color: AppColors.lightBlue4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                )
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    DateFormat('hh:mma | MM.dd.yyyy')
                        .format(prayerData.prayer.createdOn),
                    style: AppTextStyles.regularText13.copyWith(
                      color: AppColors.lightBlue4,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
              hasReminder
                  ? Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppColors.lightBlue3,
                    )
                  : Container(),
              SizedBox(width: 10),
              Expanded(
                child: Divider(
                  color: AppColors.lightBlue4,
                  thickness: 1,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: Center(
                child: Text(
                  prayerData.prayer.description,
                  style: AppTextStyles.regularText18b.copyWith(
                    color: AppColors.prayerTextColor,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
