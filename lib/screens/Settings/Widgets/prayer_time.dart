import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/duration.model.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerTimeSettings extends StatefulWidget {
  final PrayerSettingsModel prayerSettings;
  final SettingsModel settings;

  @override
  PrayerTimeSettings(this.prayerSettings, this.settings);
  _PrayerTimeSettingsState createState() => _PrayerTimeSettingsState();
}

class _PrayerTimeSettingsState extends State<PrayerTimeSettings> {
  @override
  void initState() {
    LocalNotification.configureNotification(context, PrayerMode.routeName);
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

  setNotification(selectedHour, selectedFrequency, selectedMinute, selectedDay,
      period, userId) async {
    try {
      BeStilDialog.showLoading(context);
      final notificationText = selectedFrequency == Frequency.weekly
          ? '$selectedFrequency, $selectedDay, $selectedHour:$selectedMinute $period'
          : '$selectedFrequency, $selectedHour:$selectedMinute $period';
      final title = '$selectedFrequency reminder to pray';
      final description =
          'Hi, it is time for your ${selectedFrequency.toString().toLowerCase()} prayers';
      final scheduleDate = LocalNotification.scheduleDate(
          selectedHour, selectedMinute, selectedDay, period);
      await LocalNotification.setLocalNotification(
          title: title,
          description: description,
          scheduledDate: scheduleDate,
          payload: userId,
          frequency: selectedFrequency);
      await storeNotification(notificationText, userId, title, description,
          selectedFrequency, scheduleDate);
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
  ) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .addLocalNotification(
      LocalNotification.localNotificationId,
      userId,
      notificationText,
      userId,
      PrayerMode.routeName,
      userId,
      title,
      description,
      frequency,
      NotificationType.prayer_time,
      scheduledDate,
    );
    await Future.delayed(Duration(milliseconds: 300));
    BeStilDialog.hideLoading(context);
    setState(() => _addPrayerTypeMode = false);
  }

  _savePrayerTime(selectedDay, selectedFrequency, period, selectedHour,
      selectedMinute) async {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    setNotification(selectedHour, selectedFrequency, selectedMinute,
        selectedDay, period, userId);
  }

  bool _addPrayerTypeMode = false;

  @override
  Widget build(BuildContext context) {
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
          SizedBox(height: 30),
          CustomSectionHeder('My Prayer Time'),
          Column(
            children: [
              !_addPrayerTypeMode
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 40),
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
                        onSave: (selectedFrequency, selectedHour,
                                selectedMinute, selectedDay, selectedPeriod) =>
                            _savePrayerTime(selectedDay, selectedFrequency,
                                selectedPeriod, selectedHour, selectedMinute),
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
