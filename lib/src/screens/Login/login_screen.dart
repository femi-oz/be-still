import 'package:be_still/src/Data/user.data.dart';
import 'package:be_still/src/screens/Prayer/prayer_screen.dart';
import 'package:be_still/src/widgets/auth_screen_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../../widgets/Theme/app_theme.dart';
import '../../Providers/app_provider.dart';

import '../../widgets/input_field.dart';
import '../Create_Account/create_account_screen.dart';
import '../Forget_Password/forget_password.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool _autoValidate = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    _authenticate(String text) {
      setState(() {
        _autoValidate = true;
      });
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        if ((userData.singleWhere(
                (user) => user.username == _usernameController.text,
                orElse: () => null)) !=
            null) {
          var user = userData
              .singleWhere((user) => user.username == _usernameController.text);
          if (user.password == _passwordController.text) {
            _app.setCurrentUser(user);
            _app.login();
            Navigator.of(context).pushReplacementNamed(PrayerScreen.routeName);
          } else {
            _scaffoldKey.currentState.showSnackBar(
              new SnackBar(
                backgroundColor: context.brightBlue2,
                content: new Text('Password doesn\'t match'),
              ),
            );
          }
        } else {
          _scaffoldKey.currentState.showSnackBar(
            new SnackBar(
              backgroundColor: context.brightBlue2,
              content: new Text('User doesn\'t exist!'),
            ),
          );
        }
      }
    }

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
                  height: MediaQuery.of(context).size.height * 0.6,
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 10),
                            Form(
                              autovalidate: _autoValidate,
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  CustomInput(
                                    label: 'Username',
                                    controller: _usernameController,
                                    keyboardType: TextInputType.text,
                                    isRequired: true,
                                  ),
                                  SizedBox(height: 10.0),
                                  CustomInput(
                                    isPassword: true,
                                    label: 'Password',
                                    controller: _passwordController,
                                    keyboardType: TextInputType.visiblePassword,
                                    isRequired: true,
                                    textInputAction: TextInputAction.done,
                                    unfocus: true,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(
                                  child: Text(
                                    "Create an Account",
                                    style: TextStyle(
                                        color: context.brightBlue2,
                                        fontSize: 14),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pushReplacementNamed(
                                        CreateAccountScreen.routeName);
                                  },
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Remember Me',
                                      style: TextStyle(
                                          color: context.brightBlue2,
                                          fontSize: 14),
                                    ),
                                    Switch.adaptive(
                                      activeColor: Colors.white,
                                      activeTrackColor:
                                          context.switchThumbActive,
                                      inactiveThumbColor: Colors.white,
                                      value: rememberMe,
                                      onChanged: (_) {
                                        setState(
                                            () => {rememberMe = !rememberMe});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
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
                                  _authenticate('');
                                },
                                color: Colors.transparent,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: context.offWhite,
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Text(
                                "Forget my Password",
                                style: TextStyle(
                                  color: context.brightBlue2,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed(
                                    ForgetPassword.routeName);
                              },
                            ),
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
