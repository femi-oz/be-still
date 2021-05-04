import 'dart:convert';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/widgets/no_update_view.dart';
import 'package:be_still/screens/prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/screens/prayer_details/widgets/update_view.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import '../entry_screen.dart';

class PrayerDetails extends StatefulWidget {
  static const routeName = 'prayer-details';

  @override
  _PrayerDetailsState createState() => _PrayerDetailsState();
}

class _PrayerDetailsState extends State<PrayerDetails> {
  // GroupUserModel groupUser;

  void getSettings() async {
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    await Provider.of<SettingsProvider>(context, listen: false)
        .setSettings(_user.id);
  }

  Duration snoozeDurationinDays;
  DateTime snoozeEndDate;
  Duration snoozeDurationinHour;
  Duration snoozeDurationinMinutes;
  String durationText;
  int snoozeDuration;
  LocalNotificationModel reminder;
  Widget _buildMenu() {
    return PrayerMenu(context, hasReminder, reminder, () => updateUI());
  }

  String reminderString;
  bool get hasReminder {
    var reminders = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications;
    final prayerData =
        Provider.of<PrayerProvider>(context, listen: false).currentPrayer;
    reminder = reminders.firstWhere(
        (reminder) => reminder.entityId == prayerData.userPrayer.id,
        orElse: () => null);
    reminderString = reminder?.notificationText ?? '';

    if (reminder == null)
      return false;
    else
      return true;
  }

  bool _isInit = true;

  updateUI() {
    if (hasReminder) {
      print('reminderString $reminderString');
    }
    setState(() {});
  }

  BuildContext selectedContext;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      getSettings();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  setNotification(selectedHour, selectedFrequency, selectedMinute, selectedDay,
      period, CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      final notificationText = selectedFrequency == Frequency.weekly
          ? '$selectedFrequency, $selectedDay, $selectedHour:$selectedMinute $period'
          : '$selectedFrequency, $selectedHour:$selectedMinute $period';
      final title = '$selectedFrequency reminder to pray';
      final description = prayerData.prayer.description;
      final scheduleDate = LocalNotification.scheduleDate(
          int.parse(selectedHour),
          int.parse(selectedMinute),
          selectedDay,
          period);
      final payload = NotificationMessage(
          entityId: prayerData.userPrayer.id, type: NotificationType.prayer);
      await LocalNotification.setLocalNotification(
        context: context,
        title: title,
        description: description,
        scheduledDate: scheduleDate,
        payload: jsonEncode(payload.toJson()),
        frequency: selectedFrequency,
        localNotificationId: reminder.localNotificationId,
      );
      await storeNotification(
        notificationText,
        userId,
        title,
        description,
        selectedFrequency,
        scheduleDate,
        prayerData.userPrayer.id,
        selectedDay,
        period,
        selectedHour,
        selectedMinute,
      );
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  storeNotification(
      String notificationText,
      String userId,
      String title,
      String description,
      String frequency,
      tz.TZDateTime scheduledDate,
      String prayerid,
      String selectedDay,
      String period,
      String selectedHour,
      String selectedMinute) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .updateLocalNotification(
      frequency,
      scheduledDate,
      selectedDay,
      period,
      selectedHour,
      selectedMinute,
      reminder.id,
      userId,
      notificationText,
    );
    await Future.delayed(Duration(milliseconds: 300));
    BeStilDialog.hideLoading(context);
    Navigator.of(context).pop();
    setState(() => reminderString = notificationText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showPrayerActions: false,
      ),
      endDrawer: CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton.icon(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.zero),
                    ),
                    icon: Icon(
                      AppIcons.bestill_back_arrow,
                      color: AppColors.lightBlue3,
                      size: 20,
                    ),
                    onPressed: () => NavigationService.instance.goHome(0),
                    label: Text(
                      'BACK',
                      style: AppTextStyles.boldText20.copyWith(
                        color: AppColors.lightBlue3,
                      ),
                    ),
                  ),
                  hasReminder
                      ? InkWell(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            barrierColor: AppColors.detailBackgroundColor[1]
                                .withOpacity(0.5),
                            backgroundColor: AppColors.detailBackgroundColor[1]
                                .withOpacity(0.9),
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return ReminderPicker(
                                hideActionuttons: false,
                                frequency: LocalNotification.reminderInterval,
                                reminderDays: LocalNotification.reminderDays,
                                onCancel: () => Navigator.of(context).pop(),
                                onSave: (selectedFrequency, selectedHour,
                                        selectedMinute, selectedDay, period) =>
                                    setNotification(
                                        selectedHour,
                                        selectedFrequency,
                                        selectedMinute,
                                        selectedDay,
                                        period,
                                        Provider.of<PrayerProvider>(context,
                                                listen: false)
                                            .currentPrayer),
                                selectedDay: LocalNotification.reminderDays
                                        .indexOf(reminder.selectedDay) +
                                    1,
                                selectedFrequency: reminder.frequency,
                                selectedHour: int.parse(reminder.selectedHour),
                                selectedMinute:
                                    int.parse(reminder.selectedMinute),
                                selectedPeriod: reminder.period,
                              );
                            },
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                AppIcons.bestill_reminder,
                                size: 14,
                                color: AppColors.lightBlue5,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  reminderString,
                                  style: TextStyle(
                                    color: AppColors.lightBlue5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  color: AppColors.prayerDetailsBgColor,
                  // ),
                  border: Border.all(
                    color: AppColors.cardBorder,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Provider.of<PrayerProvider>(context)
                            .currentPrayer
                            .updates
                            .length >
                        0
                    ? UpdateView()
                    : NoUpdateView(),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: AppColors.lightBlue3,
              ),
              onPressed: () => showModalBottomSheet(
                context: context,
                barrierColor:
                    AppColors.detailBackgroundColor[1].withOpacity(0.5),
                backgroundColor:
                    AppColors.detailBackgroundColor[1].withOpacity(1),
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return _buildMenu();
                },
              ),
            ),
          ],
          // ),
        ),
        // endDrawer: CustomDrawer(),
      ),
    );
  }
}

class PrayerDetailsRouteArguments {
  final String id;
  final bool isGroup;

  PrayerDetailsRouteArguments({
    this.id,
    this.isGroup,
  });
}
