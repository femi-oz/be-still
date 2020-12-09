import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_input_button.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SharingSettings extends StatefulWidget {
  final SharingSettingsModel sharingSettings;
  @override
  SharingSettings(this.sharingSettings);
  _SharingSettingsState createState() => _SharingSettingsState();
}

class _SharingSettingsState extends State<SharingSettings> {
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final setingProvider = Provider.of<SettingsProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 40),
          Column(
            children: [
              CustomSectionHeder('Preferences'),
              CustomToggle(
                title: 'Enable sharing via text?',
                onChange: (value) => setingProvider.updateSharingSettings(
                    key: SettingsKey.enableSharingViaText,
                    value: value,
                    settingsId: widget.sharingSettings.id),
                value: widget.sharingSettings.enableSharingViaText,
              ),
              CustomToggle(
                title: 'Enable sharing via email?',
                onChange: (value) => setingProvider.updateSharingSettings(
                    key: SettingsKey.enableSharingViaEmail,
                    value: value,
                    settingsId: widget.sharingSettings.id),
                value: widget.sharingSettings.enableSharingViaEmail,
              ),
            ],
          ),
          SizedBox(height: 40),
          Column(
            children: [
              CustomSectionHeder('With My Church'),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Set your Church\'s preferred method of submitting prayers here to save it as a quick selection in the sharing options.',
                  style: AppTextStyles.regularText16.copyWith(
                      color: AppColors.getTextFieldText(
                          _themeProvider.isDarkModeEnabled)),
                ),
              ),
              SizedBox(height: 30),
              CustomOutlineButton(
                actionText: 'Carthage Baptist Church',
                value: 'Church',
                isDarkModeEnabled: _themeProvider.isDarkModeEnabled,
              ),
              SizedBox(height: 15),
              CustomOutlineButton(
                actionText: 'prayer@carthagebc.com',
                value: 'Email',
                isDarkModeEnabled: _themeProvider.isDarkModeEnabled,
              ),
              SizedBox(height: 15),
              CustomOutlineButton(
                actionText: '771.877.3437',
                value: 'Phone(mobile only)',
                isDarkModeEnabled: _themeProvider.isDarkModeEnabled,
              ),
              SizedBox(height: 15),
              CustomOutlineButton(
                actionText: 'carthagebc.com/prayer/request/',
                value: 'Web Prayer Form',
                isDarkModeEnabled: _themeProvider.isDarkModeEnabled,
              ),
            ],
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
