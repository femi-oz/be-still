import 'package:be_still/src/widgets/snooze_picker.dart';
import 'package:flutter/material.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';

class MyListSettings extends StatefulWidget {
  @override
  _MyListSettingsState createState() => _MyListSettingsState();
}

class _MyListSettingsState extends State<MyListSettings> {
  var sortBy = 'date';
  var snooze;
  var activeSortBy = 'date';

  setSnooze(value) {
    setState(() {
      snooze = value;
    });
  }

  List<String> snoozeInterval = [
    '7 Days',
    '14 Days',
    '30 Days',
    '90 Days',
    '1 Year'
  ];
  List<String> autoDeleteInterval = [
    '30 Days',
    '90 Days',
    '1 Year',
    '2 Years',
    'Never'
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: context.dropShadow,
                  offset: Offset(0.0, 0.5),
                  blurRadius: 5.0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  context.prayerMenuStart,
                  context.prayerMenuEnd,
                ],
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              'Default Sort By',
              style: TextStyle(
                  color: context.settingsHeader,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: sortBy == 'date'
                        ? context.toolsActiveBtn.withOpacity(0.3)
                        : Colors.transparent,
                    border: Border.all(
                      color: context.inputFieldBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.transparent),
                    child: Container(
                      child: Text(
                        'DATE',
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        sortBy = 'date';
                      });
                    },
                  ),
                ),
                Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: sortBy == 'tag'
                        ? context.toolsActiveBtn.withOpacity(0.5)
                        : Colors.transparent,
                    border: Border.all(
                      color: context.inputFieldBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.transparent),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5),
                      child: Text(
                        'TAG',
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        sortBy = 'tag';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 40.0),
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: context.dropShadow,
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  context.prayerMenuStart,
                  context.prayerMenuEnd,
                ],
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              'Default Snooze Duration',
              style: TextStyle(
                  color: context.settingsHeader,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            child: SnoozePicker(snoozeInterval, setSnooze, true),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: context.dropShadow,
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  context.prayerMenuStart,
                  context.prayerMenuEnd,
                ],
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              'Active Default Sort By',
              style: TextStyle(
                  color: context.settingsHeader,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: activeSortBy == 'date'
                        ? context.toolsActiveBtn.withOpacity(0.3)
                        : Colors.transparent,
                    border: Border.all(
                      color: context.inputFieldBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.transparent),
                    child: Container(
                      child: Text(
                        'DATE',
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        activeSortBy = 'date';
                      });
                    },
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: activeSortBy == 'tag'
                        ? context.toolsActiveBtn.withOpacity(0.5)
                        : Colors.transparent,
                    border: Border.all(
                      color: context.inputFieldBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.transparent),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5),
                      child: Text(
                        'TAG',
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        activeSortBy = 'tag';
                      });
                    },
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: activeSortBy == 'answered'
                        ? context.toolsActiveBtn.withOpacity(0.5)
                        : Colors.transparent,
                    border: Border.all(
                      color: context.inputFieldBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.transparent),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5),
                      child: Text(
                        'ANSWERED',
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        activeSortBy = 'answered';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: context.dropShadow,
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  context.prayerMenuStart,
                  context.prayerMenuEnd,
                ],
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              'Active Auto Delete',
              style: TextStyle(
                  color: context.settingsHeader,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            child: SnoozePicker(autoDeleteInterval, setSnooze, true),
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 80.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Include Answered Prayers in Auto Delete?',
                    style: TextStyle(
                        color: context.inputFieldText,
                        fontSize: 12,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                Switch.adaptive(
                  value: false,
                  activeColor: Colors.white,
                  activeTrackColor: context.switchThumbActive,
                  inactiveThumbColor: Colors.white,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
