import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/sortBy.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/snooze_picker.dart';
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
    //TODO default snooze update  service
  }
  _setAutoDelete(value) {
    // TODO auto delete update service
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
    final _themeProvider = Provider.of<ThemeProvider>(context);
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
                        onSelected: null, // TODO default sort by update service
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
                child: SnoozePicker(
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
                        onSelected: null, // TODO archive sort by update service
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
                child: SnoozePicker(
                    autoDeleteInterval,
                    _setAutoDelete,
                    true,
                    autoDeleteInterval
                        .indexOf(widget.settings.archiveAutoDelete)),
              ),
              CustomToggle(
                title: 'Include Answered Prayers in Auto Delete?',
                onChange:
                    null, // TODO includeAnsweredPrayerAutoDelete update service
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
