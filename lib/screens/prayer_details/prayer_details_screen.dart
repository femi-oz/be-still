import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/v2/local_notification.model.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/theme_provider.dart';
import 'package:be_still/screens/prayer_details/widgets/no_update_view.dart';
import 'package:be_still/screens/prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/screens/prayer_details/widgets/update_view.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
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
  Duration snoozeDurationinDays = Duration.zero;
  DateTime snoozeEndDate = DateTime.now();
  Duration snoozeDurationinHour = Duration.zero;
  Duration snoozeDurationinMinutes = Duration.zero;
  String durationText = '';
  int snoozeDuration = 0;
  // String reminderString = '';

  String selectedFrequency = '';

  Widget _buildMenu(
      PrayerDataModel? prayerData, LocalNotificationDataModel reminder) {
    return PrayerMenu(context, hasReminder(prayerData), reminder,
        () => updateUI(), prayerData);
  }

  String reminderString(PrayerDataModel? prayerData) {
    final reminders = Provider.of<NotificationProviderV2>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();

    LocalNotificationDataModel? reminder = reminders.firstWhere(
        (reminder) => reminder.prayerId == (prayerData?.id ?? ''),
        orElse: () => LocalNotificationDataModel());
    return reminder.message ?? '';
  }

  bool hasReminder(PrayerDataModel? prayerData) {
    final reminders = Provider.of<NotificationProviderV2>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();

    return reminders
        .any((reminder) => reminder.prayerId == (prayerData?.id ?? ''));
  }

  bool isReminderActive(PrayerDataModel? prayerData) {
    final reminders = Provider.of<NotificationProviderV2>(context)
        .localNotifications
        .where((e) => e.type == NotificationType.reminder)
        .toList();

    LocalNotificationDataModel rem = reminders.firstWhere(
        (reminder) => reminder.prayerId == prayerData?.id,
        orElse: () => LocalNotificationDataModel());
    if ((rem.id ?? '').isNotEmpty) {
      if (rem.frequency != Frequency.one_time) {
        return true;
      } else {
        if ((rem.scheduleDate ?? DateTime.now().subtract(Duration(hours: 1)))
            .isAfter(DateTime.now())) {
          return true;
        } else {
          Provider.of<NotificationProviderV2>(context).deleteLocalNotification(
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

  @override
  void initState() {
    super.initState();
    getPrayer();
  }

  getPrayer() async {
    final prayerId =
        Provider.of<PrayerProviderV2>(context, listen: false).currentPrayerId;
    await Provider.of<PrayerProviderV2>(context, listen: false)
        .getPrayer(prayerId: prayerId);
  }

  // BuildContext selectedContext;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // getSettings();
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  LocalNotificationDataModel _reminder(PrayerDataModel? prayerData) {
    final reminders =
        Provider.of<NotificationProviderV2>(context, listen: false)
            .localNotifications;
    return reminders.firstWhere(
        (reminder) => reminder.prayerId == (prayerData?.id ?? ''),
        orElse: () => LocalNotificationDataModel());
  }

  @override
  Widget build(BuildContext context) {
    final prayerData = Provider.of<PrayerProviderV2>(context).prayer;

    return Scaffold(
        appBar: CustomAppBar(
          showPrayerActions: false,
        ),
        body: prayerData.status != Status.deleted
            ? Container(
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
                                    barrierColor: Provider.of<ThemeProviderV2>(
                                                context,
                                                listen: false)
                                            .isDarkModeEnabled
                                        ? AppColors.backgroundColor[0]
                                            .withOpacity(0.8)
                                        : Color(0xFF021D3C).withOpacity(0.7),
                                    backgroundColor:
                                        Provider.of<ThemeProviderV2>(context,
                                                    listen: false)
                                                .isDarkModeEnabled
                                            ? AppColors.backgroundColor[0]
                                                .withOpacity(0.8)
                                            : Color(0xFF021D3C)
                                                .withOpacity(0.7),
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return _buildMenu(
                                          prayerData, _reminder(prayerData));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if ((prayerData.status == Status.snoozed))
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Row(
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
                                  'Snoozed until ${DateFormat('MMM').format(prayerData.snoozeEndDate ?? DateTime.now())} ${getDayText(prayerData.snoozeEndDate?.day)}, ${DateFormat('yyyy h:mm a').format(prayerData.snoozeEndDate ?? DateTime.now())}',
                                  style: AppTextStyles.regularText12),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                      ]),
                    hasReminder(prayerData) && isReminderActive(prayerData)
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
                                              entityId: prayerData.id ?? '',
                                              type: NotificationType.reminder,
                                              reminder: _reminder(prayerData),
                                              hideActionuttons: false,
                                              popTwice: false,
                                              onCancel: () =>
                                                  Navigator.of(context).pop(),
                                              prayerData: prayerData,
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
                                      child: Text(reminderString(prayerData),
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
                    if (((prayerData.id) ?? '').isNotEmpty)
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
                          child: (prayerData.updates ?? []).length > 0
                              ? UpdateView(prayerData)
                              : NoUpdateView(prayerData),
                        ),
                      ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              )
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 60),
                child: Column(
                  children: [
                    Opacity(
                      opacity: 0.3,
                      child: Text(
                        'This prayer is no longer available',
                        style: AppTextStyles.demiboldText34,
                        textAlign: TextAlign.center,
                      ),
                    ).marginOnly(bottom: 50),
                    Container(
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: AppColors.lightBlue4,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: OutlinedButton(
                        onPressed: () {
                          AppController appController = Get.find();
                          appController.setCurrentPage(0, true, 7);
                        },
                        style: ButtonStyle(
                          side: MaterialStateProperty.all<BorderSide>(
                              BorderSide(color: Colors.transparent)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'Go to my prayers',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ).paddingSymmetric(horizontal: 10, vertical: 5),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
