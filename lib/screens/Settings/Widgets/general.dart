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
    setContactStatus();
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

  setContactStatus() async {
    var status = await Permission.contacts.status;
    setState(() =>
        Settings.enabledContactPermission = status == PermissionStatus.granted);
  }

  _openContactConfirmation(BuildContext context) {
    AlertDialog dialog = AlertDialog(
      actionsPadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.all(0),
      backgroundColor: AppColors.prayerCardBgColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.darkBlue),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'You must allow/deny access from your device\'s Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightBlue4,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            // GestureDetector(
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      openAppSettings();
                    },
                    child: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * .30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'GO TO SETTINGS',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.of(context).pop();
                  //   },
                  //   child: Container(
                  //     height: 30,
                  //     width: MediaQuery.of(context).size.width * .20,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(
                  //         color: AppColors.cardBorder,
                  //         width: 1,
                  //       ),
                  //       borderRadius: BorderRadius.circular(5),
                  //     ),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: <Widget>[
                  //         Text(
                  //           'CANCEL',
                  //           style: TextStyle(
                  //             color: AppColors.red,
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Future<void> _setPermission() async {
    var status = await Permission.contacts.request();
    //disabled and alowed through popup
    if (!Settings.enabledContactPermission && status.isGranted)
      setState(() => Settings.enabledContactPermission = true);
    //disabled and is permanently denied (iOS)
    else if (!Settings.enabledContactPermission && status.isPermanentlyDenied) {
      _openContactConfirmation(context);
      setState(() => Settings.enabledContactPermission = true);
    }
    //disabled and denied through popup
    else if (!Settings.enabledContactPermission && status.isDenied)
      setState(() => Settings.enabledContactPermission = false);
    //enabled and needs to be diabled
    else {
      setState(() => Settings.enabledContactPermission = false);
      _openContactConfirmation(context);
    }
  }

  void _updateEmail(UserModel user) async {
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .updateEmail(_newEmail.text, user.id);
      BeStilDialog.showSuccessDialog(
          context, 'Your email has been updated successfully');
      _newEmail.clear();
    } on HttpException catch (_) {
      _newEmail.clear();
      BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
    } catch (e) {
      print(e.message);
      var message = '';
      if (e.message ==
          'The email address is already in use by another account.') {
        message =
            'That email address is already in use. Please select another email.';
      } else {
        message = e.message;
      }
      BeStilDialog.showErrorDialog(context, message);
      _newEmail.clear();
    }
  }

  void _updatePassword() async {
    try {
      // BeStilDialog.showLoading(context);
      await Provider.of<UserProvider>(context, listen: false)
          .updatePassword(_newPassword.text);
      _newPassword.clear();
      _newConfirmPassword.clear();
      // BeStilDialog.hideLoading(context);
      // Navigator.of(context).pop();
      BeStilDialog.showSuccessDialog(
          context, 'Your password has been updated successfully');
    } on HttpException catch (_) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.reloginErrorOccured);
      _newPassword.clear();
      _newConfirmPassword.clear();
    } catch (e) {
      var message = '';
      print(e.message);
      if (e.message == 'username or password is incorrect') {
        message = 'Password is incorrect.';
      } else {
        message = e.message;
      }
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, message);
      _newPassword.clear();
      _newConfirmPassword.clear();
    }
  }

  void _verifyPassword(_user, type, ctx) async {
    try {
      BeStilDialog.showLoading(context);
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .signIn(email: _user.email, password: _currentPassword.text);
      _currentPassword.clear();
      Future.delayed(Duration(milliseconds: 300), () async {
        if (type == _ModalType.email) {
          _updateEmail(_user);
        }

        if (type == _ModalType.password) {
          _updatePassword();
        }
      });
      BeStilDialog.hideLoading(context);
      Navigator.of(context).pop();
    } on HttpException catch (e) {
      _currentPassword.clear();

      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      _currentPassword.clear();
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  List<String> _themeModes = [
    BsThemeMode.light,
    BsThemeMode.dark,
    BsThemeMode.auto,
  ];

  // Widget build

  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Text(
                  '${_currentUser.firstName} ${_currentUser.lastName}',
                  style: AppTextStyles.boldText30.copyWith(height: 1),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          CustomOutlineButton(
            actionColor: AppColors.lightBlue4,
            actionText: 'UPDATE',
            onPressed: () {
              setState(() => isVerified = false);
              _update(_ModalType.email, context);
            },
            value: _currentUser.email,
          ),
          SizedBox(height: 10),
          CustomOutlineButton(
            actionColor: AppColors.lightBlue4,
            actionText: 'UPDATE',
            onPressed: () {
              setState(() => isVerified = false);
              _update(_ModalType.password, context);
            },
            value: 'password',
          ),
          SizedBox(height: 15),
          CustomToggle(
            onChange: (value) => _setPermission(),
            title: 'Allow Be Still to access contacts?',
            value: Settings.enabledContactPermission,
          ),
          SizedBox(height: 20),
          CustomSectionHeder('App Appearance'),
          SizedBox(height: 35),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                for (int i = 0; i < _themeModes.length; i++)
                  CustomButtonGroup(
                    isSelected: _themeProvider.currentTheme == _themeModes[i],
                    length: _themeModes.length,
                    onSelected: (value) => _themeProvider.changeTheme(value),
                    title: _themeModes[i],
                    index: i,
                  ),
              ],
            ),
          ),
          SizedBox(height: 35),
          CustomSectionHeder('App Version'),
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
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Text('App is running the latest version',
                //     style: AppTextStyles.regularText15
                //         .copyWith(color: AppColors.textFieldText)),
                Text(_version, style: AppTextStyles.regularText15),
              ],
            ),
          ),
          SizedBox(height: 30),
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
    );
  }

  void _update(_ModalType type, ctx) {
    var _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final _formKey = GlobalKey<FormState>();
    _newEmail.text = _user.email;
    final alert = AlertDialog(
      insetPadding: EdgeInsets.all(10),
      backgroundColor: AppColors.backgroundColor[1],
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width - 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type == _ModalType.email)
                Text(
                  'Update your email',
                  style: AppTextStyles.boldText20,
                )
              else if (type == _ModalType.password)
                Text(
                  'Update your password',
                  style: AppTextStyles.boldText20,
                ),
              SizedBox(height: 10.0),
              Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (type == _ModalType.email)
                      CustomInput(
                        showSuffix: false,
                        isRequired: true,
                        isEmail: true,
                        label: 'New Email',
                        controller: _newEmail,
                      ),
                    SizedBox(
                      height: 15.0,
                    ),
                    CustomInput(
                      showSuffix: false,
                      isRequired: true,
                      obScurePassword: true,
                      isPassword: true,
                      label: 'Current Password',
                      controller: _currentPassword,
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    if (type == _ModalType.password)
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomInput(
                              obScurePassword: true,
                              showSuffix: false,
                              isRequired: true,
                              isPassword: true,
                              label: 'New Password',
                              controller: _newPassword,
                            ),
                            SizedBox(height: 15.0),
                            CustomInput(
                              obScurePassword: true,
                              showSuffix: false,
                              isRequired: true,
                              label: 'Confirm Password',
                              controller: _newConfirmPassword,
                              validator: (value) {
                                if (_newPassword.text != value) {
                                  return 'Password fields do not match';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 5.0),
                          ],
                        ),
                      ),
                    // SizedBox(height: 40),
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
                            _verifyPassword(
                              _user,
                              type,
                              ctx,
                            );
                          },
                          child: Text(
                            'Submit',
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
      ),
    );
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
