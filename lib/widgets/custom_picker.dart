import 'package:be_still/models/v2/duration.model.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomPicker extends StatefulWidget {
  final Function onChange;
  final int selected;
  final bool hideActionuttons;
  final List<LookUpV2> lookup;

  @override
  CustomPicker(
      this.lookup, this.onChange, this.hideActionuttons, this.selected);
  _CustomPickerState createState() => _CustomPickerState();
}

class _CustomPickerState extends State<CustomPicker> {
  double itemExtent = 30.0;
  LookUpV2 selectedInterval = LookUpV2(text: '', value: 0);
  @override
  Widget build(BuildContext context) {
    int selectedIndex =
        widget.lookup.map((e) => e.value).toList().indexOf(widget.selected);
    FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: selectedIndex);
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: MediaQuery.of(context).size.height * 0.2,
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
                              selectionOverlay:
                                  CupertinoPickerDefaultSelectionOverlay(
                                background: Colors.transparent,
                              ),
                              scrollController: scrollController,
                              itemExtent: itemExtent,
                              onSelectedItemChanged: (i) => setState(() {
                                selectedInterval = widget.lookup[i];
                                widget.onChange(selectedInterval.value);
                              }),
                              children: <Widget>[
                                ...widget.lookup
                                    .map((i) => Align(
                                        alignment: Alignment.center,
                                        child: Text(i.text ?? '',
                                            textAlign: TextAlign.center,
                                            style:
                                                AppTextStyles.regularText15)))
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
                          widget.onChange(selectedInterval.value);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width * .38,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('SAVE', style: AppTextStyles.boldText18),
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
                              color: AppColors.cardBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('CANCEL', style: AppTextStyles.boldText18),
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
