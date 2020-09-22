import 'dart:async';

import 'package:be_still/data/user.data.dart';

import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/widgets/auth_screen_painter.dart';
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
  TextEditingController _fullnameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();

  Map<String, String> _formData = {
    'fullName': '',
    'password': '',
    'dob': '',
    'email': '',
  };

  void _createAccount() {
    setState(() {
      _autoValidate = true;
      if (!_formKey.currentState.validate()) return;
      _formKey.currentState.save();
      _formData['fullName'] = _fullnameController.text;
      _formData['email'] = _emailController.text;
      _formData['dob'] = _dobController.text;
      _formData['password'] = _passwordController.text;
      print(_formData);
      step += 1;
    });
  }

  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    _next() {
      if (step == 2) {
        var user = userData.singleWhere((user) => user.id == '1');
        Provider.of<UserProvider>(context, listen: false).setCurrentUser(user);
        return new Timer(
          Duration(seconds: 2),
          () => {
            Provider.of<AuthProvider>(context, listen: false).login(),
            Navigator.of(context).pushNamed(PrayerScreen.routeName)
          },
        );
      }
      return null;
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
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
                                  fullnameController: _fullnameController,
                                )
                              : CreateAccountSuccess(),
                        ),
                      ),
                      step > 1
                          ? Container()
                          : Column(
                              children: <Widget>[
                                InkWell(
                                  onTap: () =>
                                      {print(step), _createAccount(), _next()},
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
                                      Icons.arrow_forward,
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
                                )
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
