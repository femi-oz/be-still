import 'package:be_still/enums/time_range.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReminderPicker extends StatefulWidget {
  final Function onSave;
  final Function onCancel;
  final List<String> frequency;
  final List<String> reminderDays;
  final bool hideActionuttons;
  final int selectedDay;
  final int selectedMinute;
  final int selectedHour;
  final String selectedPeriod;
  final String selectedFrequency;

  @override
  ReminderPicker({
    this.onSave,
    this.frequency,
    this.reminderDays,
    this.hideActionuttons,
    this.onCancel,
    this.selectedDay = DateTime.wednesday,
    this.selectedHour = 6,
    this.selectedMinute = 30,
    this.selectedPeriod = PeriodOfDay.pm,
    this.selectedFrequency = Frequency.daily,
  });
  _ReminderPickerState createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  double itemExtent = 30.0;

  String selectedFrequency;
  int selectedDay;
  String selectedPeriod;
  int selectedHour;
  int selectedMinute;

  List<String> periodOfDay = [PeriodOfDay.am, PeriodOfDay.pm];
  var hoursOfTheDay = new List<int>.generate(12, (i) => i + 1);
  var minInTheHour = new List<int>.generate(60, (i) => i + 0);

  @override
  void initState() {
    selectedHour = widget.selectedHour != null ? widget.selectedHour : 6;
    selectedMinute = widget.selectedMinute != null ? widget.selectedMinute : 30;
    selectedDay =
        widget.selectedDay != null ? widget.selectedDay : DateTime.wednesday;
    selectedPeriod =
        widget.selectedPeriod != null ? widget.selectedPeriod : PeriodOfDay.pm;
    selectedFrequency = widget.selectedFrequency != null
        ? widget.selectedFrequency
        : Frequency.daily;
    // selectedDay = widget.reminderDays[DateTime.now().weekday - 1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FixedExtentScrollController frequencyController =
        FixedExtentScrollController(
            initialItem: widget.frequency.indexOf(selectedFrequency));
    FixedExtentScrollController daysController = FixedExtentScrollController(
        initialItem:
            widget.reminderDays.indexOf(widget.reminderDays[selectedDay - 1]));
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
                            width: MediaQuery.of(context).size.width * 0.23,
                            child: selectedFrequency == Frequency.weekly
                                ? CupertinoPicker(
                                    selectionOverlay:
                                        CupertinoPickerDefaultSelectionOverlay(
                                      background: Colors.transparent,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    scrollController: daysController,
                                    itemExtent: itemExtent,
                                    onSelectedItemChanged: (i) =>
                                        setState(() => selectedDay = i + 1),
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
                                : Container(height: 31),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.12,
                            child: CupertinoPicker(
                              selectionOverlay:
                                  CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent,
                              ),
                              backgroundColor: Colors.transparent,
                              scrollController: hourController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(
                                  () => selectedHour = hoursOfTheDay[i]),
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
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(':',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.regularText15),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.12,
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
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CustomButtonGroup(
                        title: 'CANCEL',
                        onSelected: (_) => widget.onCancel(),
                        length: 2,
                        index: 0,
                      ),
                      CustomButtonGroup(
                        title: 'SAVE',
                        onSelected: (_) {
                          var min = selectedMinute < 10
                              ? '0$selectedMinute'
                              : '$selectedMinute';
                          var hour = selectedHour < 10
                              ? '0$selectedHour'
                              : '${selectedHour + 1} ';
                          // var date =
                          //     '$selectedHour:$selectedMinute $selectedPeriod';
                          widget.onSave(
                              selectedFrequency,
                              hour,
                              min,
                              widget.reminderDays[selectedDay - 1],
                              selectedPeriod);
                        },
                        length: 2,
                        index: 1,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
