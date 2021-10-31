import 'dart:convert';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/local_notification.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';

class ReminderPicker extends StatefulWidget {
  final Function onCancel;
  final bool hideActionuttons;
  final LocalNotificationModel reminder;
  final String type;

  @override
  ReminderPicker({
    @required this.hideActionuttons,
    @required this.onCancel,
    @required this.reminder,
    @required this.type,
  });
  _ReminderPickerState createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  double itemExtent = 30.0;

  int selectedHour;

  String selectedFrequency;
  int selectedDayOfWeek;
  String selectedPeriod;
  int selectedMinute;
  int selectedYear;
  String selectedMonth;
  int selectedDayOfMonth;

  List<String> periodOfDay = [PeriodOfDay.am, PeriodOfDay.pm];
  List<int> hoursOfTheDay = new List<int>.generate(12, (i) => i + 1);
  List<int> minInTheHour = [0, 15, 30, 45];
  List<int> years = new List<int>.generate(10, (i) => i + DateTime.now().year);
  List<int> daysOfMonth = new List<int>.generate(31, (i) => i + 1);

  @override
  void initState() {
    if (widget.reminder != null) {
      selectedHour = int.parse(widget.reminder?.selectedHour);
      selectedMinute = int.parse(widget.reminder?.selectedMinute);
      selectedDayOfWeek = LocalNotification.daysOfWeek
          .indexOf(widget.reminder?.selectedDay?.capitalizeFirst());
      selectedPeriod = widget.reminder?.period;
      selectedFrequency = widget.reminder?.frequency;
      selectedYear = int.parse(widget.reminder?.selectedYear);
      selectedMonth = widget.reminder?.selectedMonth;
      selectedDayOfMonth = int.parse(widget.reminder?.selectedDayOfMonth);
    } else {
      selectedHour = DateTime.now().hour == 0 ? 12 : DateTime.now().hour;
      selectedMinute = minInTheHour[0];
      selectedDayOfWeek = DateTime.now().weekday - 1;
      selectedPeriod =
          DateTime.now().hour > 12 ? PeriodOfDay.pm : PeriodOfDay.am;
      selectedFrequency = Frequency.one_time;
      selectedYear = DateTime.now().year;
      selectedMonth = LocalNotification.months[DateTime.now().month - 1];
      selectedDayOfMonth = DateTime.now().day;
    }
    super.initState();
  }

  storeNotification(
    String notificationText,
    String userId,
    String title,
    String description,
    String frequency,
    tz.TZDateTime scheduledDate,
    String prayerid,
    String selectedDay,
    String period,
    String selectedHour,
    String selectedMinute,
    String selectedYear,
  ) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .addLocalNotification(
      LocalNotification.localNotificationID,
      prayerid,
      notificationText,
      userId,
      prayerid,
      title,
      description,
      frequency,
      widget.type,
      scheduledDate,
      selectedDay,
      period,
      selectedHour,
      selectedMinute,
      selectedYear,
      selectedMonth,
      selectedDayOfMonth.toString(),
    );
    BeStilDialog.hideLoading(context);
    setState(() {});
    if (widget.type == NotificationType.reminder)
      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
    else
      widget.onCancel();
    setState(() => null);
  }

  updatePrayerTime(
    String selectedDay,
    String selectedPeriod,
    String selectedFrequency,
    String selectedHour,
    String selectedMinute,
    tz.TZDateTime scheduledDate,
    String userId,
    String notificationText,
    String selectedYear,
  ) async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .updateLocalNotification(
      selectedFrequency,
      scheduledDate,
      selectedDay,
      selectedPeriod,
      selectedHour,
      selectedMinute,
      widget.reminder?.id,
      userId,
      notificationText,
      selectedYear,
      selectedMonth,
      selectedDayOfMonth.toString(),
    );
    BeStilDialog.hideLoading(context);

    setState(() {});
    if (widget.type == NotificationType.reminder)
      Navigator.of(context).pushNamedAndRemoveUntil(
          EntryScreen.routeName, (Route<dynamic> route) => false);
    else
      widget.onCancel();
  }

  setNotification() async {
    print(selectedPeriod);
    // AM 22= 22-12
    // pm 12 = 12+12
    final hour = selectedPeriod == PeriodOfDay.am && selectedHour > 12
        ? selectedHour - 12
        : selectedPeriod == PeriodOfDay.pm && selectedHour < 12
            ? selectedHour + 12
            : selectedHour;
    DateTime date = DateTime(
        selectedYear,
        LocalNotification.months.indexOf(selectedMonth) + 1,
        selectedDayOfMonth,
        hour,
        selectedMinute);

    if (selectedFrequency == Frequency.one_time &&
        date.isBefore(DateTime.now())) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      var e = Exception('Please select a date in the future.');
      BeStilDialog.showErrorDialog(context, e, user, null);
      return;
    }
    try {
      var _selectedMinuteString =
          selectedMinute < 10 ? '0$selectedMinute' : '$selectedMinute';
      var _selectedHourString = hour < 10
          ? '0$hour'
          : hour > 12
              ? (hour - 12).toString()
              : '$hour ';
      BeStilDialog.showLoading(context);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      var suffix = "th";
      var digit = selectedDayOfMonth % 10;
      if ((digit > 0 && digit < 4) &&
          (selectedDayOfMonth < 11 || selectedDayOfMonth > 13)) {
        suffix = ["st", "nd", "rd"][digit - 1];
      }
      final notificationText = selectedFrequency == Frequency.weekly
          ? '$selectedFrequency, ${LocalNotification.daysOfWeek[selectedDayOfWeek]}, $_selectedHourString:$_selectedMinuteString $selectedPeriod'
          : selectedFrequency == Frequency.one_time
              ? '$selectedFrequency,  $selectedMonth $selectedDayOfMonth$suffix, $selectedYear $_selectedHourString:$_selectedMinuteString $selectedPeriod'
              : '$selectedFrequency, $_selectedHourString:$_selectedMinuteString $selectedPeriod';

      final prayerData =
          Provider.of<PrayerProvider>(context, listen: false).currentPrayer;
      final title = '$selectedFrequency reminder to pray';
      final description = prayerData?.prayer?.description ?? '';

      final scheduleDate = LocalNotification.scheduleDate(
        hour,
        selectedMinute,
        selectedDayOfWeek + 1,
        selectedPeriod,
        selectedYear,
        selectedMonth,
        selectedDayOfMonth,
        selectedFrequency == Frequency.one_time,
      );
      print(scheduleDate);
      final payload = NotificationMessage(
          entityId: prayerData?.userPrayer?.id ?? '', type: widget.type);
      await LocalNotification.setLocalNotification(
        context: context,
        title: title,
        description: widget.type == NotificationType.prayer_time
            ? 'It is time to pray!'
            : description,
        scheduledDate: scheduleDate,
        payload: jsonEncode(payload.toJson()),
        frequency: selectedFrequency,
        localNotificationId: widget.reminder?.localNotificationId ?? null,
      );
      if (widget.reminder != null)
        updatePrayerTime(
          LocalNotification.daysOfWeek[selectedDayOfWeek],
          selectedPeriod,
          selectedFrequency,
          _selectedHourString,
          _selectedMinuteString,
          scheduleDate,
          userId,
          notificationText,
          selectedYear.toString(),
        );
      else
        await storeNotification(
          notificationText,
          userId,
          title,
          description,
          selectedFrequency,
          scheduleDate,
          prayerData?.userPrayer?.id ?? '',
          LocalNotification.daysOfWeek[selectedDayOfWeek],
          selectedPeriod,
          _selectedHourString,
          _selectedMinuteString,
          selectedYear.toString(),
        );
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  _deleteReminder() async {
    try {
      await Provider.of<NotificationProvider>(context, listen: false)
          .deleteLocalNotification(widget.reminder.id);
      setState(() {});
      if (widget.type == NotificationType.reminder)
        Navigator.of(context).pushNamedAndRemoveUntil(
            EntryScreen.routeName, (Route<dynamic> route) => false);
      else
        widget.onCancel();
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    FixedExtentScrollController frequencyController =
        FixedExtentScrollController(
            initialItem:
                LocalNotification.frequency.indexOf(selectedFrequency));
    FixedExtentScrollController daysOfWeekController =
        FixedExtentScrollController(
            initialItem: LocalNotification.daysOfWeek
                .indexOf(LocalNotification.daysOfWeek[selectedDayOfWeek]));
    FixedExtentScrollController periodController = FixedExtentScrollController(
        initialItem: periodOfDay.indexOf(selectedPeriod));
    FixedExtentScrollController hourController = FixedExtentScrollController(
        initialItem: hoursOfTheDay
            .indexOf(selectedHour > 12 ? selectedHour - 12 : selectedHour));
    FixedExtentScrollController minuteController = FixedExtentScrollController(
        initialItem: minInTheHour.indexOf(selectedMinute));
    FixedExtentScrollController yearController =
        FixedExtentScrollController(initialItem: years.indexOf(selectedYear));
    FixedExtentScrollController monthController = FixedExtentScrollController(
        initialItem: LocalNotification.months.indexOf(selectedMonth));
    FixedExtentScrollController dayOfMonthController =
        FixedExtentScrollController(
            initialItem: daysOfMonth.indexOf(selectedDayOfMonth));

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.type == NotificationType.reminder
                ? 'SET REMINDER'
                : 'SET PRAYER TIME',
            style: TextStyle(
              color: AppColors.lightBlue1,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.5,
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              height: 200,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: CupertinoPicker(
                              selectionOverlay:
                                  CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent,
                              ),
                              backgroundColor: Colors.transparent,
                              scrollController: frequencyController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() =>
                                  selectedFrequency =
                                      LocalNotification.frequency[i]),
                              children: <Widget>[
                                ...LocalNotification.frequency
                                    .map((i) => Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            i,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.lightBlue4,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ],
                            ),
                          ),
                          Container(
                            width: selectedFrequency == Frequency.one_time
                                ? MediaQuery.of(context).size.width * 0.13
                                : MediaQuery.of(context).size.width * 0.2,
                            child: selectedFrequency == Frequency.one_time
                                ? CupertinoPicker(
                                    selectionOverlay:
                                        CupertinoPickerDefaultSelectionOverlay(
                                      background: Colors.transparent,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    scrollController: yearController,
                                    itemExtent: itemExtent,
                                    onSelectedItemChanged: (i) =>
                                        setState(() => selectedYear = years[i]),
                                    children: <Widget>[
                                      ...years.map(
                                        (r) => Align(
                                          alignment: Alignment.center,
                                          child: Text(r.toString(),
                                              style:
                                                  AppTextStyles.regularText15),
                                        ),
                                      ),
                                    ],
                                  )
                                : selectedFrequency == Frequency.weekly
                                    ? CupertinoPicker(
                                        selectionOverlay:
                                            CupertinoPickerDefaultSelectionOverlay(
                                          background: Colors.transparent,
                                        ),
                                        backgroundColor: Colors.transparent,
                                        scrollController: daysOfWeekController,
                                        itemExtent: itemExtent,
                                        onSelectedItemChanged: (i) => setState(
                                            () => selectedDayOfWeek = i),
                                        children: <Widget>[
                                          ...LocalNotification.daysOfWeek.map(
                                            (r) => Align(
                                              alignment: Alignment.center,
                                              child: Text(r,
                                                  style: AppTextStyles
                                                      .regularText15),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(height: 31),
                          ),
                          selectedFrequency == Frequency.one_time
                              ? Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.12,
                                  child: CupertinoPicker(
                                    selectionOverlay:
                                        CupertinoPickerDefaultSelectionOverlay(
                                      background: Colors.transparent,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    scrollController: monthController,
                                    itemExtent: itemExtent,
                                    onSelectedItemChanged: (i) => setState(() =>
                                        selectedMonth =
                                            LocalNotification.months[i]),
                                    children: <Widget>[
                                      for (var i = 0;
                                          i < LocalNotification.months.length;
                                          i++)
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                              LocalNotification.months[i],
                                              style:
                                                  AppTextStyles.regularText15),
                                        ),
                                    ],
                                  ),
                                )
                              : Container(),
                          selectedFrequency == Frequency.one_time
                              ? Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.085,
                                  child: CupertinoPicker(
                                    selectionOverlay:
                                        CupertinoPickerDefaultSelectionOverlay(
                                      background: Colors.transparent,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    scrollController: dayOfMonthController,
                                    itemExtent: itemExtent,
                                    onSelectedItemChanged: (i) => setState(() =>
                                        selectedDayOfMonth = daysOfMonth[i]),
                                    children: <Widget>[
                                      for (var i = 0;
                                          i < daysOfMonth.length;
                                          i++)
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(daysOfMonth[i].toString(),
                                              style:
                                                  AppTextStyles.regularText15),
                                        ),
                                    ],
                                  ),
                                )
                              : Container(),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.085,
                            child: CupertinoPicker(
                              selectionOverlay:
                                  CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent,
                              ),
                              backgroundColor: Colors.transparent,
                              scrollController: hourController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() {
                                selectedHour = hoursOfTheDay[i];
                              }),
                              children: <Widget>[
                                for (var i = 0; i < hoursOfTheDay.length; i++)
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                        hoursOfTheDay[i] < 10
                                            ? '0${hoursOfTheDay[i]}'
                                            : '${hoursOfTheDay[i]}',
                                        style: AppTextStyles.regularText15),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            height: 31,
                            width: selectedFrequency == Frequency.one_time
                                ? MediaQuery.of(context).size.width * 0.015
                                : MediaQuery.of(context).size.width * 0.1,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(':',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.regularText15),
                            ),
                          ),
                          Container(
                            width: selectedFrequency == Frequency.one_time
                                ? MediaQuery.of(context).size.width * 0.09
                                : MediaQuery.of(context).size.width * 0.12,
                            child: CupertinoPicker(
                              selectionOverlay:
                                  CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent,
                              ),
                              backgroundColor: Colors.transparent,
                              scrollController: minuteController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(
                                  () => selectedMinute = minInTheHour[i]),
                              children: <Widget>[
                                for (var i = 0; i < minInTheHour.length; i++)
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                        minInTheHour[i] < 10
                                            ? '0${minInTheHour[i]}'
                                            : '${minInTheHour[i]}',
                                        style: AppTextStyles.regularText15),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: selectedFrequency == Frequency.one_time
                                ? MediaQuery.of(context).size.width * 0.09
                                : MediaQuery.of(context).size.width * 0.1,
                            child: CupertinoPicker(
                              selectionOverlay:
                                  CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent,
                              ),
                              backgroundColor: Colors.transparent,
                              scrollController: periodController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() {
                                selectedPeriod = periodOfDay[i];
                              }),
                              children: <Widget>[
                                ...periodOfDay
                                    .map(
                                      (x) => Align(
                                        child: Text(
                                          x,
                                          style: TextStyle(
                                            color: AppColors.lightBlue4,
                                            fontSize: 14,
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
          widget.hideActionuttons
              ? Container()
              : Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              widget.onCancel();
                            },
                            child: Container(
                              height: 38.0,
                              width: MediaQuery.of(context).size.width * .35,
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
                            onTap: setNotification,
                            child: Container(
                              height: 38.0,
                              width: MediaQuery.of(context).size.width * .35,
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
                                  Text('SAVE',
                                      style: AppTextStyles.boldText20.copyWith(
                                          color: AppColors.white, height: 1.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    widget.reminder != null
                        ? GestureDetector(
                            onTap: () {
                              _deleteReminder();
                            },
                            child: Container(
                              height: 38.0,
                              width: MediaQuery.of(context).size.width * 0.71,
                              decoration: BoxDecoration(
                                color: AppColors.red,
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
                                  Text('DELETE REMINDER',
                                      style: AppTextStyles.boldText20.copyWith(
                                          color: AppColors.white, height: 1.5)),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
        ],
      ),
    );
  }
}
