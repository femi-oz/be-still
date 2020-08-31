import 'dart:async';

import 'package:be_still/src/Data/user.data.dart';
import 'package:be_still/src/screens/Forget_Password/Widgets/step_three.dart';
import 'package:be_still/src/screens/Forget_Password/Widgets/step_two.dart';
import 'package:be_still/src/widgets/auth_screen_painter.dart';
import 'package:flutter/material.dart';
import 'package:be_still/src/Providers/app_provider.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'Widgets/step_one.dart';
import 'Widgets/sucess.dart';

class ForgetPassword extends StatefulWidget {
  static const routeName = '/forget-password';

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  int step = 1;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _codeController = new TextEditingController();
  TextEditingController _confirmcodeController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  bool _autoValidate1 = false;
  bool _autoValidate2 = false;
  bool _autoValidate3 = false;

  Map<String, String> _formData = {
    'userName': '',
    'code': '',
    'password': '',
  };

  _next() {
    setState(() {
      if (step == 1) {
        _autoValidate1 = true;
        if (!_formKey1.currentState.validate()) return;
        _formKey1.currentState.save();
        _formData['userName'] = _usernameController.text;
      } else if (step == 2) {
        _autoValidate2 = true;
        if (!_formKey2.currentState.validate()) return;
        _formKey2.currentState.save();
        _formData['code'] = _codeController.text;
      } else if (step == 3) {
        _autoValidate3 = true;
        if (!_formKey3.currentState.validate()) return;
        _formKey3.currentState.save();
        _formData['password'] = _passwordController.text;
      }
      print(_formData);
      step += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        body: Container(
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
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: step == 1
                            ? ForgetPasswordOne(
                                autoValidate: _autoValidate1,
                                formKey: _formKey1,
                                usernameController: _usernameController,
                              )
                            : step == 2
                                ? ForgetPasswordTwo(
                                    autoValidate: _autoValidate2,
                                    formKey: _formKey2,
                                    codeController: _codeController,
                                    confirmcodeController:
                                        _confirmcodeController,
                                  )
                                : step == 3
                                    ? ForgetPasswordThree(
                                        autoValidate: _autoValidate3,
                                        formKey: _formKey3,
                                        confirmPasswordController:
                                            _confirmPasswordController,
                                        passwordController: _passwordController,
                                      )
                                    : ForgetPasswordSucess(),
                      ),
                      step > 3
                          ? Container()
                          : Container(
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
                                          _next();
                                          if (step == 4) {
                                            var user = userData.singleWhere(
                                                (user) => user.id == '1');
                                            _app.setCurrentUser(user);
                                            return new Timer(
                                              Duration(seconds: 5),
                                              () => {
                                                _app.login(),
                                                Navigator.of(context)
                                                    .pushNamed('/')
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
                                  step > 2
                                      ? Container()
                                      : GestureDetector(
                                          child: Text(
                                            "Go Back",
                                            style: TextStyle(
                                              color: context.brightBlue2,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.of(context)
                                                .pushReplacementNamed('/');
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
