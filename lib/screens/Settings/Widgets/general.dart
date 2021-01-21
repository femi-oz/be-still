import 'package:be_still/enums/theme_mode.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/settings_provider.dart';
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

enum _ModalType { email, password, auth }

class _GeneralSettingsState extends State<GeneralSettings> {
  TextEditingController _newEmail = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  BuildContext bcontext;
  var _key = GlobalKey<State>();
  var _version = '';

  _getVersion() async {
    try {
      _version = await GetVersion.projectVersion;
    } on PlatformException {
      _version = '0.0';
    }
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }

  _initiatePermission() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      //We can now access our contacts here
    }
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

  void _showAlert(_ModalType type) {
    final _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        builder: (context) {
          var _user =
              Provider.of<UserProvider>(context, listen: false).currentUser;
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              color: AppColors.backgroundColor[1],
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: type == _ModalType.email
                          ? CustomInput(
                              label: 'New Email', controller: _newEmail)
                          : type == _ModalType.password
                              ? CustomInput(
                                  label: 'New Email', controller: _newPassword)
                              : Text('Auth'),
                    ),
                  ),
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
                        child: Text('Submit',
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
        });
  }

  List<String> _themeModes = [
    BsThemeMode.light,
    BsThemeMode.dark,
    BsThemeMode.auto,
  ];

  Widget build(BuildContext context) {
    _getVersion();
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
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
                    onPressed: () => _showAlert(_ModalType.email),
                    isDarkModeEnabled: Settings.isDarkMode,
                    value: _currentUser.email),
                SizedBox(height: 10),
                CustomOutlineButton(
                    actionColor: AppColors.lightBlue4,
                    actionText: 'UPDATE',
                    onPressed: () => _showAlert(_ModalType.password),
                    isDarkModeEnabled: Settings.isDarkMode,
                    value: 'password'),
                SizedBox(height: 10),
                CustomOutlineButton(
                    actionColor: AppColors.red,
                    actionText: 'ADD',
                    onPressed: () => null,
                    isDarkModeEnabled: Settings.isDarkMode,
                    value: 'Two-Factor Authentication'),
                SizedBox(height: 10),
              ],
            ),
            Column(
              children: [
                CustomToggle(
                  onChange: (value) => null,
                  title: 'Enable Face/Touch ID',
                  value: Provider.of<SettingsProvider>(context).isFaceIdEnabled,
                ),
                CustomToggle(
                  onChange: (value) => _initiatePermission(),
                  title: 'Allow BeStill to access Contacts?',
                  value:
                      Provider.of<SettingsProvider>(context).hasAccessToContact,
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
                          isSelected: Settings.themeMode == _themeModes[i],
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 40.0, horizontal: 20.0),
                  child: Row(
                    children: [
                      CustomButtonGroup(
                        onSelected: () => null,
                        title: 'DELETE ACCOUNT & ALL DATA',
                        color: AppColors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
