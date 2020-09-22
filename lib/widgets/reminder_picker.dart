import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class ReminderPicker extends StatefulWidget {
  final _setReminder;

  final interval;

  final reminderDays;

  final hideActionuttons;

  @override
  ReminderPicker(this._setReminder, this.interval, this.reminderDays,
      this.hideActionuttons);
  _ReminderPickerState createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  int selected = 0;

  double itemExtent = 30.0;

  FixedExtentScrollController daysController =
      FixedExtentScrollController(initialItem: 2);
  FixedExtentScrollController hourController =
      FixedExtentScrollController(initialItem: 5);
  FixedExtentScrollController minuteController =
      FixedExtentScrollController(initialItem: 15);
  FixedExtentScrollController intervalController =
      FixedExtentScrollController(initialItem: 2);
  FixedExtentScrollController ampmController =
      FixedExtentScrollController(initialItem: 1);

  List<String> ampm = ['AM', 'PM'];

  var selectedInterval = 'Hourly';
  var selectedDay = '01';
  var selectedHour = '01';
  var selectedMinute = '00';
  var selectedAMpm = 'AM';
  @override
  Widget build(BuildContext context) {
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
                              scrollController: intervalController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() {
                                selectedInterval = widget.interval[i];
                              }),
                              children: <Widget>[
                                ...widget.interval
                                    .map((i) => Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            i,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: context.brightBlue2,
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
                            child: CupertinoPicker(
                              scrollController: daysController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() {
                                var selected = i + 1;
                                selectedDay =
                                    selected < 10 ? '0$selected' : '$selected';
                              }),
                              children: <Widget>[
                                ...widget.reminderDays.map(
                                  (r) => Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      r,
                                      style: TextStyle(
                                        color: context.brightBlue2,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: CupertinoPicker(
                              scrollController: hourController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() {
                                var selected = i + 1;
                                selectedHour =
                                    selected < 10 ? '0$selected' : '$selected';
                              }),
                              children: <Widget>[
                                for (var i = 1; i <= 12; i++)
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      i < 10 ? '0$i' : '$i',
                                      style: TextStyle(
                                        color: context.brightBlue2,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: CupertinoPicker(
                                // scrollController: minuteController,
                                itemExtent: itemExtent,
                                onSelectedItemChanged: (i) => null,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      ':',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: context.brightBlue2,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: CupertinoPicker(
                              scrollController: minuteController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() {
                                var selected = i + 1;
                                selectedMinute =
                                    selected < 10 ? '0$selected' : '$selected';
                              }),
                              children: <Widget>[
                                for (var i = 0; i < 60; i++)
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      i < 10 ? '0$i' : '$i',
                                      style: TextStyle(
                                        color: context.brightBlue2,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: CupertinoPicker(
                              scrollController: ampmController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() {
                                selectedAMpm = ampm[i];
                              }),
                              children: <Widget>[
                                ...ampm
                                    .map(
                                      (x) => Align(
                                        child: Text(
                                          x,
                                          style: TextStyle(
                                            color: context.brightBlue2,
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
                      GestureDetector(
                        onTap: () {
                          var amPm = selectedAMpm == 'PM' ? 'P' : 'A';
                          widget._setReminder(
                              '$selectedInterval | $selectedDay | $selectedHour:$selectedMinute$amPm');
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width * .38,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.inputFieldBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'SAVE',
                                style: TextStyle(
                                  color: context.brightBlue2,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width * .38,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.inputFieldBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: context.brightBlue2,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
