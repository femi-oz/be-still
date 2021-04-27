import 'dart:async';
import 'dart:convert';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/add_update/add_update.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/menu-button.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/share_prayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'delete_prayer.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PrayerMenu extends StatefulWidget {
  final BuildContext parentcontext;
  final bool hasReminder;
  final Function updateUI;
  final LocalNotificationModel reminder;
  @override
  PrayerMenu(
      this.parentcontext, this.hasReminder, this.reminder, this.updateUI);

  @override
  _PrayerMenuState createState() => _PrayerMenuState();
}

class _PrayerMenuState extends State<PrayerMenu> {
  var selectedInterval;
  var selectedDuration;
  var selectedDurationIndex;
  var selectedIntervalIndex;
  int minutes;
  List<String> reminderInterval = [
    // 'Hourly',
    Frequency.daily,
    Frequency.weekly,
    // 'Monthly',
    // 'Yearly'
  ];
  // List<String> snoozeInterval = [
  //   '7 Days',
  //   '14 Days',
  //   '30 Days',
  //   '90 Days',
  //   '1 Year'
  // ];

  List<String> snoozeInterval = ['Minutes', 'Days', 'Weeks', 'Months'];

  List<String> snoozeDuration = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
  ];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  _markPrayerAsFavorite(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(
        context,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .favoritePrayer(prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
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

  _unMarkPrayerAsFavorite(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(
        context,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .unfavoritePrayer(prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
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

  @override
  void initState() {
    super.initState();
  }

  // _setDefaultSnooze() async {
  //   switch (selectedInterval) {
  //     // case 'Minutes':
  //     //   minutes = 1;
  //     //   break;
  //     case 'Days':
  //       minutes = 1440;
  //       break;
  //     case 'Weeks':
  //       minutes = 10080;
  //       break;
  //     case 'Months':
  //       minutes = 43800;
  //       break;
  //     default:
  //   }

  //   var settingsId =
  //       Provider.of<SettingsProvider>(context, listen: false).settings.id;

  //   var e = int.parse(selectedDuration) * minutes;
  //   try {
  //     BeStilDialog.showLoading(
  //       context,
  //     );
  //     await Provider.of<SettingsProvider>(context, listen: false)
  //         .updateSettings(
  //             Provider.of<UserProvider>(context, listen: false).currentUser.id,
  //             key: SettingsKey.defaultSnoozeDurationMins,
  //             value: e,
  //             settingsId: settingsId);
  //     await Future.delayed(Duration(milliseconds: 300));
  //     BeStilDialog.hideLoading(context);
  //   } on HttpException catch (e) {
  //     await Future.delayed(Duration(milliseconds: 300));
  //     BeStilDialog.hideLoading(context);
  //     BeStilDialog.showErrorDialog(context, e.message);
  //   } catch (e) {
  //     await Future.delayed(Duration(milliseconds: 300));
  //     BeStilDialog.hideLoading(context);
  //     BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
  //   }
  // }

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
      );
      if (widget.hasReminder)
        _updatePrayerTime(
          selectedDay,
          period,
          selectedFrequency,
          selectedHour,
          selectedMinute,
          scheduleDate,
          userId,
          notificationText,
        );
      else
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
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
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
        .addLocalNotification(
      LocalNotification.localNotificationID,
      prayerid,
      notificationText,
      userId,
      prayerid,
      title,
      description,
      frequency,
      NotificationType.reminder,
      scheduledDate,
      selectedDay,
      period,
      selectedHour,
      selectedMinute,
    );
    await Future.delayed(Duration(milliseconds: 300));
    BeStilDialog.hideLoading(context);

    NavigationService.instance.goHome(0);
  }

  _updatePrayerTime(
    String selectedDay,
    String selectedPeriod,
    String selectedFrequency,
    String selectedHour,
    String selectedMinute,
    tz.TZDateTime scheduledDate,
    String userId,
    String notificationText,
  ) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .updateLocalNotification(
      selectedFrequency,
      scheduledDate,
      selectedDay,
      selectedPeriod,
      selectedHour,
      selectedMinute,
      widget.reminder.id,
      userId,
      notificationText,
    );
    await Future.delayed(Duration(milliseconds: 300));
    BeStilDialog.hideLoading(context);

    NavigationService.instance.goHome(0);
  }

  void _onMarkAsAnswered(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<PrayerProvider>(context, listen: false)
          .markPrayerAsAnswered(prayerData.prayer.id, prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
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

  void _unMarkAsAnswered(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<PrayerProvider>(context, listen: false)
          .unMarkPrayerAsAnswered(
              prayerData.prayer.id, prayerData.userPrayer.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
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

  void _unArchive(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<PrayerProvider>(context, listen: false)
          .unArchivePrayer(prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  void _snoozePrayer(CombinePrayerStream prayerData) async {
    if (selectedInterval == null) {
      var selectedIntervalIndex = snoozeInterval
          .indexOf(snoozeInterval[int.parse(Settings.snoozeInterval)]);
      selectedInterval = snoozeInterval[selectedIntervalIndex];
    }
    if (selectedDuration == null) {
      var selectedDurationindex = snoozeDuration
          .indexOf(snoozeDuration[int.parse(Settings.snoozeDuration)]);
      selectedDuration = snoozeDuration[selectedDurationindex];
    }
    BeStilDialog.showLoading(context);
    switch (selectedInterval) {
      case 'Minutes':
        minutes = 1;
        break;
      case 'Days':
        minutes = 1440;
        break;
      case 'Weeks':
        minutes = 10080;
        break;
      case 'Months':
        minutes = 43800;
        break;
      default:
    }

    var e = int.parse(selectedDuration) * minutes;
    var _snoozeEndDate = DateTime.now().add(new Duration(minutes: e));
    try {
      await Provider.of<PrayerProvider>(context, listen: false).snoozePrayer(
          prayerData.prayer.id, _snoozeEndDate, prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pushReplacementNamed(EntryScreen.routeName);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  void _unSnoozePrayer(CombinePrayerStream prayerData) async {
    BeStilDialog.showLoading(context);

    try {
      await Provider.of<PrayerProvider>(context, listen: false).unSnoozePrayer(
          prayerData.prayer.id, DateTime.now(), prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pushReplacementNamed(EntryScreen.routeName);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  void _onArchive(CombinePrayerStream prayerData) async {
    try {
      BeStilDialog.showLoading(context);
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) => e.entityId == prayerData.prayer.id)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false)
          .archivePrayer(prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);

      NavigationService.instance.goHome(0);
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

  Widget build(BuildContext context) {
    CombinePrayerStream prayerData =
        Provider.of<PrayerProvider>(context).currentPrayer;
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  AppIcons.bestill_close,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: AppColors.textFieldText,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MenuButton(
                  icon: AppIcons.bestill_share,
                  text: 'Share',
                  isDisable: prayerData.prayer.isAnswer ||
                      prayerData.userPrayer.isArchived,
                  onPressed: () => showModalBottomSheet(
                      context: context,
                      barrierColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.5),
                      backgroundColor:
                          AppColors.detailBackgroundColor[1].withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SharePrayer(
                          prayerData: prayerData,
                        );
                      }),
                ),
                MenuButton(
                  icon: AppIcons.bestill_edit,
                  isDisable: prayerData.prayer.isAnswer ||
                      prayerData.userPrayer.isArchived,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPrayer(
                        isEdit: true,
                        prayerData: prayerData,
                      ),
                    ),
                  ),
                  text: 'Edit',
                ),
                MenuButton(
                  icon: AppIcons.bestill_update,
                  isDisable: prayerData.prayer.isAnswer ||
                      prayerData.userPrayer.isArchived,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddUpdate(
                        prayerData: prayerData,
                      ),
                    ),
                  ),
                  text: 'Add an Update',
                ),
                MenuButton(
                  icon: AppIcons.bestill_reminder,
                  isDisable: prayerData.prayer.isAnswer ||
                      prayerData.userPrayer.isArchived,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    barrierColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.5),
                    backgroundColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.9),
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
                                prayerData),
                        selectedFrequency: widget.hasReminder
                            ? widget.reminder.frequency
                            : null,
                        selectedHour: widget.hasReminder
                            ? int.parse(widget.reminder.selectedHour)
                            : null,
                        selectedMinute: widget.hasReminder
                            ? int.parse(widget.reminder.selectedMinute)
                            : null,
                        selectedPeriod:
                            widget.hasReminder ? widget.reminder.period : null,
                      );
                    },
                  ),
                  text: widget.hasReminder ? 'Edit Reminder' : 'Set Reminder',
                ),
                MenuButton(
                  icon: AppIcons.bestill_snooze,
                  isDisable: prayerData.prayer.isAnswer ||
                      prayerData.userPrayer.isArchived,
                  onPressed: () => prayerData.userPrayer.isSnoozed
                      ? _unSnoozePrayer(prayerData)
                      : showModalBottomSheet(
                          context: context,
                          barrierColor: AppColors.detailBackgroundColor[1]
                              .withOpacity(0.5),
                          backgroundColor: AppColors.detailBackgroundColor[1]
                              .withOpacity(0.9),
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return Container(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      height: 200,
                                      child: Column(
                                        children: <Widget>[
                                          Text('Set Snooze Duration',
                                              style:
                                                  AppTextStyles.regularText15),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    child: CupertinoPicker(
                                                      scrollController: FixedExtentScrollController(
                                                          initialItem: snoozeInterval
                                                              .indexOf(snoozeInterval[
                                                                  int.parse(Settings
                                                                      .snoozeInterval)])),
                                                      itemExtent: 30,
                                                      onSelectedItemChanged:
                                                          (i) => setState(() {
                                                        selectedInterval =
                                                            snoozeInterval[i];
                                                        selectedIntervalIndex =
                                                            snoozeInterval.indexOf(
                                                                snoozeInterval[
                                                                    i]);
                                                        Settings.snoozeInterval =
                                                            selectedIntervalIndex
                                                                .toString();

                                                        // widget.onChange(selectedInterval.value);
                                                      }),
                                                      children: <Widget>[
                                                        ...snoozeInterval
                                                            .map(
                                                              (i) => Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(i,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: AppTextStyles
                                                                          .regularText15)),
                                                            )
                                                            .toList(),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    child: CupertinoPicker(
                                                      scrollController: FixedExtentScrollController(
                                                          initialItem: snoozeDuration
                                                              .indexOf(snoozeDuration[
                                                                  int.parse(Settings
                                                                      .snoozeDuration)])),
                                                      itemExtent: 30,
                                                      onSelectedItemChanged:
                                                          (i) => setState(() {
                                                        selectedDuration =
                                                            snoozeDuration[i];
                                                        selectedDurationIndex =
                                                            snoozeDuration.indexOf(
                                                                selectedDuration);
                                                        Settings.snoozeDuration =
                                                            selectedDurationIndex
                                                                .toString();

                                                        // widget.onChange(selectedInterval.value);
                                                      }),
                                                      children: <Widget>[
                                                        ...snoozeDuration
                                                            .map(
                                                              (i) => Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(i,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: AppTextStyles
                                                                          .regularText15)),
                                                            )
                                                            .toList(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 40),
                                    width: double.infinity,
                                    child: Row(
                                      children: <Widget>[
                                        CustomButtonGroup(
                                          title: 'SNOOZE',
                                          onSelected: (_) {
                                            _snoozePrayer(prayerData);
                                          },
                                          length: 2,
                                          index: 0,
                                        ),
                                        CustomButtonGroup(
                                          title: 'CANCEL',
                                          onSelected: (_) {
                                            Navigator.of(context).pop();
                                          },
                                          length: 2,
                                          index: 0,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                  text: prayerData.userPrayer.isSnoozed ? 'Unsnooze' : 'Snooze',
                ),
                MenuButton(
                  icon: AppIcons.bestill_answered,
                  onPressed: () => prayerData.prayer.isAnswer
                      ? _unMarkAsAnswered(prayerData)
                      : _onMarkAsAnswered(prayerData),
                  text: prayerData.prayer.isAnswer
                      ? 'Unmark as Answered'
                      : 'Mark as Answered',
                ),
                MenuButton(
                  icon: prayerData.userPrayer.isFavorite
                      ? Icons.favorite_border_outlined
                      : Icons.favorite,
                  onPressed: () => prayerData.userPrayer.isFavorite
                      ? _unMarkPrayerAsFavorite(prayerData)
                      : _markPrayerAsFavorite(prayerData),
                  text: prayerData.userPrayer.isFavorite
                      ? 'Unmark as Favorite '
                      : 'Mark as Favorite ',
                ),
                MenuButton(
                  icon: AppIcons.bestill_archive,
                  onPressed: () => prayerData.userPrayer.isArchived
                      ? _unArchive(prayerData)
                      : _onArchive(prayerData),
                  text: prayerData.userPrayer.isArchived
                      ? 'Unarchive'
                      : 'Archive',
                ),
                MenuButton(
                  icon: AppIcons.bestill_delete,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    barrierColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.5),
                    backgroundColor:
                        AppColors.detailBackgroundColor[1].withOpacity(0.9),
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return DeletePrayer(prayerData);
                    },
                  ),
                  text: 'Delete',
                ),
              ],
            ),
          ),
          // IconButton(
          //   icon: Icon(
          //     AppIcons.bestill_close,
          //   ),
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //   },
          //   color: AppColors.textFieldText,
          // ),
        ],
      ),
    );
  }
}
