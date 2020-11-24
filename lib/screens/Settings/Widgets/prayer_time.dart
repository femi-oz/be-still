import 'package:be_still/models/prayer_settings.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/reminder_picker.dart';
import 'package:be_still/widgets/snooze_picker.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:provider/provider.dart';

class PrayerTimeSettings extends StatefulWidget {
  final PrayerSettingsModel prayerSettings;

  @override
  PrayerTimeSettings(this.prayerSettings);
  _PrayerTimeSettingsState createState() => _PrayerTimeSettingsState();
}

class _PrayerTimeSettingsState extends State<PrayerTimeSettings> {
  var snooze;
  var reminder;

  setSnooze(value) {
    setState(() {
      snooze = value;
    });
  }

  List<String> prayerTimeInterval = [
    'Evening Listening',
    'Rock Jams',
    'Prayer Time',
    'Jason Station',
    'New Hits'
  ];

  List<String> reminderInterval = ['Daily', 'Weekly', 'T-Th', 'M-W-F'];

  List reminderDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  setReminder(value) {
    setState(() {
      reminder = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.getDropShadow(_themeProvider.isDarkModeEnabled),
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors:
                    AppColors.getPrayerMenu(_themeProvider.isDarkModeEnabled),
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              'Preferences',
              style: TextStyle(
                  color: AppColors.offWhite2,
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
                    'Allow emergency calls (second call from the same number calls within 2 minutes)',
                    style: TextStyle(
                        color: AppColors.getTextFieldText(
                            _themeProvider.isDarkModeEnabled),
                        fontSize: 12,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                Switch.adaptive(
                  value: false,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.lightBlue4,
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
                    'Set to Do Not Disturb during Prayer Time?',
                    style: TextStyle(
                        color: AppColors.getTextFieldText(
                            _themeProvider.isDarkModeEnabled),
                        fontSize: 12,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                Switch.adaptive(
                  value: true,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.lightBlue4,
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
                    'Enable background music during Prayer Mode?F',
                    style: TextStyle(
                        color: AppColors.getTextFieldText(
                            _themeProvider.isDarkModeEnabled),
                        fontSize: 12,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                Switch.adaptive(
                  value: false,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.lightBlue4,
                  inactiveThumbColor: Colors.white,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            color:
                AppColors.getTextFieldBgColor(_themeProvider.isDarkModeEnabled),
            child: OutlineButton(
              borderSide: BorderSide(
                  color: AppColors.getCardBorder(
                      _themeProvider.isDarkModeEnabled)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'CONNECTED',
                      style: TextStyle(
                          color: AppColors.lightBlue3,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Image.asset('assets/images/spotify.png'),
                        ),
                        Text(
                          'Spotify',
                          style: TextStyle(
                              color: AppColors.getTextFieldText(
                                  _themeProvider.isDarkModeEnabled),
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              onPressed: () => print('test'),
            ),
          ),
          Container(
            child: SnoozePicker(prayerTimeInterval, setSnooze, true, null),
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Auto play music during prayer time?',
                    style: TextStyle(
                        color: AppColors.getTextFieldText(
                            _themeProvider.isDarkModeEnabled),
                        fontSize: 12,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                Switch.adaptive(
                  value: true,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.lightBlue4,
                  inactiveThumbColor: Colors.white,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.getDropShadow(_themeProvider.isDarkModeEnabled),
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors:
                    AppColors.getPrayerMenu(_themeProvider.isDarkModeEnabled),
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              'My Prayer Time',
              style: TextStyle(
                  color: AppColors.offWhite2,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'T-Th',
                          style: TextStyle(
                              color: AppColors.getTextFieldText(
                                  _themeProvider.isDarkModeEnabled),
                              fontSize: 10,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          'Wed',
                          style: TextStyle(
                              color: AppColors.getTextFieldText(
                                  _themeProvider.isDarkModeEnabled),
                              fontSize: 10,
                              fontWeight: FontWeight.w400),
                        ),
                        Container(
                          width: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '06',
                                style: TextStyle(
                                    color: AppColors.getTextFieldText(
                                        _themeProvider.isDarkModeEnabled),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                ':',
                                style: TextStyle(
                                    color: AppColors.getTextFieldText(
                                        _themeProvider.isDarkModeEnabled),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                '15',
                                style: TextStyle(
                                    color: AppColors.getTextFieldText(
                                        _themeProvider.isDarkModeEnabled),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                'PM',
                                style: TextStyle(
                                    color: AppColors.getTextFieldText(
                                        _themeProvider.isDarkModeEnabled),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.lightBlue3,
                    ),
                    onPressed: null),
                IconButton(
                  icon: Icon(
                    Icons.not_interested,
                    color: AppColors.lightBlue3,
                  ),
                  onPressed: null,
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 80.0),
            child: ReminderPicker(
              setReminder,
              reminderInterval,
              reminderDays,
              false,
            ),
          ),
        ],
      ),
    );
  }
}
