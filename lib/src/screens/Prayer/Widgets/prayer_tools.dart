import 'package:flutter/material.dart';
import './../../../widgets/Theme/app_theme.dart';

class PrayerTools extends StatefulWidget {
  @override
  PrayerTools();

  @override
  _PrayerToolsState createState() => _PrayerToolsState();
}

class _PrayerToolsState extends State<PrayerTools> {
  var view = 'active';
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: FlatButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, color: context.toolsBackBtn),
              label: Text(
                'BACK',
                style: TextStyle(
                  color: context.toolsBackBtn,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'VIEW',
                        style: TextStyle(
                          color: context.brightBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              view = 'active';
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          decoration: BoxDecoration(
                            color: view == 'active'
                                ? context.toolsActiveBtn.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: context.toolsBtnBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: context.brightBlue2,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              view = 'snoozed';
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          decoration: BoxDecoration(
                            color: view == 'snoozed'
                                ? context.toolsActiveBtn.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: context.toolsBtnBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'SNOOZED',
                              style: TextStyle(
                                color: context.brightBlue2,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              view = 'archived';
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          decoration: BoxDecoration(
                            color: view == 'archived'
                                ? context.toolsActiveBtn.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: context.toolsBtnBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'ARCHIVED',
                              style: TextStyle(
                                color: context.brightBlue2,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              view = 'answered';
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          decoration: BoxDecoration(
                            color: view == 'answered'
                                ? context.toolsActiveBtn.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: context.toolsBtnBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'ANSWERED',
                              style: TextStyle(
                                color: context.brightBlue2,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
