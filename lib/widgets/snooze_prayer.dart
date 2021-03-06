import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/flavor_config.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/notification_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SnoozePrayer extends StatefulWidget {
  final PrayerDataModel? prayerData;
  final bool popTwice;
  SnoozePrayer(this.prayerData, {this.popTwice = true});
  @override
  _SnoozePrayerState createState() => _SnoozePrayerState();
}

class _SnoozePrayerState extends State<SnoozePrayer> {
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

  @override
  void initState() {
    final currentUser =
        Provider.of<UserProviderV2>(context, listen: false).currentUser;
    selectedInterval = (widget.prayerData?.snoozeFrequency ?? '').isNotEmpty
        ? widget.prayerData?.snoozeFrequency ?? ''
        : currentUser.defaultSnoozeFrequency ?? '';
    selectedDuration = (widget.prayerData?.snoozeDuration ?? 0) > 0
        ? widget.prayerData?.snoozeDuration ?? 0
        : currentUser.defaultSnoozeDuration ?? 0;
    snoozeDuration = currentUser.defaultSnoozeFrequency == "Weeks"
        ? snoozeWeeks
        : currentUser.defaultSnoozeFrequency == "Months"
            ? snoozeMonths
            : currentUser.defaultSnoozeFrequency == "Days"
                ? snoozeDays
                : snoozeMins;
    super.initState();
  }

  void clearSearch() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    await Provider.of<MiscProviderV2>(context, listen: false)
        .setSearchMode(false);
    await Provider.of<MiscProviderV2>(context, listen: false)
        .setSearchQuery('');
    await Provider.of<PrayerProviderV2>(context, listen: false)
        .searchPrayers('', userId ?? '');
  }

  void _snoozePrayer() async {
    BeStilDialog.showLoading(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
    final _snoozeEndDate = DateTime.now().add(new Duration(minutes: e));
    try {
      var notifications =
          Provider.of<NotificationProviderV2>(context, listen: false)
              .localNotifications
              .where((e) =>
                  e.prayerId == widget.prayerData?.id &&
                  e.type == NotificationType.reminder)
              .toList();
      notifications.forEach((e) async =>
          await Provider.of<NotificationProviderV2>(context, listen: false)
              .deleteLocalNotification(e.id ?? '', e.localNotificationId ?? 0));
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      await Provider.of<PrayerProviderV2>(context, listen: false).snoozePrayer(
          userId ?? '',
          widget.prayerData?.id ?? '',
          selectedDuration,
          _snoozeEndDate,
          (user.prayers ?? []).map((e) => e.prayerId ?? '').toList());
      clearSearch();

      BeStilDialog.hideLoading(context);
      Navigator.pop(context);

      AppController appController = Get.find();
      if (widget.popTwice) Navigator.pop(context);
      appController.setCurrentPage(0, true, 0);
    } catch (e, s) {
      await Future.delayed(Duration(milliseconds: 300),
          () => {BeStilDialog.hideLoading(context)});
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
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
                            width: MediaQuery.of(context).size.width * 0.3,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        child: Center(
                          child: Text('CANCEL',
                              style: AppTextStyles.boldText20
                                  .copyWith(color: AppColors.white)),
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
                        child: Center(
                          child: Text('SNOOZE',
                              style: AppTextStyles.boldText20
                                  .copyWith(color: AppColors.white)),
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
