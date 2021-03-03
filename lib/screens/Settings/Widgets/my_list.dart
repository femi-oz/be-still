import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/models/duration.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/custom_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyListSettings extends StatefulWidget {
  final SettingsModel settings;
  MyListSettings(this.settings);
  @override
  _MyListSettingsState createState() => _MyListSettingsState();
}

class _MyListSettingsState extends State<MyListSettings> {
  _setDefaultSnooze(e) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        Provider.of<UserProvider>(context, listen: false).currentUser.id,
        key: SettingsKey.defaultSnoozeDurationMins,
        value: e,
        settingsId: widget.settings.id);
  }

  _setAutoDelete(e) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        Provider.of<UserProvider>(context, listen: false).currentUser.id,
        key: SettingsKey.archiveAutoDeleteMins,
        value: e,
        settingsId: widget.settings.id);
  }

  List<LookUp> snoozeInterval = [
    LookUp(text: IntervalRange.thirtyMinutes, value: 30),
    LookUp(text: IntervalRange.oneHour, value: 60),
    LookUp(text: IntervalRange.sevenDays, value: 10080),
    LookUp(text: IntervalRange.fourtheenDays, value: 20160),
    LookUp(text: IntervalRange.thirtyDays, value: 43200),
    LookUp(text: IntervalRange.ninetyDays, value: 129600),
    LookUp(text: IntervalRange.oneYear, value: 525600),
  ];

  List<LookUp> autoDeleteInterval = [
    LookUp(text: IntervalRange.thirtyDays, value: 43200),
    LookUp(text: IntervalRange.ninetyDays, value: 129600),
    LookUp(text: IntervalRange.oneYear, value: 525600),
    LookUp(text: IntervalRange.twoYears, value: 1051200),
    LookUp(text: IntervalRange.never, value: 0),
  ];

  List<String> defaultSortBy = [SortType.date, SortType.tag];
  List<String> archiveSortBy = [SortType.date, SortType.tag, SortType.answered];
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final userId = Provider.of<UserProvider>(context).currentUser.id;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 15),
          Column(
            children: [
              CustomSectionHeder('Default Sort By'),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    for (int i = 0; i < defaultSortBy.length; i++)
                      CustomButtonGroup(
                        isSelected:
                            widget.settings.defaultSortBy == defaultSortBy[i],
                        onSelected: (value) => settingsProvider.updateSettings(
                            userId,
                            key: SettingsKey.defaultSortBy,
                            value: value,
                            settingsId: widget.settings.id),
                        title: defaultSortBy[i],
                        length: defaultSortBy.length,
                        index: i,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              CustomSectionHeder('Default Snooze Duration'),
              Container(
                child: CustomPicker(snoozeInterval, _setDefaultSnooze, true,
                    widget.settings.defaultSnoozeDurationMins),
              ),
            ],
          ),
          Column(
            children: [
              CustomSectionHeder('Archive Default Sort By'),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    for (int i = 0; i < archiveSortBy.length; i++)
                      CustomButtonGroup(
                        isSelected:
                            widget.settings.archiveSortBy == archiveSortBy[i],
                        onSelected: (value) => settingsProvider.updateSettings(
                            userId,
                            key: SettingsKey.archiveSortBy,
                            value: value,
                            settingsId: widget.settings.id),
                        title: archiveSortBy[i],
                        length: archiveSortBy.length,
                        index: i,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              CustomSectionHeder('Archive Auto Delete'),
              Container(
                child: CustomPicker(autoDeleteInterval, _setAutoDelete, true,
                    widget.settings.archiveAutoDeleteMins),
              ),
              CustomToggle(
                title: 'Include Answered Prayers in Auto Delete?',
                onChange: (value) => settingsProvider.updateSettings(userId,
                    key: SettingsKey.includeAnsweredPrayerAutoDelete,
                    value: value,
                    settingsId: widget.settings.id),
                value: widget.settings.includeAnsweredPrayerAutoDelete,
              )
            ],
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}
