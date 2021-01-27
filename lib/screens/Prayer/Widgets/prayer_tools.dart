import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerFilters extends StatefulWidget {
  @override
  _PrayerFiltersState createState() => _PrayerFiltersState();
}

class _PrayerFiltersState extends State<PrayerFilters> {
  String status;
  bool isSnoozed;
  bool isAnswered;
  bool isArchived;
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    var filterOptions = Provider.of<PrayerProvider>(context).filterOptions;
    status = filterOptions.status;
    isSnoozed = filterOptions.isSnoozed;
    isAnswered = filterOptions.isAnswered;
    isArchived = filterOptions.isArchived;
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: FlatButton.icon(
              onPressed: () async {
                // await Provider.of<PrayerProvider>(context).filterPrayers(
                //   isAnswered: isAnswered,
                //   isArchived: isArchived,
                //   isSnoozed: isSnoozed,
                //   status: status,
                // );
                Navigator.of(context).pop();
              },
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
                            () async {
                              status = status == Status.active
                                  ? Status.inactive
                                  : Status.active;
                              await Provider.of<PrayerProvider>(context,
                                      listen: false)
                                  .filterPrayers(
                                isAnswered: isAnswered,
                                isArchived: isArchived,
                                isSnoozed: isSnoozed,
                                status: status,
                              );
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
                            color: filterOptions.status == Status.active
                                ? AppColors.activeButton.withOpacity(0.2)
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
                              Status.active,
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
                            () async {
                              isSnoozed = !isSnoozed;
                              status = Status.inactive;
                              await Provider.of<PrayerProvider>(context,
                                      listen: false)
                                  .filterPrayers(
                                isAnswered: isAnswered,
                                isArchived: isArchived,
                                isSnoozed: isSnoozed,
                                status: status,
                              );
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
                            color: filterOptions.isSnoozed == true
                                ? AppColors.activeButton.withOpacity(0.2)
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
                            () async {
                              isArchived = !isArchived;
                              await Provider.of<PrayerProvider>(context,
                                      listen: false)
                                  .filterPrayers(
                                isAnswered: isAnswered,
                                isArchived: isArchived,
                                isSnoozed: isSnoozed,
                                status: status,
                              );
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
                            color: filterOptions.isArchived == true
                                ? AppColors.activeButton.withOpacity(0.2)
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
                            () async {
                              isAnswered = !isAnswered;
                              await Provider.of<PrayerProvider>(context,
                                      listen: false)
                                  .filterPrayers(
                                isAnswered: isAnswered,
                                isArchived: isArchived,
                                isSnoozed: isSnoozed,
                                status: status,
                              );
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
                            color: filterOptions.isAnswered == true
                                ? AppColors.activeButton.withOpacity(0.2)
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
                      Provider.of<PrayerProvider>(context).currentPrayerType ==
                              PrayerType.group
                          ? GestureDetector(
                              onTap: () => null,
                              child: Container(
                                height: 50,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 10),
                                decoration: BoxDecoration(
                                  color: filterOptions.isAnswered == true
                                      ? AppColors.activeButton.withOpacity(0.2)
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
                                    'GROUP SETTINGS',
                                    style: TextStyle(
                                      color: AppColors.lightBlue4,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
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
