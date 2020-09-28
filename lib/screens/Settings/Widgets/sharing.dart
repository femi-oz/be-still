import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';

class SharingSettings extends StatefulWidget {
  @override
  _SharingSettingsState createState() => _SharingSettingsState();
}

class _SharingSettingsState extends State<SharingSettings> {
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
                    'Enable sharing via text?',
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
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    'Enable sharing via email?',
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
              'With My Church',
              style: TextStyle(
                  color: context.settingsHeader,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Set your Church\'s preferred method of submitting prayers here to save it as a quick selection in the sharing options.',
              style: TextStyle(
                  color: context.inputFieldText,
                  fontSize: 12,
                  fontWeight: FontWeight.w300),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 10),
            color: context.inputFieldBg,
            child: OutlineButton(
              borderSide: BorderSide(color: context.inputFieldBorder),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Carthage Baptist Church',
                      style: TextStyle(
                          color: context.brightBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      'Church',
                      style: TextStyle(
                          color: context.inputFieldText,
                          fontSize: 10,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              onPressed: () => print('test'),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(left: 20.0, right: 20.0, top: 5, bottom: 10),
            color: context.inputFieldBg,
            child: OutlineButton(
              borderSide: BorderSide(color: context.inputFieldBorder),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'prayer@carthagebc.com',
                      style: TextStyle(
                          color: context.brightBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      'Email',
                      style: TextStyle(
                          color: context.inputFieldText,
                          fontSize: 10,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              onPressed: () => print('test'),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(left: 20.0, right: 20.0, top: 5, bottom: 10),
            color: context.inputFieldBg,
            child: OutlineButton(
              borderSide: BorderSide(color: context.inputFieldBorder),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '771.877.3437',
                      style: TextStyle(
                          color: context.brightBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      'Phone(mobile only)',
                      style: TextStyle(
                          color: context.inputFieldText,
                          fontSize: 10,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              onPressed: () => print('test'),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(left: 20.0, right: 20.0, top: 5, bottom: 80),
            color: context.inputFieldBg,
            child: OutlineButton(
              borderSide: BorderSide(color: context.inputFieldBorder),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        strutStyle: StrutStyle(fontSize: 12.0),
                        text: TextSpan(
                            style: TextStyle(
                                color: context.brightBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                            text: 'carthagebc.com/prayer/request/testing'),
                      ),
                    ),
                    Text(
                      'Web Prayer Form',
                      style: TextStyle(
                          color: context.inputFieldText,
                          fontSize: 10,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              onPressed: () => print('test'),
            ),
          ),
        ],
      ),
    );
  }
}