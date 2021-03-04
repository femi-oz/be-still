import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/duration.model.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_input_button.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/custom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class PrayerTimeSettings extends StatefulWidget {
  final PrayerSettingsModel prayerSettings;
  final SettingsModel settings;

  @override
  PrayerTimeSettings(this.prayerSettings, this.settings);
  _PrayerTimeSettingsState createState() => _PrayerTimeSettingsState();
}

class _PrayerTimeSettingsState extends State<PrayerTimeSettings> {
  var snooze;
  var reminder;

  setSnooze(value) {
    setState(() {
      snooze = value;
    });
  }

  String currentTimeZone;

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();

    currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    _configureLocalTimeZone();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSetttings);
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

  List<String> reminderDays = [
    DaysOfWeek.sun,
    DaysOfWeek.mon,
    DaysOfWeek.tue,
    DaysOfWeek.wed,
    DaysOfWeek.thu,
    DaysOfWeek.fri,
    DaysOfWeek.sat,
  ];

  setReminder(value) {
    setState(() {
      reminder = value;
    });
  }

  int _getExactDy(day) {
    var now = new DateTime.now();

    while (now.weekday != day) {
      now = now.subtract(new Duration(days: 1));
    }
    return now.day;
  }

  tz.TZDateTime _scheduleDate(
      selectedHour, selectedMinute, selectedDay, period) {
    // print(selectedDay);
    // print(selectedMinute);
    // print(selectedHour);
    // print(period);
    var day = reminderDays.indexOf(selectedDay) + 1;
    var hour = period == PeriodOfDay.am ? selectedHour : selectedHour + 12;
    hour = hour == 24 ? 00 : hour;
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, _getExactDy(day), hour, selectedMinute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  setNotification(selectedHour, selectedFrequency, selectedMinute, selectedDay,
      period, userId) async {
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
        '$selectedFrequency reminder to pray',
        'Hi, it is time to for your ${selectedFrequency.toString().toLowerCase()} prayer',
        _scheduleDate(selectedHour, selectedMinute, selectedDay, period),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name', 'your channel description'),
            iOS: IOSNotificationDetails()),
        payload: userId,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: selectedFrequency.toString().toLowerCase() ==
                Frequency.daily.toLowerCase()
            ? DateTimeComponents.time
            : DateTimeComponents
                .dayOfWeekAndTime); //daily:time,weekly:dayOfWeekAndTime
    var notificationText = selectedFrequency == Frequency.weekly
        ? '$selectedFrequency, $selectedDay, $selectedHour:$selectedMinute $period'
        : '$selectedFrequency, $selectedHour:$selectedMinute $period';
    await storeNotification(localId, notificationText, userId);
  }

  storeNotification(localId, notificationText, userId) async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<NotificationProvider>(context, listen: false)
          .addLocalNotification(localId, userId, notificationText);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      setState(() => _addPrayerTypeMode = false);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  _savePrayerTime(selectedDay, selectedFrequency, period, selectedHour,
      selectedMinute) async {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    await Provider.of<SettingsProvider>(context, listen: false)
        .updatePrayerSettings(userId,
            key: SettingsKey.day,
            value: selectedDay,
            settingsId: widget.prayerSettings.id);
    await Provider.of<SettingsProvider>(context, listen: false)
        .updatePrayerSettings(userId,
            key: SettingsKey.frequency,
            value: selectedFrequency,
            settingsId: widget.prayerSettings.id);
    await Provider.of<SettingsProvider>(context, listen: false)
        .updatePrayerSettings(userId,
            key: SettingsKey.time,
            value: period,
            settingsId: widget.prayerSettings.id);

    // await Provider.of<NotificationProvider>(context, listen: false)
    //     .addLocalNotification(localId, userId, notificationText);

    setNotification(selectedHour, selectedFrequency, selectedMinute,
        selectedDay, period, userId);
  }

  bool _addPrayerTypeMode = false;

  @override
  Widget build(BuildContext context) {
    final setingProvider = Provider.of<SettingsProvider>(context);
    final userId = Provider.of<UserProvider>(context).currentUser.id;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          Column(
            children: [
              CustomSectionHeder('Preference'),
              SizedBox(height: 20),
              CustomToggle(
                onChange: (value) => setingProvider.updatePrayerSettings(userId,
                    key: SettingsKey.allowEmergencyCalls,
                    value: value,
                    settingsId: widget.prayerSettings.id),
                title:
                    'Allow emergency calls (second call from the same number calls within 2 minutes)',
                value: widget.prayerSettings.allowEmergencyCalls,
              ),
              CustomToggle(
                onChange: (value) => setingProvider.updatePrayerSettings(userId,
                    key: SettingsKey.doNotDisturb,
                    value: value,
                    settingsId: widget.prayerSettings.id),
                title: 'Set to Do Not Disturb during Prayer Time?',
                value: widget.prayerSettings.doNotDisturb,
              ),
              CustomToggle(
                onChange: (value) => setingProvider.updatePrayerSettings(userId,
                    key: SettingsKey.enableBackgroundMusic,
                    value: value,
                    settingsId: widget.prayerSettings.id),
                title: 'Enable background music during Prayer Mode?',
                value: widget.prayerSettings.enableBackgroundMusic,
              ),
              SizedBox(height: 20),
              CustomOutlineButton(
                actionColor: AppColors.lightBlue4,
                actionText: 'CONNECTED',
                textIcon: 'assets/images/spotify.png',
                onPressed: () => null,
                value: 'Spotify',
              ),
              Container(
                child: CustomPicker(songs, setSnooze, true, 3),
              ),
              CustomToggle(
                title: 'Auto play music during prayer time?',
                onChange: (value) => setingProvider.updatePrayerSettings(userId,
                    key: SettingsKey.autoPlayMusic,
                    value: value,
                    settingsId: widget.prayerSettings.id),
                value: widget.prayerSettings.autoPlayMusic,
              ),
            ],
          ),
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
                        reminderDays: reminderDays,
                        onCancel: () =>
                            setState(() => _addPrayerTypeMode = false),
                        onSave: (selectedFrequency, selectedHour,
                                selectedMinute, selectedDay, selectedPeriod) =>
                            _savePrayerTime(
                                selectedDay,
                                selectedFrequency,
                                selectedPeriod,
                                selectedHour,
                                selectedMinute), // TODO pass the right value
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
