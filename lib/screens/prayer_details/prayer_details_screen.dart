import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/widgets/no_update_view.dart';
import 'package:be_still/screens/prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/screens/prayer_details/widgets/update_view.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

class PrayerDetails extends StatefulWidget {
  static const routeName = 'prayer-details';

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
    return PrayerMenu(context, hasReminder, _reminder, () => updateUI());
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

  BuildContext selectedContext;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle('');
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
                    onPressed: () => Navigator.of(context).pop(),
                    label: Text(
                      'BACK',
                      style: AppTextStyles.boldText20.copyWith(
                        color: AppColors.lightBlue3,
                      ),
                    ),
                  ),
                  hasReminder
                      ? InkWell(
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Transform.rotate(
                      angle: 180 * math.pi,
                      child: IconButton(
                        icon: Icon(
                          Icons.build,
                          color: AppColors.lightBlue3,
                        ),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          barrierColor: AppColors.detailBackgroundColor[1]
                              .withOpacity(0.5),
                          backgroundColor:
                              AppColors.detailBackgroundColor[1].withOpacity(1),
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return _buildMenu();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
