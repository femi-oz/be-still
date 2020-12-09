import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/settings_provider.dart';
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
  _setDefaultSnooze(value) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        key: SettingsKey.defaultSnoozeDuration,
        value: value,
        settingsId: widget.settings.id);
  }

  _setAutoDelete(value) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        key: SettingsKey.archiveAutoDelete,
        value: value,
        settingsId: widget.settings.id);
  }

  List<String> snoozeInterval = [
    IntervalRange.sevenDays,
    IntervalRange.fourtheenDays,
    IntervalRange.thirtyDays,
    IntervalRange.ninetyDays,
    IntervalRange.oneYear,
  ];
  List<String> autoDeleteInterval = [
    IntervalRange.thirtyDays,
    IntervalRange.ninetyDays,
    IntervalRange.oneYear,
    IntervalRange.twoYears,
    IntervalRange.never,
  ];
  List<String> defaultSortBy = [SortType.date, SortType.tag];
  List<String> archiveSortBy = [SortType.date, SortType.tag, SortType.answered];
  @override
  Widget build(BuildContext context) {
    final setingProvider = Provider.of<SettingsProvider>(context);

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
                        onSelected: (value) => setingProvider.updateSettings(
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
                        onSelected: (value) => setingProvider.updateSettings(
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
                        .indexOf(widget.settings.archiveAutoDelete)),
              ),
              CustomToggle(
                title: 'Include Answered Prayers in Auto Delete?',
                onChange: (value) => setingProvider.updateSettings(
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
