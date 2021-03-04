import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/duration.model.dart';
import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/custom_input_button.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/custom_picker.dart';
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

  _savePrayerTime(
      String selectedDay, String selectedFrequency, String date) async {
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
            value: date,
            settingsId: widget.prayerSettings.id);
    setState(() => _addPrayerTypeMode = false);
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
                        onSave: (selectedDay, selectedFrequency, date) =>
                            _savePrayerTime(selectedDay, selectedFrequency,
                                date), // TODO pass the right value
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
