import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../../../utils/app_theme.dart';

class PrayerTools extends StatefulWidget {
  @override
  PrayerTools();

  @override
  _PrayerToolsState createState() => _PrayerToolsState();
}

class _PrayerToolsState extends State<PrayerTools> {
  var view = 'active';
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: FlatButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, color: AppColors.lightBlue5),
              label: Text(
                'BACK',
                style: TextStyle(
                  color: AppColors.lightBlue5,
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
                          color: AppColors.lightBlue3,
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
                                ? AppColors.getActiveBtn(
                                        _themeProvider.isDarkModeEnabled)
                                    .withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: AppColors.lightBlue6,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: AppColors.lightBlue4,
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
                                ? AppColors.getActiveBtn(
                                        _themeProvider.isDarkModeEnabled)
                                    .withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: AppColors.lightBlue6,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'SNOOZED',
                              style: TextStyle(
                                color: AppColors.lightBlue4,
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
                                ? AppColors.getActiveBtn(
                                        _themeProvider.isDarkModeEnabled)
                                    .withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: AppColors.lightBlue6,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'ARCHIVED',
                              style: TextStyle(
                                color: AppColors.lightBlue4,
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
                                ? AppColors.getActiveBtn(
                                        _themeProvider.isDarkModeEnabled)
                                    .withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: AppColors.lightBlue6,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'ANSWERED',
                              style: TextStyle(
                                color: AppColors.lightBlue4,
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
