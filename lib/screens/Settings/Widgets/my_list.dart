import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/models/duration.model.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/custom_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyListSettings extends StatefulWidget {
  final SettingsModel settings;
  MyListSettings(this.settings);
  @override
  _MyListSettingsState createState() => _MyListSettingsState();
}

class _MyListSettingsState extends State<MyListSettings> {
  var selectedInterval;
  var selectedDuration;
  var selectedDurationIndex;
  var selectedIntervalIndex;
  int minutes;
  _setDefaultSnooze() async {
    switch (selectedInterval) {
      // case 'Minutes':
      //   minutes = 1;
      //   break;
      case 'Days':
        minutes = 1440;
        break;
      case 'Weeks':
        minutes = 10080;
        break;
      case 'Months':
        minutes = 43800;
        break;
      default:
    }

    var e = int.parse(selectedDuration) * minutes;
    try {
      BeStilDialog.showLoading(
        context,
      );
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSettings(
              Provider.of<UserProvider>(context, listen: false).currentUser.id,
              key: SettingsKey.defaultSnoozeDurationMins,
              value: e,
              settingsId: widget.settings.id);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  _setAutoDelete(e) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        Provider.of<UserProvider>(context, listen: false).currentUser.id,
        key: SettingsKey.archiveAutoDeleteMins,
        value: e,
        settingsId: widget.settings.id);
  }

  // List<LookUp> snoozeInterval = [
  //   LookUp(text: IntervalRange.thirtyMinutes, value: 30),
  //   LookUp(text: IntervalRange.oneHour, value: 60),
  //   LookUp(text: IntervalRange.sevenDays, value: 10080),
  //   LookUp(text: IntervalRange.fourtheenDays, value: 20160),
  //   LookUp(text: IntervalRange.thirtyDays, value: 43200),
  //   LookUp(text: IntervalRange.ninetyDays, value: 129600),
  //   LookUp(text: IntervalRange.oneYear, value: 525600),
  // ];

  @override
  dispose() {
    _setDefaultSnooze();
    super.dispose();
  }

  List<String> snoozeInterval = ['Minutes', 'Days', 'Weeks', 'Months'];

  List<String> snoozeDuration = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
  ];

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
            // CustomSectionHeder('Default Sort By'),
            // SizedBox(height: 35),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: <Widget>[
            //       for (int i = 0; i < defaultSortBy.length; i++)
            //         CustomButtonGroup(
            //           isSelected:
            //               widget.settings.defaultSortBy == defaultSortBy[i],
            //           onSelected: (value) => settingsProvider.updateSettings(
            //               userId,
            //               key: SettingsKey.defaultSortBy,
            //               value: value,
            //               settingsId: widget.settings.id),
            //           title: defaultSortBy[i],
            //           length: defaultSortBy.length,
            //           index: i,
            //         ),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 35),
            CustomSectionHeder('Default Snooze Duration'),
            // Container(
            //   child: CustomPicker(snoozeInterval, _setDefaultSnooze, true,
            //       widget.settings.defaultSnoozeDurationMins),
            // ),

            // Container(
            //   margin: EdgeInsets.only(bottom: 80.0),
            //   child: ReminderPicker(
            //     hideActionuttons: false,
            //     frequency: snoozeInterval,
            //     reminderDays: snoozeDuration,
            //     onSave: (selectedFrequency, selectedDuration) =>
            //         _setDefaultSnooze(
            //       selectedFrequency,
            //       selectedDuration,
            //     ),
            //   ),
            // )
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
                                      scrollController:
                                          FixedExtentScrollController(
                                              initialItem: snoozeInterval
                                                  .indexOf(snoozeInterval[
                                                      int.parse(Settings
                                                          .snoozeInterval)])),
                                      itemExtent: 30,
                                      onSelectedItemChanged: (i) =>
                                          setState(() {
                                        selectedInterval = snoozeInterval[i];
                                        selectedIntervalIndex = snoozeInterval
                                            .indexOf(snoozeInterval[i]);
                                        Settings.snoozeInterval =
                                            selectedIntervalIndex.toString();

                                        // widget.onChange(selectedInterval.value);
                                      }),
                                      children: <Widget>[
                                        ...snoozeInterval
                                            .map(
                                              (i) => Align(
                                                  alignment: Alignment.center,
                                                  child: Text(i,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: AppTextStyles
                                                          .regularText15)),
                                            )
                                            .toList(),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: CupertinoPicker(
                                      scrollController:
                                          FixedExtentScrollController(
                                              initialItem: snoozeDuration
                                                  .indexOf(snoozeDuration[
                                                      int.parse(Settings
                                                          .snoozeDuration)])),
                                      itemExtent: 30,
                                      onSelectedItemChanged: (i) =>
                                          setState(() {
                                        selectedDuration = snoozeDuration[i];
                                        selectedDurationIndex = snoozeDuration
                                            .indexOf(selectedDuration);
                                        Settings.snoozeDuration =
                                            selectedDurationIndex.toString();

                                        // widget.onChange(selectedInterval.value);
                                      }),
                                      children: <Widget>[
                                        ...snoozeDuration
                                            .map(
                                              (i) => Align(
                                                  alignment: Alignment.center,
                                                  child: Text(i,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: AppTextStyles
                                                          .regularText15)),
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
            // CustomSectionHeder('Archive Default Sort By'),
            // SizedBox(height: 35),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: <Widget>[
            //       for (int i = 0; i < archiveSortBy.length; i++)
            //         CustomButtonGroup(
            //           isSelected:
            //               widget.settings.archiveSortBy == archiveSortBy[i],
            //           onSelected: (value) => settingsProvider.updateSettings(
            //               userId,
            //               key: SettingsKey.archiveSortBy,
            //               value: value,
            //               settingsId: widget.settings.id),
            //           title: archiveSortBy[i],
            //           length: archiveSortBy.length,
            //           index: i,
            //         ),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 35),
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
