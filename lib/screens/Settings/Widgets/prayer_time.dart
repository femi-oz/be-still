import 'package:be_still/enums/reminder.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_input_button.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/snooze_picker.dart';
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
  var snooze;
  var reminder;

  setSnooze(value) {
    setState(() {
      snooze = value;
    });
  }

  List<String> songs = [
    'Evening Listening',
    'Rock Jams',
    'Prayer Time',
    'Jason Station',
    'New Hits'
  ];

  List<String> reminderInterval = [
    ReminderFrequency.daily,
    ReminderFrequency.weekly,
    ReminderFrequency.t_th,
    ReminderFrequency.m_w_f,
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

  _savePrayerTime(String selectedDay, String selectedFrequency, DateTime date) {
    // TODO save prayer time service
    print('$selectedDay, $selectedFrequency, $date');
  }

  bool _addPrayerTypeMode = false;

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          Column(
            children: [
              CustomSectionHeder('Preference'),
              SizedBox(height: 20),
              CustomToggle(
                onChange: () => null,
                title:
                    'Allow emergency calls (second call from the same number calls within 2 minutes)',
                value: widget.prayerSettings.allowEmergencyCalls,
              ),
              CustomToggle(
                onChange: () => null,
                title: 'Set to Do Not Disturb during Prayer Time?',
                value: widget.prayerSettings.doNotDisturb,
              ),
              CustomToggle(
                onChange: () => null,
                title: 'Enable background music during Prayer Mode?',
                value: widget.prayerSettings.enableBackgroundMusic,
              ),
              SizedBox(height: 20),
              CustomInputButton(
                actionColor: AppColors.lightBlue4,
                actionText: 'CONNECTED',
                icon: 'assets/images/spotify.png',
                onPressed: () => null,
                isDarkModeEnabled: _themeProvider.isDarkModeEnabled,
                value: 'Spotify',
              ),
              Container(
                child: SnoozePicker(songs, setSnooze, true, 2),
              ),
              CustomToggle(
                title: 'Auto play music during prayer time?',
                onChange: () => null,
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
                        onSave: (selectedDay, selectedFrequency, date) =>
                            _savePrayerTime(
                                selectedDay, selectedFrequency, date),
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
