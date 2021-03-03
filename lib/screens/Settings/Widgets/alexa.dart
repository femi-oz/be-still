import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/duration.model.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/custom_input_button.dart';
import 'package:be_still/widgets/custom_picker.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlexaSettings extends StatefulWidget {
  final SettingsModel settings;

  AlexaSettings(this.settings);
  @override
  _AlexaSettingsState createState() => _AlexaSettingsState();
}

class _AlexaSettingsState extends State<AlexaSettings> {
  _onChangeTime(value) {
    Provider.of<SettingsProvider>(context, listen: false).updateSettings(
        Provider.of<UserProvider>(context, listen: false).currentUser.id,
        key: SettingsKey.pauseInterval,
        value: value,
        settingsId: widget.settings.id);
  }

  List<LookUp> prayerTimeInterval = [
    LookUp(text: SecondsInterval.ten),
    LookUp(text: SecondsInterval.twenty),
    LookUp(text: SecondsInterval.thirty),
    LookUp(text: SecondsInterval.fourty),
  ];

  @override
  Widget build(BuildContext context) {
    final setingProvider = Provider.of<SettingsProvider>(context);
    final userId = Provider.of<UserProvider>(context).currentUser.id;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          Column(
            children: [
              CustomSectionHeder('Preferences'),
              SizedBox(height: 40),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'How to Enable the BeStill skill on Alexa',
                  style: AppTextStyles.regularText20,
                ),
              ),
              SizedBox(height: 40),
              CustomOutlineButton(
                actionText: 'CONNECTED',
                value: 'LOGOUT',
                icon: 'assets/images/amazon.png',
                textColor: AppColors.red,
                onPressed: () => null,
              ),
              SizedBox(height: 20),
              CustomToggle(
                title: 'Allow Alexa to notify me of my Prayer Time?',
                onChange: (value) => setingProvider.updateSettings(userId,
                    key: SettingsKey.allowPrayerTimeNotification,
                    value: value,
                    settingsId: widget.settings.id),
                value: widget.settings.allowPrayerTimeNotification,
              ),
              CustomToggle(
                title: 'Sync Notifications / Reminders with Alexa?',
                onChange: (value) => setingProvider.updateSettings(userId,
                    key: SettingsKey.syncAlexa,
                    value: value,
                    settingsId: widget.settings.id),
                value: widget.settings.syncAlexa,
              ),
            ],
          ),
          SizedBox(height: 30),
          Column(
            children: [
              CustomSectionHeder('Prayer Time'),
              CustomToggle(
                title: 'Enable Alexa to read prayers from My List?',
                onChange: (value) => setingProvider.updateSettings(userId,
                    key: SettingsKey.allowAlexaReadPrayer,
                    value: value,
                    settingsId: widget.settings.id),
                value: widget.settings.allowAlexaReadPrayer,
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    width: double.infinity,
                    child: Text(
                      'Set pause between prayers during Prayer Time',
                      style: AppTextStyles.regularText15
                          .copyWith(color: AppColors.textFieldText),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 80.0),
                    child: CustomPicker(
                        prayerTimeInterval, _onChangeTime, true, 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
