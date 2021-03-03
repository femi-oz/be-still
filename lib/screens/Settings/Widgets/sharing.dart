import 'package:be_still/enums/settings_key.dart';
import 'package:be_still/models/sharing_settings.model.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/custom_input_button.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SharingSettings extends StatefulWidget {
  @override
  _SharingSettingsState createState() => _SharingSettingsState();
}

enum _ModalType { church, email, phone, link }

class _SharingSettingsState extends State<SharingSettings> {
  TextEditingController _churchName = TextEditingController();
  TextEditingController _churchPhone = TextEditingController();
  TextEditingController _churchEmail = TextEditingController();
  TextEditingController _churchLink = TextEditingController();

  void _updateChurch() async {
    try {
      final settingProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSharingSettings(userId,
              key: SettingsKey.churchName,
              settingsId: settingProvider.sharingSettings.id,
              value: _churchName.text);
      Navigator.pop(context);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  void _updateEmail() async {
    try {
      final settingProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSharingSettings(userId,
              key: SettingsKey.churchEmail,
              settingsId: settingProvider.sharingSettings.id,
              value: _churchEmail.text);
      Navigator.pop(context);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  void _updateLink() async {
    try {
      final settingProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSharingSettings(userId,
              key: SettingsKey.webFormLink,
              settingsId: settingProvider.sharingSettings.id,
              value: _churchLink.text);
      Navigator.pop(context);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  void _updatePhone() async {
    try {
      final settingProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final userId =
          Provider.of<UserProvider>(context, listen: false).currentUser.id;
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSharingSettings(userId,
              key: SettingsKey.churchPhone,
              settingsId: settingProvider.sharingSettings.id,
              value: _churchPhone.text);
      Navigator.pop(context);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingProvider = Provider.of<SettingsProvider>(context);
    final userId = Provider.of<UserProvider>(context).currentUser.id;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 40),
          Column(
            children: [
              CustomSectionHeder('Preferences'),
              CustomToggle(
                title: 'Enable sharing via text?',
                onChange: (value) => settingProvider.updateSharingSettings(
                    userId,
                    key: SettingsKey.enableSharingViaText,
                    value: value,
                    settingsId: settingProvider.sharingSettings.id),
                value: settingProvider.sharingSettings.enableSharingViaText,
              ),
              CustomToggle(
                title: 'Enable sharing via email?',
                onChange: (value) => settingProvider.updateSharingSettings(
                    userId,
                    key: SettingsKey.enableSharingViaEmail,
                    value: value,
                    settingsId: settingProvider.sharingSettings.id),
                value: settingProvider.sharingSettings.enableSharingViaEmail,
              ),
            ],
          ),
          SizedBox(height: 40),
          //method hidelAllTextFieled
          GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Column(
              children: [
                CustomSectionHeder('With My Church'),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Set your Church\'s preferred method of submitting prayers here to save it as a quick selection in the sharing options.',
                    style: AppTextStyles.regularText15
                        .copyWith(color: AppColors.textFieldText),
                  ),
                ),
                SizedBox(height: 30),
                CustomOutlineButton(
                  onPressed: () => _update(_ModalType.church, context),
                  actionText: settingProvider.sharingSettings.churchName == ''
                      ? '---------'
                      : settingProvider.sharingSettings.churchName,
                  value: 'Church',
                ),
                SizedBox(height: 15),
                CustomOutlineButton(
                  onPressed: () => _update(_ModalType.email, context),
                  actionText: settingProvider.sharingSettings.churchEmail == ''
                      ? '---------'
                      : settingProvider.sharingSettings.churchEmail,
                  value: 'Email',
                ),
                SizedBox(height: 15),
                CustomOutlineButton(
                  onPressed: () => _update(_ModalType.phone, context),
                  actionText: settingProvider.sharingSettings.churchPhone == ''
                      ? '---------'
                      : settingProvider.sharingSettings.churchPhone,
                  value: 'Phone(mobile only)',
                ),
                SizedBox(height: 15),
                CustomOutlineButton(
                  onPressed: () => _update(_ModalType.link, context),
                  actionText: settingProvider.sharingSettings.webFormlink == ''
                      ? '---------'
                      : settingProvider.sharingSettings.webFormlink,
                  value: 'Web Prayer Form',
                ),
              ],
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  void _update(_ModalType type, ctx) {
    final sharingSettings =
        Provider.of<SettingsProvider>(context, listen: false).sharingSettings;
    _churchEmail.text = sharingSettings.churchEmail;
    _churchName.text = sharingSettings.churchName;
    _churchPhone.text = sharingSettings.churchPhone;
    _churchLink.text = sharingSettings.webFormlink;
    final alert = AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      backgroundColor: AppColors.backgroundColor[1],
      content: Container(
        width: MediaQuery.of(context).size.width - 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            type == _ModalType.church
                ? CustomInput(
                    label: 'Enter Church Name', controller: _churchName)
                : type == _ModalType.email
                    ? CustomInput(
                        label: 'Enter Church Email', controller: _churchEmail)
                    : type == _ModalType.phone
                        ? CustomInput(
                            label: 'Enter Church Phone',
                            controller: _churchPhone)
                        : type == _ModalType.link
                            ? CustomInput(
                                label: 'Enter Church Web Prayer Form Link',
                                controller: _churchLink)
                            : null,
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton(
                  color: AppColors.grey.withOpacity(0.5),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.regularText15.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                FlatButton(
                  color: AppColors.lightBlue3,
                  onPressed: () => type == _ModalType.email
                      ? _updateEmail()
                      : type == _ModalType.church
                          ? _updateChurch()
                          : type == _ModalType.link
                              ? _updateLink()
                              : type == _ModalType.phone
                                  ? _updatePhone()
                                  : null,
                  child: Text('Save',
                      style: AppTextStyles.regularText15.copyWith(
                        color: Colors.white,
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
