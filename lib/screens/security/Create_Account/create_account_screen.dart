import 'dart:async';

import 'package:be_still/Data/user.data.dart';
import 'package:be_still/Providers/app_provider.dart';
import 'package:be_still/screens/Prayer/prayer_screen.dart';
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

  _createAccount() {
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
    final _app = Provider.of<AppProvider>(context);
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
              image: AssetImage(_app.isDarkModeEnabled
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
                          : Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: <Widget>[
                                  Container(
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
                                    child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          _createAccount();
                                          if (step == 2) {
                                            var user = userData.singleWhere(
                                                (user) => user.id == '1');
                                            _app.setCurrentUser(user);
                                            return new Timer(
                                              Duration(seconds: 5),
                                              () => {
                                                _app.login(),
                                                Navigator.of(context).pushNamed(
                                                    PrayerScreen.routeName)
                                              },
                                            );
                                          }
                                          return null;
                                        });
                                      },
                                      color: Colors.transparent,
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
                                      Navigator.of(context)
                                          .pushNamed(LoginScreen.routeName);
                                    },
                                  )
                                ],
                              ),
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
