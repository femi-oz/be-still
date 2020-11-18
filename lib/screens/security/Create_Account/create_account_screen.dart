import 'dart:async';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:be_still/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Widgets/create-account-form.dart';

class CreateAccountScreen extends StatefulWidget {
  static const routeName = '/create-account';

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // var step = 1;

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  TextEditingController _date = new TextEditingController();
  TextEditingController _firstnameController = new TextEditingController();
  TextEditingController _lastnameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  DateTime _selectedDate;
  bool _enableSubmit = false;
  final _key = GlobalKey<State>();

  _selectDate(DateTime value) async {
    setState(() {
      _selectedDate = value;
    });
  }

  _agreeTerms(bool value) {
    setState(() {
      _enableSubmit = value;
    });
  }

  void _createAccount() async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return null;
    _formKey.currentState.save();

    final UserModel _userData = UserModel(
      churchId: 0,
      createdBy: '${_firstnameController.text} ${_lastnameController.text}'
          .toUpperCase(),
      createdOn: DateTime.now(),
      dateOfBirth: _selectedDate,
      email: _emailController.text,
      firstName: _firstnameController.text,
      keyReference: '',
      lastName: _lastnameController.text,
      modifiedBy: '${_firstnameController.text} ${_lastnameController.text}'
          .toUpperCase(),
      modifiedOn: DateTime.now(),
      phone: '',
    );
    await BeStilDialog.showLoading(context, _key, 'Registering');
    try {
      final result =
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .registerUser(
                  password: _passwordController.text, userData: _userData);

      if (result) {
        await Provider.of<UserProvider>(context, listen: false)
            .setCurrentUser();
        new Timer(
            Duration(seconds: 2),
            () => Navigator.of(context)
                .pushReplacementNamed(PrayerScreen.routeName));
        BeStilDialog.hideLoading(_key);
      }
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(_key);
      BeStillSnackbar.showInSnackBar(
          message: "Your account couldn't be created. Please try again",
          key: _scaffoldKey);
    } catch (e) {
      BeStilDialog.hideLoading(_key);
      BeStillSnackbar.showInSnackBar(
          message: 'An error occured. Please try again', key: _scaffoldKey);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: AppColors.offWhite1,
        content: new Text(value),
      ),
    );
  }

  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
            ),
            image: DecorationImage(
              image: AssetImage(StringUtils.getBackgroundImage(
                  _themeProvider.isDarkModeEnabled)),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                CustomLogoShape(),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Container(
                          child: CreateAccountForm(
                            autoValidate: _autoValidate,
                            confirmPasswordController:
                                _confirmPasswordController,
                            passwordController: _passwordController,
                            datePickerController: _date,
                            dobController: _dobController,
                            emailController: _emailController,
                            formKey: _formKey,
                            firstnameController: _firstnameController,
                            lastnameController: _lastnameController,
                            selectDate: _selectDate,
                            agreeTerms: _agreeTerms,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildFooter() {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => !_enableSubmit
              ? showInSnackBar(
                  'Accept terms to proceed',
                )
              : _createAccount(),
          child: Container(
            height: 50.0,
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.lightBlue1,
                  AppColors.lightBlue2,
                ],
              ),
            ),
            child: Icon(
              _enableSubmit ? Icons.arrow_forward : Icons.do_not_disturb,
              color: AppColors.offWhite1,
            ),
          ),
        ),
        InkWell(
          child: Text(
            "Go Back",
            style: AppTextStyles.regularText13,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}
