import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:be_still/utils/app_theme.dart';

class GeneralSettings extends StatelessWidget {
  final SettingsModel settings;

  @override
  GeneralSettings(this.settings);

  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    print(settings);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
          bottom: 20.0,
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    _currentUser.firstName, //TODO
                    style: TextStyle(
                        color: context.settingsUsername,
                        fontSize: 28,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    DateFormat('MM/dd/yyyy').format(_currentUser.dateOfBirth),
                    style: TextStyle(
                        color: context.settingsUsername.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Container(
              margin:
                  EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 15),
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
                        'UPDATE',
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        _currentUser.email,
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
              margin: EdgeInsets.only(bottom: 15, left: 20.0, right: 20.0),
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
                        'UPDATE',
                        style: TextStyle(
                            color: context.brightBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        'password',
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
              margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15),
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
                        'ADD',
                        style: TextStyle(
                            color: context.prayerCardTags,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        'Two-Factor Authentication',
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
              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      'Allow BeStill to access Contacts?',
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
                      'Enable Face/Touch ID',
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
                'App Appearance',
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
                      color: _themeProvider.colorMode == 'light'
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
                          'LIGHT',
                          style: TextStyle(
                              color: context.brightBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onPressed: () => _themeProvider.changeTheme('light'),
                    ),
                  ),
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: _themeProvider.colorMode == 'dark'
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
                          'DARK',
                          style: TextStyle(
                              color: context.brightBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onPressed: () => _themeProvider.changeTheme('dark'),
                    ),
                  ),
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: _themeProvider.colorMode == 'auto'
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
                          'AUTO',
                          style: TextStyle(
                              color: context.brightBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onPressed: () => _themeProvider.changeTheme('auto'),
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
                'App Data',
                style: TextStyle(
                    color: context.settingsHeader,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: context.prayerCardBorder,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: OutlineButton(
                  borderSide: BorderSide(color: Colors.transparent),
                  child: Container(
                    child: Text(
                      'EXPORT',
                      style: TextStyle(
                          color: context.brightBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  onPressed: null,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'App is running the latest version',
                    style: TextStyle(
                      color: context.inputFieldText,
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    '1.02',
                    style: TextStyle(
                      color: context.brightBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 80),
              child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: context.prayerCardTags,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: OutlineButton(
                  borderSide: BorderSide(color: Colors.transparent),
                  child: Container(
                    child: Text(
                      'DELETE ACCOUNT & ALL DATA',
                      style: TextStyle(
                          color: context.prayerCardTags,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  onPressed: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
