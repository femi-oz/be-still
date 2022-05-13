import 'dart:io';

import 'package:be_still/enums/time_range.dart';
import 'package:be_still/models/duration.model.dart';
import 'package:be_still/models/settings.model.dart';

import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/string_utils.dart';
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
    try {} on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 15.0),
          CustomSectionHeder('Preferences'),
          SizedBox(height: 20.0),
          CustomToggle(
            title: 'Allow push notifications?',
            onChange: (value) =>
                Provider.of<UserProviderV2>(context, listen: false)
                    .updateUserSettings('enablePushNotification', value),
            value: widget.settings.allowPushNotification ?? false,
          ),
        ],
      ),
    );
  }
}
