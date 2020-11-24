import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_picker.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:provider/provider.dart';

class AlexaSettings extends StatefulWidget {
  @override
  _AlexaSettingsState createState() => _AlexaSettingsState();
}

class _AlexaSettingsState extends State<AlexaSettings> {
  var snooze;

  setSnooze(value) {
    setState(() {
      snooze = value;
    });
  }

  List<String> prayerTimeInterval = [
    '10s',
    '20s',
    '30s',
    '40s',
  ];

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
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'How to Enable the BeStill skill on Alexa',
              style: TextStyle(
                  color: AppColors.lightBlue3,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
            color: AppColors.getTextFieldBgColor(
                Provider.of<ThemeProvider>(context).isDarkModeEnabled),
            child: OutlineButton(
              borderSide: BorderSide(
                  color: AppColors.getCardBorder(
                      _themeProvider.isDarkModeEnabled)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: Image.asset(
                            'assets/images/amazon.png',
                          ),
                        ),
                        Text(
                          'alexa',
                          style: TextStyle(
                              color: AppColors.getTextFieldText(
                                  _themeProvider.isDarkModeEnabled),
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    FlatButton(
                      child: Text(
                        'LOGOUT',
                        style: TextStyle(
                            color: AppColors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      onPressed: null,
                    )
                  ],
                ),
              ),
              onPressed: () => print('test'),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Allow Alexa to notify me of my Prayer Time?',
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
                    'Sync Notifications / Reminders with Alexa?',
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
              'Prayer Time',
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
                    'Enable Alexa to read prayers from My List?',
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
            width: double.infinity,
            child: Text(
              'Set pause between prayers during Prayer Time',
              style: TextStyle(
                color: AppColors.getTextFieldText(
                    _themeProvider.isDarkModeEnabled),
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 80.0),
            child: CustomPicker(prayerTimeInterval, setSnooze, true, null),
          ),
        ],
      ),
    );
  }
}
