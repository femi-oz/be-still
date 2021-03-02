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
  _setDefaultSnooze(BDuration e) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        key: SettingsKey.defaultSnoozeDuration,
        value: e.value,
        settingsId: widget.settings.id);
  }

  _setAutoDelete(value) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        key: SettingsKey.archiveAutoDelete,
        value: value,
        settingsId: widget.settings.id);
  }

  List<BDuration> snoozeInterval = [
    BDuration(text: IntervalRange.thirtyMinutes, value: 30),
    BDuration(text: IntervalRange.oneHour, value: 60),
    BDuration(text: IntervalRange.sevenDays, value: 10080),
    BDuration(text: IntervalRange.fourtheenDays, value: 20160),
    BDuration(text: IntervalRange.thirtyDays, value: 43200),
    BDuration(text: IntervalRange.ninetyDays, value: 129600),
    BDuration(text: IntervalRange.oneYear, value: 525600),
  ];
  List<BDuration> autoDeleteInterval = [
    BDuration(text: IntervalRange.thirtyDays, value: 30),
    BDuration(text: IntervalRange.ninetyDays, value: 90),
    BDuration(text: IntervalRange.oneYear, value: 365),
    BDuration(text: IntervalRange.twoYears, value: 730),
    BDuration(text: IntervalRange.never, value: 0),
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
                            userId: userId,
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
                child: CustomPicker(
                    snoozeInterval,
                    _setDefaultSnooze,
                    true,
                    snoozeInterval
                        .map((e) => e.text)
                        .toList()
                        .indexOf(widget.settings.defaultSnoozeDuration)),
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
                            userId: userId,
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
                child: CustomPicker(
                    autoDeleteInterval,
                    _setAutoDelete,
                    true,
                    autoDeleteInterval
                        .map((e) => e.text)
                        .toList()
                        .indexOf(widget.settings.archiveAutoDelete)),
              ),
              CustomToggle(
                title: 'Include Answered Prayers in Auto Delete?',
                onChange: (value) => settingsProvider.updateSettings(
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
