import 'package:be_still/enums/theme_mode.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/theme_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_input_button.dart';
import 'package:be_still/widgets/custom_section_header.dart';
import 'package:be_still/widgets/custom_select_button.dart';
import 'package:be_still/widgets/custom_toggle.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_version/get_version.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class GeneralSettings extends StatefulWidget {
  final SettingsModel settings;

  @override
  GeneralSettings(this.settings);

  @override
  _GeneralSettingsState createState() => _GeneralSettingsState();
}

enum _ModalType { email, password }

class _GeneralSettingsState extends State<GeneralSettings> {
  TextEditingController _newEmail = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  BuildContext bcontext;
  var _version = '';

  _getVersion() async {
    try {
      _version = await GetVersion.projectVersion;
    } on PlatformException {
      _version = '0.0';
    }
  }

  Future<void> _setPermission() async {
    if (Settings.enabledContactPermission)
      setState(() => Settings.enabledContactPermission = false);
    else
      await Permission.contacts.request().then((p) {
        setState(() =>
            Settings.enabledContactPermission = p == PermissionStatus.granted);
      });
  }

  void _updateEmail(UserModel user) async {
    BeStilDialog.showConfirmDialog(context,
        message: 'Are you sure you want to update your email?',
        title: 'Update Email', onConfirm: () async {
      try {
        BeStilDialog.showLoading(
          bcontext,
        );
        await Provider.of<UserProvider>(context, listen: false)
            .updateEmail(_newEmail.text, user.id);
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(context);
        Navigator.of(context).pop();
      } on HttpException catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(context);
        BeStilDialog.showErrorDialog(context, e.message);
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(context);
        BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
      }
    });
  }

  _updatePassword() {
    BeStilDialog.showConfirmDialog(context,
        message: 'Are you sure you want to update your password?',
        title: 'Update Password', onConfirm: () async {
      try {
        BeStilDialog.showLoading(
          bcontext,
        );
        await Provider.of<UserProvider>(context, listen: false)
            .updatePassword(_newPassword.text);
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(context);
        Navigator.of(context).pop();
      } on HttpException catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(context);
        BeStilDialog.showErrorDialog(context, e.message);
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(context);
        BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
      }
    });
  }

  void _update(_ModalType type, ctx) {
    var _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final alert = AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      backgroundColor: AppColors.backgroundColor[1],
      content: Container(
        // color: AppColors.backgroundColor[1],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            type == _ModalType.email
                ? CustomInput(label: 'New Email', controller: _newEmail)
                : type == _ModalType.password
                    ? CustomInput(
                        label: 'New Password', controller: _newPassword)
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
                    )),
                FlatButton(
                  color: AppColors.lightBlue3,
                  onPressed: () => type == _ModalType.email
                      ? _updateEmail(_user)
                      : type == _ModalType.password
                          ? _updatePassword
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

  List<String> _themeModes = [
    BsThemeMode.light,
    BsThemeMode.dark,
    BsThemeMode.auto,
  ];

  Widget build(BuildContext context) {
    _getVersion();

    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    final _themeProvider = Provider.of<ThemeProvider>(context);
    setState(() => this.bcontext = context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
          bottom: 20.0,
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('${_currentUser.firstName} ${_currentUser.lastName}',
                      style: AppTextStyles.boldText30),
                  Text(
                      DateFormat('MM/dd/yyyy').format(_currentUser.dateOfBirth),
                      style: AppTextStyles.regularText13),
                ],
              ),
            ),
            SizedBox(height: 25),
            Column(
              children: [
                CustomOutlineButton(
                    actionColor: AppColors.lightBlue4,
                    actionText: 'UPDATE',
                    onPressed: () => _update(_ModalType.email, context),
                    value: _currentUser.email),
                SizedBox(height: 10),
                CustomOutlineButton(
                    actionColor: AppColors.lightBlue4,
                    actionText: 'UPDATE',
                    onPressed: () => _update(_ModalType.password, context),
                    value: 'password'),
                SizedBox(height: 10),
                CustomOutlineButton(
                    actionColor: AppColors.red,
                    actionText: 'ADD',
                    onPressed: () => null,
                    value: 'Two-Factor Authentication'),
                SizedBox(height: 10),
              ],
            ),
            Column(
              children: [
                CustomToggle(
                  onChange: (value) =>
                      setState(() => Settings.enableLocalAuth = value),
                  title: 'Enable Face/Touch ID',
                  value: Settings.enableLocalAuth,
                ),
                CustomToggle(
                  onChange: (value) => _setPermission(),
                  title: 'Allow BeStill to access Contacts?',
                  value: Settings.enabledContactPermission,
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              children: [
                CustomSectionHeder('App Appearance'),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      for (int i = 0; i < _themeModes.length; i++)
                        CustomButtonGroup(
                          isSelected:
                              _themeProvider.currentTheme == _themeModes[i],
                          length: _themeModes.length,
                          onSelected: (value) =>
                              _themeProvider.changeTheme(value),
                          title: _themeModes[i],
                          index: i,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                CustomSectionHeder('App Data'),
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //       vertical: 40.0, horizontal: 20.0),
                //   child: Row(
                //     children: [
                //       CustomButtonGroup(
                //         onSelected: () => null,
                //         title: 'EXPORT',
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('App is running the latest version',
                          style: AppTextStyles.regularText15
                              .copyWith(color: AppColors.textFieldText)),
                      Text(_version, style: AppTextStyles.regularText15),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //       vertical: 40.0, horizontal: 20.0),
                //   child: Row(
                //     children: [
                //       CustomButtonGroup(
                //         onSelected: () => null,
                //         title: 'DELETE ACCOUNT & ALL DATA',
                //         color: AppColors.red,
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
