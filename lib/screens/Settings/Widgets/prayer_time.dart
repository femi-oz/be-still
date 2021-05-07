import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/duration.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/date_format.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PrayerTimeSettings extends StatefulWidget {
  final PrayerSettingsModel prayerSettings;
  final SettingsModel settings;

  @override
  PrayerTimeSettings(this.prayerSettings, this.settings);
  _PrayerTimeSettingsState createState() => _PrayerTimeSettingsState();
}

class _PrayerTimeSettingsState extends State<PrayerTimeSettings> {
  BuildContext bcontext;

  @override
  void initState() {
    super.initState();
  }

  var prayerTimeText =
      'Be Still can remind you to pray at a specific time each day or on a regular schedule. Tap the "Add Reminder" button to create one or more prayer times. You will receive a short notification whenever you have scheduled a prayer time to start.';

  List<LookUp> songs = [
    LookUp(text: 'Evening Listening', value: 1),
    LookUp(text: 'Rock Jams', value: 2),
    LookUp(text: 'Prayer Time', value: 3),
    LookUp(text: 'Jason Station', value: 4),
    LookUp(text: 'New Hits', value: 5)
  ];

  double itemExtent = 30.0;
  bool _addPrayerTypeMode = false;
  bool showUpdateField = false;
  LocalNotificationModel reminder;

  _deletePrayerTime(
    int localNotificationId,
    String notificationId,
  ) async {
    try {
      BeStilDialog.showLoading(
        context,
      );
      await LocalNotification.unschedule(localNotificationId);
      await Provider.of<NotificationProvider>(context, listen: false)
          .deleteLocalNotification(notificationId);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      setState(() {});
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimeList =
        Provider.of<NotificationProvider>(context).prayerTimeNotifications;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundColor,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 15),
            CustomSectionHeder('My Prayer Time'),
            SizedBox(height: 35.0),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  prayerTimeText,
                  style: AppTextStyles.regularText15
                      .copyWith(color: AppColors.prayerTextColor),
                )),
            SizedBox(height: 35.0),
            prayerTimeList.length > 0
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        ...prayerTimeList.map(
                          (data) => Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20.0,
                                      right: 15.0,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 10.0,
                                      ),
                                      height: 40.0,
                                      width: MediaQuery.of(context).size.width *
                                          0.75,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.lightBlue6,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Text(
                                              data.frequency,
                                              style: AppTextStyles.regularText15
                                                  .copyWith(
                                                      color: AppColors
                                                          .prayerTextColor),
                                            ),
                                          ),
                                          data.frequency == Frequency.weekly
                                              ? Container(
                                                  child: Text(
                                                    data.selectedDay,
                                                    style: AppTextStyles
                                                        .regularText15
                                                        .copyWith(
                                                      color: AppColors
                                                          .prayerTextColor,
                                                    ),
                                                  ),
                                                )
                                              : data.frequency ==
                                                      Frequency.one_time
                                                  ? Container(
                                                      child: Text(
                                                        DateFormat('MM-dd-yy')
                                                            .format(data
                                                                .scheduledDate),
                                                        style: AppTextStyles
                                                            .regularText15
                                                            .copyWith(
                                                          color: AppColors
                                                              .prayerTextColor,
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                          Row(
                                            children: [
                                              Text(
                                                data.selectedHour,
                                                style: AppTextStyles
                                                    .regularText15
                                                    .copyWith(
                                                  color:
                                                      AppColors.prayerTextColor,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                ':',
                                                style: AppTextStyles
                                                    .regularText15
                                                    .copyWith(
                                                  color:
                                                      AppColors.prayerTextColor,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                data.selectedMinute,
                                                style: AppTextStyles
                                                    .regularText15
                                                    .copyWith(
                                                  color:
                                                      AppColors.prayerTextColor,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                data.period,
                                                style: AppTextStyles
                                                    .regularText15
                                                    .copyWith(
                                                  color:
                                                      AppColors.prayerTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        child: GestureDetector(
                                          child: Icon(
                                            AppIcons.bestill_edit,
                                            size: 16,
                                            color: AppColors.lightBlue3,
                                          ),
                                          onTap: () {
                                            reminder = data;
                                            setState(
                                                () => showUpdateField = true);
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      InkWell(
                                        child: GestureDetector(
                                          child: Icon(
                                            AppIcons.bestill_close,
                                            size: 18,
                                            color: AppColors.lightBlue3,
                                          ),
                                          onTap: () {
                                            _deletePrayerTime(
                                                data.localNotificationId,
                                                data.id);
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 10.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            Column(
              children: [
                !_addPrayerTypeMode && !showUpdateField
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        child: Row(
                          children: [
                            CustomButtonGroup(
                              title: 'ADD REMINDER',
                              onSelected: (_) =>
                                  setState(() => _addPrayerTypeMode = true),
                            )
                          ],
                        ),
                      )
                    : Container(),
                _addPrayerTypeMode
                    ? Container(
                        margin: EdgeInsets.only(bottom: 80.0),
                        child: ReminderPicker(
                          type: NotificationType.prayer_time,
                          hideActionuttons: false,
                          reminder: null,
                          onCancel: () =>
                              setState(() => _addPrayerTypeMode = false),
                        ),
                      )
                    : showUpdateField
                        ? Container(
                            margin: EdgeInsets.only(bottom: 80.0),
                            child: ReminderPicker(
                              type: NotificationType.prayer_time,
                              reminder: reminder,
                              hideActionuttons: false,
                              onCancel: () =>
                                  setState(() => showUpdateField = false),
                            ),
                          )
                        : Container(),
                SizedBox(height: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
