import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/v2/duration.model.dart';

import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_input_button.dart';
import 'package:be_still/widgets/custom_picker.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:flutter/material.dart';

class AlexaSettings extends StatefulWidget {
  final SettingsModel settings;

  AlexaSettings(this.settings);
  @override
  _AlexaSettingsState createState() => _AlexaSettingsState();
}

class _AlexaSettingsState extends State<AlexaSettings> {
  _onChangeTime(value) {}

  List<LookUpV2> prayerTimeInterval = [
    LookUpV2(text: SecondsInterval.ten, value: 10),
    LookUpV2(text: SecondsInterval.twenty, value: 20),
    LookUpV2(text: SecondsInterval.thirty, value: 30),
    LookUpV2(text: SecondsInterval.fourty, value: 40),
  ];

  @override
  Widget build(BuildContext context) {
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
                  'How to Enable the Be Still skill on Alexa',
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
                onChange: (value) {},
                value: widget.settings.allowPrayerTimeNotification ?? false,
              ),
              CustomToggle(
                title: 'Sync Notifications / Reminders with Alexa?',
                onChange: (value) {},
                value: widget.settings.syncAlexa ?? false,
              ),
            ],
          ),
          SizedBox(height: 30),
          Column(
            children: [
              CustomSectionHeder('Prayer Time'),
              CustomToggle(
                title: 'Enable Alexa to read prayers from My Prayers?',
                onChange: (value) {},
                value: widget.settings.allowAlexaReadPrayer ?? false,
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
