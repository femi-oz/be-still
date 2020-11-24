import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/share_prayer.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/snooze_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../../../utils/app_theme.dart';

class AddPrayerMenu extends StatefulWidget {
  @override
  _AddPrayerMenuState createState() => _AddPrayerMenuState();
}

class _AddPrayerMenuState extends State<AddPrayerMenu> {
  var reminder = '';
  var snooze = '';
  List reminderDays = [];
  initState() {
    for (var i = 1; i <= 31; i++) {
      setState(() {
        reminderDays.add(i < 10 ? '0$i' : '$i');
      });
    }
    super.initState();
  }

  setReminder(value) {
    setState(() {
      reminder = value;
    });
  }

  setSnooze(value) {
    setState(() {
      snooze = value;
    });
  }

  List<String> reminderInterval = [
    'Hourly',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly'
  ];
  List<String> snoozeInterval = [
    '7 Days',
    '14 Days',
    '30 Days',
    '90 Days',
    '1 Year'
  ];

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      barrierColor: AppColors.getDetailBgColor(
                              _themeProvider.isDarkModeEnabled)[1]
                          .withOpacity(0.5),
                      backgroundColor: AppColors.getDetailBgColor(
                              _themeProvider.isDarkModeEnabled)[1]
                          .withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return ReminderPicker(
                          hideActionuttons: false,
                          frequency: reminderInterval,
                          reminderDays: reminderDays,
                          onCancel: null,
                          onSave: null,
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Reminder',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      barrierColor: AppColors.getDetailBgColor(
                              _themeProvider.isDarkModeEnabled)[1]
                          .withOpacity(0.5),
                      backgroundColor: AppColors.getDetailBgColor(
                              _themeProvider.isDarkModeEnabled)[1]
                          .withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SharePrayer();
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.share,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Share',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      barrierColor: AppColors.getDetailBgColor(
                              _themeProvider.isDarkModeEnabled)[1]
                          .withOpacity(0.5),
                      backgroundColor: AppColors.getDetailBgColor(
                              _themeProvider.isDarkModeEnabled)[1]
                          .withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SnoozePicker(
                            snoozeInterval, setSnooze, false, null);
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.brightness_3,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Snooze',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: AppColors.getTextFieldText(_themeProvider.isDarkModeEnabled),
          ),
        ],
      ),
    );
  }
}
