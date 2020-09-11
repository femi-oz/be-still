import 'package:be_still/widgets/snooze_picker.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';

class NotificationsSettings extends StatefulWidget {
  @override
  _NotificationsSettingsState createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  var snooze;

  setSnooze(value) {
    setState(() {
      snooze = value;
    });
  }

  List<String> emailFrequency = [
    'Daily',
    'Weekly',
    'Monthly',
    'Per Instance',
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
              'Preferences',
              style: TextStyle(
                  color: context.settingsHeader,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Allow push Notifications?',
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
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Allow text Notifications?',
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
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Send notification email updates?',
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
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            width: double.infinity,
            child: Text(
              'Set email update frequency',
              style: TextStyle(
                color: context.inputFieldText,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            child: SnoozePicker(emailFrequency, setSnooze, true),
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Notify me when someone shares a prayer with me',
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
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Notify me when someone posts to a Group I\'m in',
                    style: TextStyle(
                        color: context.inputFieldText,
                        fontSize: 12,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                Switch.adaptive(
                  value: true,
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
