import 'package:be_still/enums/time_range.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReminderPicker extends StatefulWidget {
  final Function onSave;
  final Function onCancel;
  final List<String> frequency;
  final List<String> reminderDays;
  final bool hideActionuttons;

  @override
  ReminderPicker({
    this.onSave,
    this.frequency,
    this.reminderDays,
    this.hideActionuttons,
    this.onCancel,
  });
  _ReminderPickerState createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  double itemExtent = 30.0;

  String selectedFrequency = Frequency.daily;
  String selectedDay;
  String selectedPeriod = PeriodOfDay.pm;
  int selectedHour = 3;
  int selectedMinute = 30;

  List<String> periodOfDay = [PeriodOfDay.am, PeriodOfDay.pm];
  var hoursOfTheDay = new List<int>.generate(12, (i) => i + 1);
  var minInTheHour = new List<int>.generate(60, (i) => i + 1);

  @override
  void initState() {
    selectedDay = widget.reminderDays[DateTime.now().weekday - 1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FixedExtentScrollController frequencyController =
        FixedExtentScrollController(
            initialItem: widget.frequency.indexOf(selectedFrequency));
    FixedExtentScrollController daysController = FixedExtentScrollController(
        initialItem: widget.reminderDays.indexOf(selectedDay));
    FixedExtentScrollController periodController = FixedExtentScrollController(
        initialItem: periodOfDay.indexOf(selectedPeriod));
    FixedExtentScrollController hourController = FixedExtentScrollController(
        initialItem: hoursOfTheDay.indexOf(selectedHour));
    FixedExtentScrollController minuteController = FixedExtentScrollController(
        initialItem: minInTheHour.indexOf(selectedMinute));
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
                  Expanded(
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: CupertinoPicker(
                              scrollController: frequencyController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() =>
                                  selectedFrequency = widget.frequency[i]),
                              children: <Widget>[
                                ...widget.frequency
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
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: selectedFrequency == Frequency.weekly
                                ? CupertinoPicker(
                                    scrollController: daysController,
                                    itemExtent: itemExtent,
                                    onSelectedItemChanged: (i) => setState(() =>
                                        selectedDay = widget.reminderDays[i]),
                                    children: <Widget>[
                                      ...widget.reminderDays.map(
                                        (r) => Align(
                                          alignment: Alignment.center,
                                          child: Text(r,
                                              style:
                                                  AppTextStyles.regularText15),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    height: 31,
                                    decoration: BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal: BorderSide(
                                                color: Settings.isDarkMode
                                                    ? Colors.white12
                                                    : Colors.grey[350]))),
                                  ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: CupertinoPicker(
                              scrollController: hourController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(
                                  () => selectedHour = minInTheHour[i]),
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
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(
                                    color: Settings.isDarkMode
                                        ? Colors.white12
                                        : Colors.grey[350]),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(':',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.regularText15),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: CupertinoPicker(
                              scrollController: minuteController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(
                                  () => selectedMinute = minInTheHour[i]),
                              children: <Widget>[
                                for (var i = 0; i < minInTheHour.length; i++)
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                        i < 10
                                            ? '0${minInTheHour[i]}'
                                            : '${minInTheHour[i]}',
                                        style: AppTextStyles.regularText15),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: CupertinoPicker(
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
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CustomButtonGroup(
                        title: 'SAVE',
                        onSelected: (_) {
                          // var date =
                          //     '$selectedHour:$selectedMinute $selectedPeriod';
                          widget.onSave(selectedFrequency, selectedHour,
                              selectedMinute, selectedDay, selectedPeriod);
                        },
                        length: 2,
                        index: 0,
                      ),
                      CustomButtonGroup(
                        title: 'CANCEL',
                        onSelected: (_) => widget.onCancel(),
                        length: 2,
                        index: 1,
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
