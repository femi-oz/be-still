import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Theme/app_theme.dart';

class SnoozePicker extends StatefulWidget {
  final _setSnooze;

  final hideActionuttons;

  final interval;

  @override
  SnoozePicker(this.interval, this._setSnooze, this.hideActionuttons);
  _SnoozePickerState createState() => _SnoozePickerState();
}

class _SnoozePickerState extends State<SnoozePicker> {
  int selected = 2;

  double itemExtent = 30.0;


  var selectedInterval;
  @override
  Widget build(BuildContext context) {
  FixedExtentScrollController scrollController = FixedExtentScrollController(initialItem: selected);
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
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: CupertinoPicker(
                              // looping: true,
                              scrollController: scrollController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() {
                                selectedInterval = widget.interval[i];
                              }),
                              children: <Widget>[
                                ...widget.interval
                                    .map(
                                      (i) => Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          i,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: context.brightBlue2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
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
                          widget._setSnooze('$selectedInterval');
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
