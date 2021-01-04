import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/custom_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsSettings extends StatefulWidget {
  final SettingsModel settings;

  NotificationsSettings(this.settings);
  @override
  _NotificationsSettingsState createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  List<String> emailFrequency = [
    Frequency.daily,
    Frequency.weekly,
    Frequency.monthly,
    Frequency.per_instance,
  ];
  setEmailUpdateFrequency(value) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        key: SettingsKey.emailUpdateFrequency,
        value: value,
        settingsId: widget.settings.id);
  }

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    final setingProvider = Provider.of<SettingsProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          CustomSectionHeder('Preferences'),
          CustomToggle(
            title: 'Allow push Notifications?',
            onChange: (value) => setingProvider.updateSettings(
                key: SettingsKey.allowPushNotification,
                value: value,
                settingsId: widget.settings.id),
            value: widget.settings.allowPushNotification,
          ),
          CustomToggle(
            title: 'Allow text Notifications?',
            onChange: (value) => setingProvider.updateSettings(
                key: SettingsKey.allowTextNotification,
                value: value,
                settingsId: widget.settings.id),
            value: widget.settings.allowTextNotification,
          ),
          CustomToggle(
            title: 'Send notification email updates?',
            onChange: (value) => setingProvider.updateSettings(
                key: SettingsKey.emailUpdateNotification,
                value: value,
                settingsId: widget.settings.id),
            value: widget.settings.emailUpdateNotification,
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                width: double.infinity,
                child: Text(
                  'Set email update frequency',
                  style: AppTextStyles.regularText15.copyWith(
                      color: AppColors.getTextFieldText(
                          _themeProvider.isDarkModeEnabled)),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                child: CustomPicker(
                    emailFrequency, setEmailUpdateFrequency, true, 2),
              ),
            ],
          ),
          CustomToggle(
            title: 'Notify me when someone shares a prayer with me',
            onChange: (value) => setingProvider.updateSettings(
                key: SettingsKey.notifyMeSomeoneSharePrayerWithMe,
                value: value,
                settingsId: widget.settings.id),
            value: widget.settings.notifyMeSomeoneSharePrayerWithMe,
          ),
          CustomToggle(
            title: 'Notify me when someone posts to a Group I\'m in',
            onChange: (value) => setingProvider.updateSettings(
                key: SettingsKey.notifyMeSomeonePostOnGroup,
                value: value,
                settingsId: widget.settings.id),
            value: widget.settings.notifyMeSomeonePostOnGroup,
          ),
        ],
      ),
    );
  }
}
