import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/duration.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsSettings extends StatefulWidget {
  final SettingsModel settings;

  NotificationsSettings(this.settings);
  @override
  _NotificationsSettingsState createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  List<LookUp> emailFrequency = [
    LookUp(text: Frequency.daily, value: 1440),
    LookUp(text: Frequency.weekly, value: 10080),
    LookUp(text: Frequency.monthly, value: 43200),
    LookUp(text: Frequency.per_instance, value: 0),
  ];
  setEmailUpdateFrequency(value) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        Provider.of<UserProvider>(context, listen: false).currentUser.id,
        key: SettingsKey.emailUpdateFrequency,
        value: value,
        settingsId: widget.settings.id);
  }

  @override
  Widget build(BuildContext context) {
    final setingProvider = Provider.of<SettingsProvider>(context);
    final userId = Provider.of<UserProvider>(context).currentUser.id;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 15.0),
          CustomSectionHeder('Preferences'),
          SizedBox(height: 20.0),
          CustomToggle(
            title: 'Allow push notifications?',
            onChange: (value) => setingProvider.updateSettings(userId,
                key: SettingsKey.allowPushNotification,
                value: value,
                settingsId: widget.settings.id),
            value: widget.settings.allowPushNotification,
          ),
          // CustomToggle(
          //   title: 'Allow text Notifications?',
          //   onChange: (value) => setingProvider.updateSettings(userId,
          //       key: SettingsKey.allowTextNotification,
          //       value: value,
          //       settingsId: widget.settings.id),
          //   value: widget.settings.allowTextNotification,
          // ),
          // CustomToggle(
          //   title: 'Send notification email updates?',
          //   onChange: (value) => setingProvider.updateSettings(userId,
          //       key: SettingsKey.emailUpdateNotification,
          //       value: value,
          //       settingsId: widget.settings.id),
          //   value: widget.settings.emailUpdateNotification,
          // ),
          // Column(
          //   children: [
          //     Container(
          //       padding: EdgeInsets.only(left: 20.0, right: 20.0),
          //       width: double.infinity,
          //       child: Text(
          //         'Set email update frequency',
          //         style: AppTextStyles.regularText15
          //             .copyWith(color: AppColors.textFieldText),
          //         textAlign: TextAlign.left,
          //       ),
          //     ),
          //     Container(
          //       child: CustomPicker(
          //           emailFrequency, setEmailUpdateFrequency, true, 1440),
          //     ),
          //   ],
          // ),
          // CustomToggle(
          //   title: 'Notify me when someone shares a prayer with me',
          //   onChange: (value) => setingProvider.updateSettings(userId,
          //       key: SettingsKey.notifyMeSomeoneSharePrayerWithMe,
          //       value: value,
          //       settingsId: widget.settings.id),
          //   value: widget.settings.notifyMeSomeoneSharePrayerWithMe,
          // ),
          // CustomToggle(
          //   title: 'Notify me when someone posts to a Group I\'m in',
          //   onChange: (value) => setingProvider.updateSettings(userId,
          //       key: SettingsKey.notifyMeSomeonePostOnGroup,
          //       value: value,
          //       settingsId: widget.settings.id),
          //   value: widget.settings.notifyMeSomeonePostOnGroup,
          // ),
        ],
      ),
    );
  }
}
