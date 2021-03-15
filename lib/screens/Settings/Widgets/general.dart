import 'package:be_still/enums/theme_mode.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/settings.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/widgets/snackbar.dart';
import 'package:package_info/package_info.dart';
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
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class GeneralSettings extends StatefulWidget {
  final SettingsModel settings;
  final scaffoldKey;

  @override
  GeneralSettings(this.settings, this.scaffoldKey);

  @override
  _GeneralSettingsState createState() => _GeneralSettingsState();
}

enum _ModalType { email, password }

class _GeneralSettingsState extends State<GeneralSettings> {
  TextEditingController _newEmail = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _newConfirmPassword = TextEditingController();
  TextEditingController _currentPassword = TextEditingController();
  var _version = '';

  bool isVerified = false;

  @override
  void initState() {
    _getVersion();
    super.initState();
  }

  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    try {
      _version = packageInfo.version;
      setState(
          () => _version = '${packageInfo.version}-${packageInfo.buildNumber}');
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
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<UserProvider>(context, listen: false)
          .updateEmail(_newEmail.text, user.id);
      _newEmail.clear();
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pop();
      BeStillSnackbar.showInSnackBar(
          type: 'success',
          message: 'Your email has been updated successfully',
          key: widget.scaffoldKey);
    } on HttpException catch (_) {
      _newEmail.clear();
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
    } catch (e) {
      _newEmail.clear();
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
    }
  }

  void _updatePassword() async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<UserProvider>(context, listen: false)
          .updatePassword(_newPassword.text);
      _newPassword.clear();
      _newConfirmPassword.clear();
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pop();
      BeStillSnackbar.showInSnackBar(
          type: 'success',
          message: 'Your password has been updated successfully',
          key: widget.scaffoldKey);
    } on HttpException catch (_) {
      _newPassword.clear();
      _newConfirmPassword.clear();
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
    } catch (e) {
      _newPassword.clear();
      _newConfirmPassword.clear();
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
    }
  }

  void _verifyPassword(String email, type, ctx) async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .signIn(email: email, password: _currentPassword.text);
      _currentPassword.clear();
      setState(() => isVerified = true);
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pop();
      _update(type, ctx);
    } on HttpException catch (_) {
      _currentPassword.clear();
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
    } catch (e) {
      _currentPassword.clear();
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
    }
  }

  List<String> _themeModes = [
    BsThemeMode.light,
    BsThemeMode.dark,
    BsThemeMode.auto,
  ];

  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    final _themeProvider = Provider.of<ThemeProvider>(context);
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
                    onPressed: () {
                      setState(() => isVerified = false);
                      _update(_ModalType.email, context);
                    },
                    value: _currentUser.email),
                SizedBox(height: 10),
                CustomOutlineButton(
                    actionColor: AppColors.lightBlue4,
                    actionText: 'UPDATE',
                    onPressed: () {
                      setState(() => isVerified = false);
                      _update(_ModalType.password, context);
                    },
                    value: 'password'),
                SizedBox(height: 10),
                // CustomOutlineButton(
                //     actionColor: AppColors.red,
                //     actionText: 'ADD',
                //     onPressed: () => null,
                //     value: 'Two-Factor Authentication'),
                // SizedBox(height: 10),
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

  void _update(_ModalType type, ctx) {
    var _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final _formKey = GlobalKey<FormState>();
    _newEmail.text = _user.email;
    final alert = AlertDialog(
      insetPadding: EdgeInsets.all(10),
      backgroundColor: AppColors.backgroundColor[1],
      content: Container(
        width: MediaQuery.of(context).size.width - 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isVerified)
              Text(
                'Verify your password',
                style: AppTextStyles.boldText20,
              )
            else if (isVerified && type == _ModalType.email)
              Text(
                'Update your email',
                style: AppTextStyles.boldText20,
              )
            else if (isVerified && type == _ModalType.password)
              Text(
                'Update your password',
                style: AppTextStyles.boldText20,
              ),
            SizedBox(height: 30.0),
            Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isVerified)
                    CustomInput(
                        showSuffix: false,
                        isRequired: true,
                        obScurePassword: true,
                        label: 'Re-enter your password to continue',
                        controller: _currentPassword)
                  else if (isVerified && type == _ModalType.email)
                    CustomInput(
                        showSuffix: false,
                        isRequired: true,
                        isEmail: true,
                        label: 'Enter new email',
                        controller: _newEmail)
                  else if (isVerified && type == _ModalType.password)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomInput(
                            obScurePassword: true,
                            showSuffix: false,
                            isRequired: true,
                            isPassword: true,
                            label: 'Enter new pssword',
                            controller: _newPassword),
                        SizedBox(height: 15.0),
                        CustomInput(
                          obScurePassword: true,
                          showSuffix: false,
                          isRequired: true,
                          label: 'Cofirm pssword',
                          controller: _newConfirmPassword,
                          validator: (value) {
                            if (_newPassword.text != value) {
                              return 'Password fields do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              AppColors.grey.withOpacity(0.5)),
                        ),
                        onPressed: () {
                          _newPassword.clear();
                          _newEmail.clear();
                          _newConfirmPassword.clear();
                          _currentPassword.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.regularText15.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              AppColors.lightBlue3),
                        ),
                        onPressed: () {
                          if (!_formKey.currentState.validate()) return null;
                          _formKey.currentState.save();

                          if (!isVerified)
                            _verifyPassword(_user.email, type, ctx);
                          else if (isVerified && type == _ModalType.email)
                            _updateEmail(_user);
                          else if (isVerified && type == _ModalType.password)
                            _updatePassword();
                        },
                        child: Text(
                          !isVerified ? 'Proceed' : 'Submit',
                          style: AppTextStyles.regularText15.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
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
