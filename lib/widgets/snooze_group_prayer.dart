import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SnoozeGroupPrayer extends StatefulWidget {
  final CombineGroupPrayerStream prayerData;
  SnoozeGroupPrayer(this.prayerData);
  @override
  _SnoozeGroupPrayerState createState() => _SnoozeGroupPrayerState();
}

class _SnoozeGroupPrayerState extends State<SnoozeGroupPrayer> {
  List<String> snoozeInterval = ['Minutes', 'Days', 'Weeks', 'Months'];
  List<int> snoozeDuration = [];
  List<int> snoozeMonths = new List<int>.generate(12, (i) => i + 1);
  List<int> snoozeWeeks = new List<int>.generate(52, (i) => i + 1);
  List<int> snoozeMins = new List<int>.generate(60, (i) => i + 1);
  List<int> snoozeDays = new List<int>.generate(31, (i) => i + 1);
  String selectedInterval = '';
  int selectedDuration = 0;

  @override
  void initState() {
    final settings =
        Provider.of<SettingsProvider>(context, listen: false).settings;
    selectedInterval = widget.prayerData.groupPrayer.snoozeFrequency.isNotEmpty
        ? widget.prayerData.groupPrayer.snoozeFrequency
        : settings.defaultSnoozeFrequency;
    selectedDuration = widget.prayerData.groupPrayer.snoozeDuration > 0
        ? widget.prayerData.groupPrayer.snoozeDuration
        : settings.defaultSnoozeDuration;
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
        minutes = 44640;
        break;
      default:
    }
    var e = selectedDuration * (minutes);
    var _snoozeEndDate = DateTime.now().add(new Duration(minutes: e));
    try {
      var notifications =
          Provider.of<NotificationProvider>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.entityId == widget.prayerData.groupPrayer.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProvider>(context, listen: false)
              .deleteLocalNotification(e.id));
      await Provider.of<PrayerProvider>(context, listen: false).snoozePrayer(
          widget.prayerData.prayer.id,
          _snoozeEndDate,
          widget.prayerData.groupPrayer.id,
          selectedDuration,
          selectedInterval);

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
        initialItem: snoozeDuration.contains(selectedDuration)
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
                    'SET SNOOZE DURATION',
                    style: TextStyle(
                      color: AppColors.lightBlue1,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.5,
                    ),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 38.0,
                        width: MediaQuery.of(context).size.width * .32,
                        decoration: BoxDecoration(
                          color: AppColors.grey.withOpacity(0.5),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('CANCEL',
                                style: AppTextStyles.boldText20.copyWith(
                                    color: AppColors.white, height: 1.5)),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _snoozePrayer,
                      child: Container(
                        height: 38.0,
                        width: MediaQuery.of(context).size.width * .32,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('SNOOZE',
                                style: AppTextStyles.boldText20.copyWith(
                                    color: AppColors.white, height: 1.5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
