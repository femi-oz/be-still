import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/models/duration.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/custom_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyListSettings extends StatefulWidget {
  final SettingsModel settings;
  final Function onDispose;
  MyListSettings(this.settings, this.onDispose);
  @override
  _MyListSettingsState createState() => _MyListSettingsState();
}

class _MyListSettingsState extends State<MyListSettings> {
  List<String> snoozeInterval = ['Minutes', 'Days', 'Weeks', 'Months'];
  List<int> snoozeDuration = [];
  List<int> snoozeMonths = new List<int>.generate(12, (i) => i + 1);
  List<int> snoozeWeeks = new List<int>.generate(52, (i) => i + 1);
  List<int> snoozeMins = new List<int>.generate(60, (i) => i + 1);
  List<int> snoozeDays = new List<int>.generate(31, (i) => i + 1);
  String selectedInterval;
  int selectedDuration;

  _setAutoDelete(e) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        Provider.of<UserProvider>(context, listen: false).currentUser.id,
        key: SettingsKey.archiveAutoDeleteMins,
        value: e,
        settingsId: widget.settings.id);
  }

  @override
  deactivate() {
    widget.onDispose(selectedDuration, selectedInterval, widget.settings.id);
    super.deactivate();
  }

  initState() {
    selectedInterval = widget.settings.defaultSnoozeFrequency;
    selectedDuration = widget.settings.defaultSnoozeDuration;
    snoozeDuration = widget.settings.defaultSnoozeFrequency == "Weeks"
        ? snoozeWeeks
        : widget.settings.defaultSnoozeFrequency == "Months"
            ? snoozeMonths
            : widget.settings.defaultSnoozeFrequency == "Days"
                ? snoozeDays
                : snoozeMins;
    super.initState();
  }

  List<LookUp> autoDeleteInterval = [
    LookUp(text: IntervalRange.thirtyMinutes, value: 30),
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
    final snoozeDurationController = FixedExtentScrollController(
        initialItem: snoozeDuration.contains(selectedDuration)
            ? snoozeDuration.indexOf(selectedDuration)
            : snoozeDuration[0]);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundColor,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 15),
            CustomSectionHeder('Default Snooze Duration'),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: CupertinoPicker(
                                      selectionOverlay:
                                          CupertinoPickerDefaultSelectionOverlay(
                                        background: Colors.transparent,
                                      ),
                                      scrollController:
                                          FixedExtentScrollController(
                                              initialItem: snoozeInterval
                                                  .indexOf(selectedInterval)),
                                      itemExtent: 30,
                                      onSelectedItemChanged: (i) {
                                        snoozeDuration = snoozeInterval[i] ==
                                                "Weeks"
                                            ? snoozeWeeks
                                            : snoozeInterval[i] == "Months"
                                                ? snoozeMonths
                                                : snoozeInterval[i] == "Days"
                                                    ? snoozeDays
                                                    : snoozeMins;
                                        snoozeDurationController
                                            .jumpTo(selectedDuration * 1.0);
                                        setState(() => selectedInterval =
                                            snoozeInterval[i]);
                                      },
                                      children: <Widget>[
                                        ...snoozeInterval
                                            .map(
                                              (i) => Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  i,
                                                  textAlign: TextAlign.center,
                                                  style: AppTextStyles
                                                      .regularText15
                                                      .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: CupertinoPicker(
                                      selectionOverlay:
                                          CupertinoPickerDefaultSelectionOverlay(
                                        background: Colors.transparent,
                                      ),
                                      scrollController:
                                          snoozeDurationController,
                                      itemExtent: 30,
                                      onSelectedItemChanged: (i) {
                                        selectedDuration = snoozeDuration[i];
                                      },
                                      children: <Widget>[
                                        ...snoozeDuration
                                            .map(
                                              (i) => Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  i.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: AppTextStyles
                                                      .regularText15
                                                      .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
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
                ],
              ),
            ),
            SizedBox(height: 10.0),
            CustomSectionHeder('Archive Auto Delete'),
            SizedBox(height: 15),
            Container(
              child: CustomPicker(
                autoDeleteInterval,
                _setAutoDelete,
                true,
                widget.settings.archiveAutoDeleteMins,
              ),
            ),
            SizedBox(height: 15),
            CustomToggle(
              title: 'Include Answered Prayers in Auto Delete?',
              onChange: (value) => settingsProvider.updateSettings(userId,
                  key: SettingsKey.includeAnsweredPrayerAutoDelete,
                  value: value,
                  settingsId: widget.settings.id),
              value: widget.settings.includeAnsweredPrayerAutoDelete,
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
