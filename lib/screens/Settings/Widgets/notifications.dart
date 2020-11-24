import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/custom_picker.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          CustomSectionHeder('Preferences'),
          CustomToggle(
            title: 'Allow push Notifications?',
            onChange: null,
            value: widget.settings.allowPushNotification,
          ),
          CustomToggle(
            title: 'Allow text Notifications?',
            onChange: null,
            value: widget.settings.allowTextNotification,
          ),
          CustomToggle(
            title: 'Send notification email updates?',
            onChange: null,
            value: widget.settings.emailUpdateNotification,
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            width: double.infinity,
            child: Text(
              'Set email update frequency',
              style: AppTextStyles.regularText16.copyWith(
                  color: AppColors.getTextFieldText(
                      _themeProvider.isDarkModeEnabled)),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            child: CustomPicker(emailFrequency, () => null, true, 2),
          ),
          CustomToggle(
            title: 'Notify me when someone shares a prayer with me',
            onChange: () => null,
            value: widget.settings.notifyMeSomeoneSharePrayerWithMe,
          ),
          CustomToggle(
            title: 'Notify me when someone posts to a Group I\'m in',
            onChange: () => null,
            value: widget.settings.notifyMeSomeonePostOnGroup,
          ),
        ],
      ),
    );
  }
}
