import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  void _updateEmail(UserModel user) async {
    BeStilDialog.showConfirmDialog(context,
        message: 'Are you sure you want to update your email?',
        title: 'Update Email', onConfirm: () async {
      try {
        BeStilDialog.showLoading(
          bcontext,
          _key,
        );
        await Provider.of<UserProvider>(context, listen: false)
            .updateEmail(_newEmail.text, user.id);
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(_key);
        Navigator.of(context).pop();
      } on HttpException catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(_key);
        BeStilDialog.showErrorDialog(context, e.message);
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(_key);
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
          _key,
        );
        await Provider.of<UserProvider>(context, listen: false)
            .updatePassword(_newPassword.text);
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(_key);
        Navigator.of(context).pop();
      } on HttpException catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(_key);
        BeStilDialog.showErrorDialog(context, e.message);
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 300));
        BeStilDialog.hideLoading(_key);
        BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
      }
    });
  }

  void _showAlert(_ModalType type) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          var _user =
              Provider.of<UserProvider>(context, listen: false).currentUser;

          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
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
                            style: AppTextStyles.regularText16.copyWith(
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
                            style: AppTextStyles.regularText16.copyWith(
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

  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('${_currentUser.firstName} ${_currentUser.lastName}',
                      style: AppTextStyles.boldText30),
                  Text(
                      DateFormat('MM/dd/yyyy').format(_currentUser.dateOfBirth),
                      style: AppTextStyles.normalDarkBlue),
                ],
              ),
            ),
            SizedBox(height: 25),
            GestureDetector(
              onTap: () => _showAlert(_ModalType.email),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.getTextFieldBorder(
                          _themeProvider.isDarkModeEnabled),
                    ),
                    borderRadius: BorderRadius.circular(3.0),
                    color: AppColors.getTextFieldBgColor(
                        _themeProvider.isDarkModeEnabled)),
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'UPDATE',
                      style: AppTextStyles.regularText18b
                          .copyWith(color: AppColors.lightBlue4),
                    ),
                    Text(
                      _currentUser.email,
                      style: AppTextStyles.regularText14.copyWith(
                          color: AppColors.getTextFieldText(
                              _themeProvider.isDarkModeEnabled)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showAlert(_ModalType.password),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.getTextFieldBorder(
                          _themeProvider.isDarkModeEnabled),
                    ),
                    borderRadius: BorderRadius.circular(3.0),
                    color: AppColors.getTextFieldBgColor(
                        _themeProvider.isDarkModeEnabled)),
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'UPDATE',
                      style: AppTextStyles.regularText18b
                          .copyWith(color: AppColors.lightBlue4),
                    ),
                    Text(
                      'password',
                      style: AppTextStyles.regularText14.copyWith(
                          color: AppColors.getTextFieldText(
                              _themeProvider.isDarkModeEnabled)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showAlert(_ModalType.auth),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.getTextFieldBorder(
                          _themeProvider.isDarkModeEnabled),
                    ),
                    borderRadius: BorderRadius.circular(3.0),
                    color: AppColors.getTextFieldBgColor(
                        _themeProvider.isDarkModeEnabled)),
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'ADD',
                      style: AppTextStyles.regularText18b
                          .copyWith(color: AppColors.red),
                    ),
                    Text(
                      'Two-Factor Authentication',
                      style: AppTextStyles.regularText14.copyWith(
                          color: AppColors.getTextFieldText(
                              _themeProvider.isDarkModeEnabled)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text('Enable Face/Touch ID',
                        style: AppTextStyles.regularText16.copyWith(
                            color: AppColors.getTextFieldText(
                                _themeProvider.isDarkModeEnabled))),
                  ),
                  Switch.adaptive(
                    value: false,
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.lightBlue4,
                    inactiveThumbColor: Colors.white,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      'Allow BeStill to access Contacts?',
                      style: AppTextStyles.regularText16.copyWith(
                          color: AppColors.getTextFieldText(
                              _themeProvider.isDarkModeEnabled)),
                    ),
                  ),
                  Switch.adaptive(
                    value: true,
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.lightBlue4,
                    inactiveThumbColor: Colors.white,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getDropShadow(
                        _themeProvider.isDarkModeEnabled),
                    offset: Offset(0.0, 1.0),
                    blurRadius: 6.0,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors:
                      AppColors.getPrayerMenu(_themeProvider.isDarkModeEnabled),
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                'App Appearance',
                style: AppTextStyles.boldText24.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => _themeProvider.changeTheme(ThemeMode.light),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                      decoration: BoxDecoration(
                        color: _themeProvider.colorMode == ThemeMode.light
                            ? AppColors.getActiveBtn(
                                    _themeProvider.isDarkModeEnabled)
                                .withOpacity(0.3)
                            : Colors.transparent,
                        border: Border.all(
                          color: AppColors.getTextFieldBorder(
                              _themeProvider.isDarkModeEnabled),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        child: Text('LIGHT', style: AppTextStyles.boldText20),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _themeProvider.changeTheme(ThemeMode.dark),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                      decoration: BoxDecoration(
                        color: _themeProvider.colorMode == ThemeMode.dark
                            ? AppColors.getActiveBtn(
                                    _themeProvider.isDarkModeEnabled)
                                .withOpacity(0.3)
                            : Colors.transparent,
                        border: Border.all(
                          color: AppColors.getTextFieldBorder(
                              _themeProvider.isDarkModeEnabled),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        child: Text('DARK', style: AppTextStyles.boldText20),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _themeProvider.changeTheme(ThemeMode.system),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                      decoration: BoxDecoration(
                        color: _themeProvider.colorMode == ThemeMode.system
                            ? AppColors.getActiveBtn(
                                    _themeProvider.isDarkModeEnabled)
                                .withOpacity(0.3)
                            : Colors.transparent,
                        border: Border.all(
                          color: AppColors.getTextFieldBorder(
                              _themeProvider.isDarkModeEnabled),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        child: Text('AUTO', style: AppTextStyles.boldText20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getDropShadow(
                        _themeProvider.isDarkModeEnabled),
                    offset: Offset(0.0, 1.0),
                    blurRadius: 6.0,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors:
                      AppColors.getPrayerMenu(_themeProvider.isDarkModeEnabled),
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                'App Data',
                style: AppTextStyles.boldText24.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: () => _themeProvider.changeTheme(ThemeMode.system),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: AppColors.getTextFieldBorder(
                        _themeProvider.isDarkModeEnabled),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  child: Text(
                    'EXPORT',
                    style: AppTextStyles.boldText20,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('App is running the latest version',
                      style: AppTextStyles.regularText16.copyWith(
                          color: AppColors.getTextFieldText(
                              _themeProvider.isDarkModeEnabled))),
                  Text('1.02', style: AppTextStyles.regularText16),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _themeProvider.changeTheme(ThemeMode.system),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: AppColors.red,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  child: Text(
                    'DELETE ACCOUNT & ALL DATA',
                    style:
                        AppTextStyles.boldText20.copyWith(color: AppColors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
