import 'dart:async';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/screens/splash/splash_screen.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/widgets/auth_screen_painter.dart';
import 'package:be_still/widgets/dialog.dart';
import 'package:be_still/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Widgets/create-account-form.dart';
import 'Widgets/success.dart';

class CreateAccountScreen extends StatefulWidget {
  static const routeName = '/create-account';

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  var step = 1;

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

  _createAccount() async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return null;
    _formKey.currentState.save();
    UserModel _user = Provider.of<UserProvider>(context).currentUser;

    final UserModel _userData = UserModel(
      churchId: 0,
      createdBy: '${_user.firstName} ${_user.lastName}'.toUpperCase(),
      createdOn: DateTime.now(),
      dateOfBirth: _selectedDate,
      email: _emailController.text,
      firstName: _firstnameController.text,
      keyReference: '',
      lastName: _lastnameController.text,
      modifiedBy: '${_user.firstName} ${_user.lastName}'.toUpperCase(),
      modifiedOn: DateTime.now(),
      phone: '',
    );
    await BeStilDialog.showLoading(
        context, _key, context.brightBlue, 'Registering');
    try {
      final result =
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .registerUser(
                  password: _passwordController.text, userData: _userData);

      if (result) {
        BeStilDialog.hideLoading(_key);
        await Provider.of<UserProvider>(context, listen: false)
            .setCurrentUser();
        setState(() => step += 1);
        return new Timer(
            Duration(seconds: 2),
            () => Navigator.of(context)
                .pushReplacementNamed(PrayerScreen.routeName));
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
        backgroundColor: context.offWhite,
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
              colors: [
                context.mainBgStart,
                context.mainBgEnd,
              ],
            ),
            image: DecorationImage(
              image: AssetImage(_themeProvider.isDarkModeEnabled
                  ? 'assets/images/background-pattern-dark.png'
                  : 'assets/images/background-pattern.png'),
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                CustomPaint(
                  painter: AuthCustomPainter(context.authPainterStart,
                      context.authPainterEnd, context.authPainterShadow),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: step == 1
                              ? CreateAccountForm(
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
                                )
                              : CreateAccountSuccess(),
                        ),
                      ),
                      step > 1
                          ? Container()
                          : Column(
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
                                          context.authBtnStart,
                                          context.authBtnEnd,
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      _enableSubmit
                                          ? Icons.arrow_forward
                                          : Icons.do_not_disturb,
                                      color: context.offWhite,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  child: Text(
                                    "Already have an account? Login!",
                                    style: TextStyle(
                                      color: context.brightBlue2,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                SizedBox(height: 20.0),
                              ],
                            ),
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
}
