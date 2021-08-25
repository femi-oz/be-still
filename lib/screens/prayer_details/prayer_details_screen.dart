import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/widgets/no_update_view.dart';
import 'package:be_still/screens/prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/screens/prayer_details/widgets/update_view.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

class PrayerDetails extends StatefulWidget {
  static const routeName = 'prayer-details';

  final Function setCurrentIndex;
  PrayerDetails(this.setCurrentIndex);

  @override
  _PrayerDetailsState createState() => _PrayerDetailsState();
}

class _PrayerDetailsState extends State<PrayerDetails> {
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
  LocalNotificationModel _reminder;
  Widget _buildMenu() {
    final prayerData =
        Provider.of<PrayerProvider>(context, listen: false).currentPrayer;
    return PrayerMenu(
        context, hasReminder, _reminder, () => updateUI(), prayerData);
  }

  String reminderString;
  bool get hasReminder {
    var reminders = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications;
    final prayerData =
        Provider.of<PrayerProvider>(context, listen: false).currentPrayer;
    final reminder = reminders.firstWhere(
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
    setState(() {});
  }

  String getDayText(day) {
    var suffix = "th";
    var digit = day % 10;
    if ((digit > 0 && digit < 4) && (day < 11 || day > 13)) {
      suffix = ["st", "nd", "rd"][digit - 1];
    }
    return day.toString() + suffix;
  }

  BuildContext selectedContext;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        getSettings();
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var reminders = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications;
    final prayerData =
        Provider.of<PrayerProvider>(context, listen: false).currentPrayer;
    _reminder = reminders.firstWhere(
        (reminder) => reminder.entityId == prayerData.userPrayer.id,
        orElse: () => null);
    return Scaffold(
      appBar: CustomAppBar(
        showPrayerActions: false,
      ),
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
              padding: EdgeInsets.only(left: 10, top: 20, right: 10),
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
                    onPressed: () => widget.setCurrentIndex(0, true),
                    label: Text(
                      'BACK',
                      style: AppTextStyles.boldText20.copyWith(
                        color: AppColors.lightBlue3,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Transform.rotate(
                        angle: 90 * math.pi / 180,
                        child: IconButton(
                          icon: Icon(Icons.build, color: AppColors.lightBlue3),
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            barrierColor: Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .isDarkModeEnabled
                                ? AppColors.backgroundColor[0].withOpacity(0.8)
                                : Color(0xFF021D3C).withOpacity(0.7),
                            backgroundColor: Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .isDarkModeEnabled
                                ? AppColors.backgroundColor[0].withOpacity(0.8)
                                : Color(0xFF021D3C).withOpacity(0.7),
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return _buildMenu();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (prayerData.userPrayer.isSnoozed)
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                InkWell(
                  onTap: () => showDialog(
                    context: context,
                    barrierColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.5),
                    builder: (BuildContext context) {
                      return Dialog(
                        insetPadding: EdgeInsets.all(20),
                        backgroundColor: AppColors.prayerCardBgColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: AppColors.darkBlue),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: ReminderPicker(
                                type: NotificationType.reminder,
                                reminder: _reminder,
                                hideActionuttons: false,
                                onCancel: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        AppIcons.snooze,
                        size: 12,
                        color: AppColors.lightBlue5,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 7),
                        child: Text(
                            'Snoozed until ${DateFormat('MMM').format(prayerData.userPrayer.snoozeEndDate)} ${getDayText(prayerData.userPrayer.snoozeEndDate.day)}, ${DateFormat('yyyy h:mm a').format(prayerData.userPrayer.snoozeEndDate)}',
                            style: AppTextStyles.regularText12),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
              ]),
            hasReminder
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => showDialog(
                          context: context,
                          barrierColor: AppColors.detailBackgroundColor[1]
                              .withOpacity(0.5),
                          builder: (BuildContext context) {
                            return Dialog(
                              insetPadding: EdgeInsets.all(20),
                              backgroundColor: AppColors.prayerCardBgColor,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: AppColors.darkBlue),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 30),
                                    child: ReminderPicker(
                                      type: NotificationType.reminder,
                                      reminder: _reminder,
                                      hideActionuttons: false,
                                      onCancel: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              AppIcons.bestill_reminder,
                              size: 12,
                              color: AppColors.lightBlue5,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 7),
                              child: Text(reminderString,
                                  style: AppTextStyles.regularText12),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  )
                : Container(),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.prayerDetailsBgColor,
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
            SizedBox(
              height: 30,
            )
          ],
        ),
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
