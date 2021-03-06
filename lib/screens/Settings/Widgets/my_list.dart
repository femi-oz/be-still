import 'dart:io';

import 'package:be_still/enums/interval.dart';
import 'package:be_still/enums/sort_by.dart';
import 'package:be_still/flavor_config.dart';
import 'package:be_still/models/v2/duration.model.dart';
import 'package:be_still/models/v2/user.model.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/custom_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyListSettings extends StatefulWidget {
  final UserDataModel settings;
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
  List<int> snoozeMins = new List<int>.generate(
      FlavorConfig.isProduction() || FlavorConfig.isStore() ? 59 : 60,
      (i) =>
          i + (FlavorConfig.isProduction() || FlavorConfig.isStore() ? 2 : 1));
  List<int> snoozeDays = new List<int>.generate(31, (i) => i + 1);
  String selectedInterval = '';
  int selectedDuration = 0;
  bool autoDeleteValueChanged = false;

  _setAutoDelete(e) {
    try {
      Provider.of<UserProviderV2>(context, listen: false)
          .updateUserSettings('archiveAutoDeleteMinutes', e);
      autoDeleteValueChanged = true;
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  @override
  deactivate() {
    final user =
        Provider.of<UserProviderV2>(context, listen: false).currentUser;
    widget.onDispose(selectedDuration, selectedInterval);
    if ((user.archiveAutoDeleteMinutes ?? 0) > 0 && autoDeleteValueChanged) {
      Provider.of<PrayerProviderV2>(context, listen: false)
          .updatePrayerAutoDelete(false);
    }

    super.deactivate();
  }

  initState() {
    selectedInterval = widget.settings.defaultSnoozeFrequency ?? '';
    selectedDuration = widget.settings.defaultSnoozeDuration ?? 0;
    snoozeDuration = widget.settings.defaultSnoozeFrequency == "Weeks"
        ? snoozeWeeks
        : widget.settings.defaultSnoozeFrequency == "Months"
            ? snoozeMonths
            : widget.settings.defaultSnoozeFrequency == "Days"
                ? snoozeDays
                : snoozeMins;
    super.initState();
  }

  List<LookUpV2> autoDeleteInterval =
      FlavorConfig.isDev() || FlavorConfig.isStaging()
          ? [
              LookUpV2(text: IntervalRange.thirtyMinutes, value: 30),
              LookUpV2(text: IntervalRange.thirtyDays, value: 43200),
              LookUpV2(text: IntervalRange.ninetyDays, value: 129600),
              LookUpV2(text: IntervalRange.oneYear, value: 525600),
              LookUpV2(text: IntervalRange.twoYears, value: 1051200),
              LookUpV2(text: IntervalRange.never, value: 0),
            ]
          : [
              LookUpV2(text: IntervalRange.thirtyDays, value: 43200),
              LookUpV2(text: IntervalRange.ninetyDays, value: 129600),
              LookUpV2(text: IntervalRange.oneYear, value: 525600),
              LookUpV2(text: IntervalRange.twoYears, value: 1051200),
              LookUpV2(text: IntervalRange.never, value: 0),
            ];

  List<String> defaultSortBy = [SortType.date, SortType.tag];
  List<String> archiveSortBy = [SortType.date, SortType.tag, SortType.answered];
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<UserProviderV2>(context);
    final prayerProvider = Provider.of<PrayerProviderV2>(context);
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
                widget.settings.archiveAutoDeleteMinutes ?? 0,
              ),
            ),
            SizedBox(height: 15),
            CustomToggle(
              title: 'Include Answered Prayers in Auto Delete?',
              onChange: (value) {
                settingsProvider.updateUserSettings(
                    'includeAnsweredPrayerAutoDelete', value);
                prayerProvider.updateAnsweredPrayerAutoDelete();
              },
              value: widget.settings.includeAnsweredPrayerAutoDelete ?? false,
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
