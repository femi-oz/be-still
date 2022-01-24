import 'dart:io';

import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/widgets/no_update_view.dart';
import 'package:be_still/screens/prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/screens/prayer_details/widgets/update_view.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

class PrayerDetails extends StatefulWidget {
  static const routeName = 'prayer-details';

  @override
  _PrayerDetailsState createState() => _PrayerDetailsState();
}

class _PrayerDetailsState extends State<PrayerDetails> {
  void getSettings() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<SettingsProvider>(context, listen: false)
          .setSettings(_user.id ?? '');
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured, user, s);
    }
  }

  Duration snoozeDurationinDays = Duration.zero;
  DateTime snoozeEndDate = DateTime.now();
  Duration snoozeDurationinHour = Duration.zero;
  Duration snoozeDurationinMinutes = Duration.zero;
  String durationText = '';
  int snoozeDuration = 0;
  // String reminderString = '';

  Widget _buildMenu(
      CombinePrayerStream? prayerData, LocalNotificationModel reminder) {
    return PrayerMenu(context, hasReminder(prayerData), reminder,
        () => updateUI(), prayerData);
  }

  String reminderString(CombinePrayerStream? prayerData) {
    final reminders = Provider.of<NotificationProvider>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();

    LocalNotificationModel? reminder = reminders.firstWhere(
        (reminder) => reminder.entityId == (prayerData?.userPrayer?.id ?? ''),
        orElse: () => LocalNotificationModel.defaultValue());
    return reminder.notificationText ?? '';
  }

  bool hasReminder(CombinePrayerStream? prayerData) {
    final reminders = Provider.of<NotificationProvider>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();

    return reminders.any(
        (reminder) => reminder.entityId == (prayerData?.userPrayer?.id ?? ''));
  }

  bool isReminderActive(CombinePrayerStream? prayerData) {
    final reminders = Provider.of<NotificationProvider>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();

    LocalNotificationModel rem = reminders.firstWhere(
        (reminder) => reminder.entityId == prayerData?.userPrayer?.id,
        orElse: () => LocalNotificationModel.defaultValue());
    if ((rem.id ?? '').isNotEmpty) {
      if (rem.frequency != Frequency.one_time) {
        return true;
      } else {
        if ((rem.scheduledDate ?? DateTime.now().subtract(Duration(hours: 1)))
            .isAfter(DateTime.now())) {
          return true;
        } else {
          Provider.of<NotificationProvider>(context).deleteLocalNotification(
              rem.id ?? '', rem.localNotificationId ?? 0);
          return false;
        }
      }
    } else {
      return false;
    }
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

  // BuildContext selectedContext;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        getSettings();
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  LocalNotificationModel _reminder(CombinePrayerStream? prayerData) {
    final reminders = Provider.of<NotificationProvider>(context, listen: false)
        .localNotifications;
    return reminders.firstWhere(
        (reminder) => reminder.entityId == (prayerData?.userPrayer?.id ?? ''),
        orElse: () => LocalNotificationModel.defaultValue());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showPrayerActions: false,
      ),
      body: StreamBuilder<CombinePrayerStream>(
          stream: Provider.of<PrayerProvider>(context).getPrayer(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return BeStilDialog.getLoading(context);
            if (snapshot.hasData) {
              return Container(
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
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.zero),
                            ),
                            icon: Icon(
                              AppIcons.bestill_back_arrow,
                              color: AppColors.lightBlue3,
                              size: 20,
                            ),
                            onPressed: () {
                              AppController appController = Get.find();
                              appController.setCurrentPage(0, true, 7);
                            },
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
                                  icon: Icon(Icons.build,
                                      color: AppColors.lightBlue3),
                                  onPressed: () => showModalBottomSheet(
                                    context: context,
                                    barrierColor: Provider.of<ThemeProvider>(
                                                context,
                                                listen: false)
                                            .isDarkModeEnabled
                                        ? AppColors.backgroundColor[0]
                                            .withOpacity(0.8)
                                        : Color(0xFF021D3C).withOpacity(0.7),
                                    backgroundColor: Provider.of<ThemeProvider>(
                                                context,
                                                listen: false)
                                            .isDarkModeEnabled
                                        ? AppColors.backgroundColor[0]
                                            .withOpacity(0.8)
                                        : Color(0xFF021D3C).withOpacity(0.7),
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return _buildMenu(snapshot.data,
                                          _reminder(snapshot.data));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if ((snapshot.data?.userPrayer ??
                                UserPrayerModel.defaultValue())
                            .isSnoozed ??
                        false)
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                                        isGroup: false,
                                        entityId:
                                            snapshot.data?.userPrayer?.id ?? '',
                                        type: NotificationType.reminder,
                                        reminder: _reminder(snapshot.data),
                                        hideActionuttons: false,
                                        onCancel: () =>
                                            Navigator.of(context).pop(),
                                        prayerData: snapshot.data,
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
                                    'Snoozed until ${DateFormat('MMM').format(snapshot.data?.userPrayer?.snoozeEndDate ?? DateTime.now())} ${getDayText(snapshot.data?.userPrayer?.snoozeEndDate?.day)}, ${DateFormat('yyyy h:mm a').format(snapshot.data?.userPrayer?.snoozeEndDate ?? DateTime.now())}',
                                    style: AppTextStyles.regularText12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                      ]),
                    hasReminder(snapshot.data) &&
                            isReminderActive(snapshot.data)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () => showDialog(
                                  context: context,
                                  barrierColor: AppColors
                                      .detailBackgroundColor[1]
                                      .withOpacity(0.5),
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      insetPadding: EdgeInsets.all(20),
                                      backgroundColor:
                                          AppColors.prayerCardBgColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: AppColors.darkBlue),
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
                                              isGroup: false,
                                              entityId: snapshot
                                                      .data?.userPrayer?.id ??
                                                  '',
                                              type: NotificationType.reminder,
                                              reminder:
                                                  _reminder(snapshot.data),
                                              hideActionuttons: false,
                                              popTwice: false,
                                              onCancel: () =>
                                                  Navigator.of(context).pop(),
                                              prayerData: snapshot.data,
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
                                      child: Text(reminderString(snapshot.data),
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
                    if (((snapshot.data?.prayer ?? PrayerModel.defaultValue())
                                .id ??
                            '')
                        .isNotEmpty)
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
                          child: (snapshot.data?.updates ?? []).length > 0
                              ? UpdateView(snapshot.data)
                              : NoUpdateView(snapshot.data),
                        ),
                      ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              );
            }
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 60),
              child: Column(
                children: [
                  Opacity(
                    opacity: 0.3,
                    child: Text(
                      'This prayer no longer exists',
                      style: AppTextStyles.demiboldText34,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      AppController appController = Get.find();
                      appController.setCurrentPage(0, true, 7);
                    },
                    child: Container(
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      // width: MediaQuery.of(context).size.width * .30,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'Go to prayer list',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
