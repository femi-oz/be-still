import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class SnoozePrayer extends StatefulWidget {
  final CombinePrayerStream prayerData;
  SnoozePrayer(this.prayerData);
  @override
  _SnoozePrayerState createState() => _SnoozePrayerState();
}

class _SnoozePrayerState extends State<SnoozePrayer> {
  List<String> snoozeInterval = ['Minutes', 'Days', 'Weeks', 'Months'];
  List<int> snoozeDuration = [];
  List<int> snoozeMonths = new List<int>.generate(12, (i) => i + 1);
  List<int> snoozeWeeks = new List<int>.generate(52, (i) => i + 1);
  List<int> snoozeMins = new List<int>.generate(60, (i) => i + 1);
  List<int> snoozeDays = new List<int>.generate(31, (i) => i + 1);

  String selectedInterval;
  int selectedDuration;

  @override
  void initState() {
    final settings =
        Provider.of<SettingsProvider>(context, listen: false).settings;
    selectedInterval = settings.defaultSnoozeFrequency;
    selectedDuration = settings.defaultSnoozeDuration;
    snoozeDuration = settings.defaultSnoozeFrequency == "Weeks"
        ? snoozeWeeks
        : settings.defaultSnoozeFrequency == "Months"
            ? snoozeMonths
            : settings.defaultSnoozeFrequency == "Days"
                ? snoozeDays
                : snoozeMins;
    super.initState();
  }

  void _snoozePrayer() async {
    BeStilDialog.showLoading(context);

    var minutes = 0;
    switch (selectedInterval) {
      case 'Minutes':
        minutes = 1;
        break;
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

    var e = selectedDuration * minutes;
    var _snoozeEndDate = DateTime.now().add(new Duration(minutes: e));
    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData.userPrayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false).snoozePrayer(
          widget.prayerData.prayer.id,
          _snoozeEndDate,
          widget.prayerData.userPrayer.id);

      await Future.delayed(Duration(milliseconds: 300),
          () => {BeStilDialog.hideLoading(context)});
      Navigator.pushReplacement(context, SlideRightRoute(page: EntryScreen()));
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300),
          () => {BeStilDialog.hideLoading(context)});
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snoozeDurationController = FixedExtentScrollController(
        initialItem: snoozeDuration.asMap().containsKey(selectedDuration)
            ? snoozeDuration.indexOf(selectedDuration)
            : snoozeDuration[0]);
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              height: 200,
              child: Column(
                children: <Widget>[
                  Text(
                    'Set Snooze Duration',
                    style: AppTextStyles.regularText15
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: CupertinoPicker(
                              selectionOverlay:
                                  CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent,
                              ),
                              scrollController: FixedExtentScrollController(
                                  initialItem:
                                      snoozeInterval.indexOf(selectedInterval)),
                              itemExtent: 30,
                              onSelectedItemChanged: (i) {
                                snoozeDuration = snoozeInterval[i] == "Weeks"
                                    ? snoozeWeeks
                                    : snoozeInterval[i] == "Months"
                                        ? snoozeMonths
                                        : snoozeInterval[i] == "Days"
                                            ? snoozeDays
                                            : snoozeMins;
                                snoozeDurationController
                                    .jumpTo(selectedDuration * 1.0);
                                setState(
                                    () => selectedInterval = snoozeInterval[i]);
                              },
                              children: <Widget>[
                                ...snoozeInterval
                                    .map(
                                      (i) => Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          i,
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.regularText15
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
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: CupertinoPicker(
                                selectionOverlay:
                                    CupertinoPickerDefaultSelectionOverlay(
                                  background: Colors.transparent,
                                ),
                                scrollController: snoozeDurationController,
                                itemExtent: 30,
                                onSelectedItemChanged: (i) {
                                  print(snoozeDuration
                                      .asMap()
                                      .containsKey(selectedDuration));
                                  var index = snoozeDuration
                                          .asMap()
                                          .containsKey(selectedDuration)
                                      ? i
                                      : 0;
                                  setState(() =>
                                      selectedDuration = snoozeDuration[index]);
                                },
                                children: <Widget>[
                                  ...snoozeDuration
                                      .map(
                                        (i) => Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            i.toString(),
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles.regularText15
                                                .copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            width: double.infinity,
            child: Row(
              children: <Widget>[
                CustomButtonGroup(
                  title: 'SNOOZE',
                  onSelected: (_) {
                    _snoozePrayer();
                  },
                  length: 2,
                  index: 0,
                ),
                CustomButtonGroup(
                  title: 'CANCEL',
                  onSelected: (_) {
                    Navigator.of(context).pop();
                  },
                  length: 2,
                  index: 0,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
