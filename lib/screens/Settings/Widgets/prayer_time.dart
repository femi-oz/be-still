import 'dart:convert';

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
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

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

  List<LookUp> songs = [
    LookUp(text: 'Evening Listening', value: 1),
    LookUp(text: 'Rock Jams', value: 2),
    LookUp(text: 'Prayer Time', value: 3),
    LookUp(text: 'Jason Station', value: 4),
    LookUp(text: 'New Hits', value: 5)
  ];

  List<String> reminderInterval = [
    Frequency.daily,
    Frequency.weekly,
    Frequency.t_th,
    Frequency.m_w_f,
  ];
  double itemExtent = 30.0;
  bool _addPrayerTypeMode = false;
  bool showUpdateField = false;
  LocalNotificationModel notification;

  setNotification(selectedHour, selectedFrequency, selectedMinute, selectedDay,
      period, userId, bool isEdit, int localNotificationId) async {
    try {
      BeStilDialog.showLoading(context);
      final notificationText = selectedFrequency == Frequency.weekly
          ? '$selectedFrequency, $selectedDay, $selectedHour:$selectedMinute $period'
          : '$selectedFrequency, $selectedHour:$selectedMinute $period';
      final title = '$selectedFrequency reminder to pray';
      final description =
          'Hi, it is time for your ${selectedFrequency.toString().toLowerCase()} prayers';
      final scheduleDate = LocalNotification.scheduleDate(
          int.parse(selectedHour),
          int.parse(selectedMinute),
          selectedDay,
          period);
      final payload = NotificationMessage(
          entityId: userId, type: NotificationType.prayer_time);
      await LocalNotification.setLocalNotification(
        title: title,
        description: description,
        scheduledDate: scheduleDate,
        payload: jsonEncode(payload.toJson()),
        frequency: selectedFrequency,
        context: context,
        localNotificationId: localNotificationId,
      );
      if (isEdit)
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
          selectedDay,
          period,
          selectedHour.toString(),
          selectedMinute.toString(),
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
    DateTime scheduledDate,
    String selectedDay,
    String period,
    String selectedHour,
    String selectedMinute,
  ) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .addLocalNotification(
            LocalNotification.localNotificationID,
            userId,
            notificationText,
            userId,
            userId,
            title,
            description,
            frequency,
            NotificationType.prayer_time,
            scheduledDate,
            selectedDay,
            period,
            selectedHour,
            selectedMinute);
    await Future.delayed(Duration(milliseconds: 300));
    BeStilDialog.hideLoading(context);
    setState(() => _addPrayerTypeMode = false);
  }

  _savePrayerTime(selectedDay, selectedFrequency, period, selectedHour,
      selectedMinute) async {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    setNotification(selectedHour, selectedFrequency, selectedMinute,
        selectedDay, period, userId, false, null);
  }

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
      notification.id,
      userId,
      notificationText,
    );
    await Future.delayed(Duration(milliseconds: 300));
    BeStilDialog.hideLoading(context);
    setState(() => showUpdateField = false);
  }

  // _deleteTimerModal(BuildContext context, String prayerTimeId) {
  //   return Container(
  //     width: double.infinity,
  //     height: double.infinity,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: <Widget>[
  //         Container(
  //           padding: EdgeInsets.symmetric(horizontal: 100),
  //           child: Text(
  //             'Are you sure you want to delete this prayer time?',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: AppColors.lightBlue4,
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               height: 1.5,
  //             ),
  //           ),
  //         ),
  //         GestureDetector(
  //           onTap: _deletePrayerTime(prayerTimeId),
  //           child: Container(
  //             height: 30,
  //             width: double.infinity,
  //             margin: EdgeInsets.all(40),
  //             decoration: BoxDecoration(
  //               border: Border.all(
  //                 color: AppColors.red,
  //                 width: 1,
  //               ),
  //               borderRadius: BorderRadius.circular(5),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: <Widget>[
  //                 Text(
  //                   'DELETE',
  //                   style: TextStyle(
  //                     color: AppColors.red,
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         GestureDetector(
  //           onTap: () {
  //             Navigator.of(context).pop();
  //           },
  //           child: Container(
  //             height: 30,
  //             width: MediaQuery.of(context).size.width * .38,
  //             decoration: BoxDecoration(
  //               border: Border.all(
  //                 color: AppColors.cardBorder,
  //                 width: 1,
  //               ),
  //               borderRadius: BorderRadius.circular(5),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: <Widget>[
  //                 Text(
  //                   'CANCEL',
  //                   style: TextStyle(
  //                     color: AppColors.lightBlue4,
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final prayerTimeList =
        Provider.of<NotificationProvider>(context, listen: false)
            .prayerTimeNotifications;
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;

    // final setingProvider = Provider.of<SettingsProvider>(context);
    // final userId = Provider.of<UserProvider>(context).currentUser.id;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // SizedBox(height: 30),
          // Column(
          //   children: [
          //     CustomSectionHeder('Preference'),
          //     SizedBox(height: 20),
          //     CustomToggle(
          //       onChange: (value) => setingProvider.updatePrayerSettings(userId,
          //           key: SettingsKey.allowEmergencyCalls,
          //           value: value,
          //           settingsId: widget.prayerSettings.id),
          //       title:
          //           'Allow emergency calls (second call from the same number calls within 2 minutes)',
          //       value: widget.prayerSettings.allowEmergencyCalls,
          //     ),
          //     CustomToggle(
          //       onChange: (value) => setingProvider.updatePrayerSettings(userId,
          //           key: SettingsKey.doNotDisturb,
          //           value: value,
          //           settingsId: widget.prayerSettings.id),
          //       title: 'Set to Do Not Disturb during Prayer Time?',
          //       value: widget.prayerSettings.doNotDisturb,
          //     ),
          //     CustomToggle(
          //       onChange: (value) => setingProvider.updatePrayerSettings(userId,
          //           key: SettingsKey.enableBackgroundMusic,
          //           value: value,
          //           settingsId: widget.prayerSettings.id),
          //       title: 'Enable background music during Prayer Mode?',
          //       value: widget.prayerSettings.enableBackgroundMusic,
          //     ),
          //     SizedBox(height: 20),
          //     // CustomOutlineButton(
          //     //   actionColor: AppColors.lightBlue4,
          //     //   actionText: 'CONNECTED',
          //     //   textIcon: 'assets/images/spotify.png',
          //     //   onPressed: () => null,
          //     //   value: 'Spotify',
          //     // ),
          //     // Container(
          //     //   child: CustomPicker(songs, null, true, 3),
          //     // ),
          //     // CustomToggle(
          //     //   title: 'Auto play music during prayer time?',
          //     //   onChange: (value) => setingProvider.updatePrayerSettings(userId,
          //     //       key: SettingsKey.autoPlayMusic,
          //     //       value: value,
          //     //       settingsId: widget.prayerSettings.id),
          //     //   value: widget.prayerSettings.autoPlayMusic,
          //     // ),
          //   ],
          // ),
          SizedBox(height: 15),
          CustomSectionHeder('My Prayer Time'),
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
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: Text(
                                            data.frequency,
                                            style: AppTextStyles.regularText15
                                                .copyWith(
                                                    color: AppColors
                                                        .prayerTextColor),
                                          ),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05),
                                        data.frequency == Frequency.weekly
                                            ? Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.15,
                                                child: Text(
                                                  data.selectedDay,
                                                  style: AppTextStyles
                                                      .regularText15
                                                      .copyWith(
                                                          color: AppColors
                                                              .prayerTextColor),
                                                ),
                                              )
                                            : SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.15),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05),
                                        Text(
                                          data.selectedHour,
                                          style: AppTextStyles.regularText15
                                              .copyWith(
                                                  color: AppColors
                                                      .prayerTextColor),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          ':',
                                          style: AppTextStyles.regularText15
                                              .copyWith(
                                                  color: AppColors
                                                      .prayerTextColor),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          data.selectedMinute,
                                          style: AppTextStyles.regularText15
                                              .copyWith(
                                                  color: AppColors
                                                      .prayerTextColor),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          data.period,
                                          style: AppTextStyles.regularText15
                                              .copyWith(
                                                  color: AppColors
                                                      .prayerTextColor),
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
                                          notification = data;
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
                                          AppIcons.bestill_delete,
                                          size: 16,
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

                      // ...localNotifications.map((data) =>
                      // // ReminderPicker(
                      // //             hideActionuttons: false,
                      // //             frequency: data.frequency,
                      // //             reminderDays: LocalNotification.reminderDays,
                      // //             onCancel: () =>
                      // //                 setState(() => _addPrayerTypeMode = false),
                      // //             onSave: (selectedFrequency, selectedHour,
                      // //                     selectedMinute, selectedDay, selectedPeriod) =>
                      // //                 _savePrayerTime(
                      // //                     selectedDay,
                      // //                     selectedFrequency,
                      // //                     selectedPeriod,
                      // //                     selectedHour,
                      // //                     selectedMinute),
                      // //           ),

                      // )
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
                            title: 'ADD PRAYER TIME',
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
                        hideActionuttons: false,
                        frequency: reminderInterval,
                        reminderDays: LocalNotification.reminderDays,
                        onCancel: () =>
                            setState(() => _addPrayerTypeMode = false),
                        onSave: (String selectedFrequency,
                                String selectedHour,
                                String selectedMinute,
                                String selectedDay,
                                String selectedPeriod) =>
                            _savePrayerTime(selectedDay, selectedFrequency,
                                selectedPeriod, selectedHour, selectedMinute),
                      ),
                    )
                  : showUpdateField
                      ? Container(
                          margin: EdgeInsets.only(bottom: 80.0),
                          child: ReminderPicker(
                            hideActionuttons: false,
                            frequency: reminderInterval,
                            reminderDays: LocalNotification.reminderDays,
                            onCancel: () =>
                                setState(() => showUpdateField = false),
                            onSave: (
                              selectedFrequency,
                              selectedHour,
                              selectedMinute,
                              selectedDay,
                              selectedPeriod,
                            ) =>
                                setNotification(
                              selectedHour,
                              selectedFrequency,
                              selectedMinute,
                              selectedDay,
                              selectedPeriod,
                              user.id,
                              true,
                              notification.localNotificationId,
                            ),
                            selectedDay: LocalNotification.reminderDays
                                    .indexOf(notification.selectedDay) +
                                1,
                            selectedFrequency: notification.frequency,
                            selectedHour: int.parse(notification.selectedHour),
                            selectedMinute:
                                int.parse(notification.selectedMinute),
                            selectedPeriod: notification.period,
                          ),
                        )
                      : Container(),
              SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }
}
