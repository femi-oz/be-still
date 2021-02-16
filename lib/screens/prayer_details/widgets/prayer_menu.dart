import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/add_update/add_update.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/share_prayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'delete_prayer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class PrayerMenu extends StatefulWidget {
  final CombinePrayerStream prayerData;
  final List<PrayerUpdateModel> updates;

  final BuildContext parentcontext;
  @override
  PrayerMenu(this.prayerData, this.updates, this.parentcontext);

  @override
  _PrayerMenuState createState() => _PrayerMenuState();
}

class _PrayerMenuState extends State<PrayerMenu> {
  List<String> reminderInterval = [
    // 'Hourly',
    'Daily',
    'Weekly',
    // 'Monthly',
    // 'Yearly'
  ];
  List<String> snoozeInterval = [
    '7 Days',
    '14 Days',
    '30 Days',
    '90 Days',
    '1 Year'
  ];
  // List<String> reminderDays = [];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future onSelectNotification(String payload) async {
    await Provider.of<PrayerProvider>(context, listen: false)
        .setPrayer(widget.prayerData.userPrayer.id);
    Navigator.of(context).pushNamed(PrayerDetails.routeName);
  }

  @override
  void initState() {
    _configureLocalTimeZone();
    // for (var i = 1; i <= 31; i++) {
    //   setState(() {
    //     reminderDays.add(i < 10 ? '0$i' : '$i');
    //   });
    // }
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
    super.initState();
  }

  String currentTimeZone;
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();

    currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  tz.TZDateTime _scheduleDate(selectedHour, selectedMinute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, selectedHour, selectedMinute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  showNotification(selectedHour, selectedFrequency, selectedMinute) async {
    var localNots = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications;
    var localId = localNots.length > 0
        ? localNots
                .reduce((a, b) =>
                    a.localNotificationId > b.localNotificationId ? a : b)
                .localNotificationId +
            1
        : 0;
    await flutterLocalNotificationsPlugin.zonedSchedule(
        localId,
        'Reminder to Pray',
        widget.prayerData.prayer.description,
        _scheduleDate(selectedHour, selectedMinute),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name', 'your channel description'),
            iOS: IOSNotificationDetails()),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: selectedFrequency.toString().toLowerCase() ==
                Frequency.daily.toLowerCase()
            ? DateTimeComponents.time
            : DateTimeComponents
                .dayOfWeekAndTime); //daily:time,weekly:dayOfWeekAndTime
    await storeNotification(localId);
  }

  storeNotification(localId) async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<NotificationProvider>(context, listen: false)
          .addLocalNotification(localId);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      _onWillPop();
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  var reminder = '';

  var snooze = '';

  setReminder(value) {
    setState(() {
      reminder = value;
    });
  }

  setSnooze(value) {
    setState(() {
      snooze = value;
    });
  }

  BuildContext bcontext;

  void _onMarkAsAnswered() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(widget.prayerData.prayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      _onWillPop();
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  void _unArchive() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .unArchivePrayer(widget.prayerData.prayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      _onWillPop();
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  void _onArchive() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .archivePrayer(widget.prayerData.prayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      _onWillPop();
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  _onWillPop() {
    Navigator.of(context).pushReplacementNamed(PrayerDetails.routeName);
  }

  Widget build(BuildContext context) {
    List<String> updates = [];
    widget.updates.forEach((data) => {
          updates = [...updates, data.description].toList()
        });

    var newUpdates = updates.join("<br>");

    setState(() => this.bcontext = context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      barrierColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.5),
                      backgroundColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SharePrayer(
                            prayer: widget.prayerData.prayer.description,
                            updates:
                                widget.updates.length > 0 ? newUpdates : '');
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          AppIcons.bestill_share,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Share',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPrayer(
                        isEdit: true,
                        prayer: widget.prayerData.prayer,
                      ),
                    ),
                  ),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          AppIcons.bestill_edit,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddUpdate(
                          prayer: widget.prayerData.prayer,
                          updates: widget.updates,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          AppIcons.bestill_update,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Add an Update',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      barrierColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.5),
                      backgroundColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return ReminderPicker(
                          hideActionuttons: false,
                          frequency: reminderInterval,
                          reminderDays: [
                            DaysOfWeek.sun,
                            DaysOfWeek.mon,
                            DaysOfWeek.tue,
                            DaysOfWeek.wed,
                            DaysOfWeek.thu,
                            DaysOfWeek.fri,
                            DaysOfWeek.sat,
                          ],
                          onCancel: () => Navigator.of(context).pop(),
                          onSave: (selectedFrequency, selectedHour,
                                  selectedMinute, _) =>
                              showNotification(selectedHour, selectedFrequency,
                                  selectedMinute),
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          AppIcons.bestill_reminder,
                          color: AppColors.lightBlue4,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  'Reminder',
                                  style: TextStyle(
                                    color: AppColors.lightBlue4,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                reminder,
                                style: TextStyle(
                                  color: AppColors.lightBlue4,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  // {
                  //   showModalBottomSheet(
                  //     context: context,
                  //     barrierColor:
                  //         AppColors.detailBackgroundColor[1].withOpacity(0.5),
                  //     backgroundColor:
                  //         AppColors.detailBackgroundColor[1].withOpacity(0.9),
                  //     isScrollControlled: true,
                  //     builder: (BuildContext context) {
                  //       return CustomPicker(
                  //           snoozeInterval, setSnooze, false, null);
                  //     },
                  //   );
                  // },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          AppIcons.bestill_snooze,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Snooze',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.prayerData.prayer.isAnswer == false
                    ? GestureDetector(
                        onTap: () => _onMarkAsAnswered(),
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.lightBlue6,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                AppIcons.bestill_answered,
                                color: AppColors.lightBlue4,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  'Mark as Answered',
                                  style: TextStyle(
                                    color: AppColors.lightBlue4,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                widget.prayerData.prayer.status == Status.active &&
                        !widget.prayerData.prayer.isArchived
                    ? GestureDetector(
                        onTap: _onArchive,
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.lightBlue6,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                AppIcons.bestill_archive,
                                color: AppColors.lightBlue4,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  'Archive',
                                  style: TextStyle(
                                    color: AppColors.lightBlue4,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: _unArchive,
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.lightBlue6,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                AppIcons.bestill_archive,
                                color: AppColors.lightBlue4,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  'Unarchive',
                                  style: TextStyle(
                                    color: AppColors.lightBlue4,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      barrierColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.5),
                      backgroundColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return DeletePrayer(widget.prayerData);
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          AppIcons.bestill_delete,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              AppIcons.bestill_close,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: AppColors.textFieldText,
          ),
        ],
      ),
    );
  }
}
