import 'package:be_still/data/user.data.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/widgets/auth_screen_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../../../utils/app_theme.dart';
import '../../../widgets/input_field.dart';
import '../Create_Account/create_account_screen.dart';
import '../Forget_Password/forget_password.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool rememberMe = false;
  bool _autoValidate = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _authenticate() async {
    final _authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    setState(() {
      _autoValidate = true;
    });
    if (!_formKey.currentState.validate()) {
      showInSnackBar('All fields are required');
      return;
    }
    _formKey.currentState.save();

    final result = await _authProvider.login(
      context: context,
      email: _usernameController.text,
      password: _passwordController.text,
    );
    if (result is bool) {
      if (result == true) {
        Provider.of<UserProvider>(context, listen: false)
            .setCurrentUserDetails();
        Navigator.of(context).pushReplacementNamed(PrayerScreen.routeName);
      }
    } else {
      showInSnackBar(result.toString());
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: context.offWhite,
        content: new Text(value),
      ),
    );
  }

  @override
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
                                    submitForm: () => _authenticate(),
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
                                    Navigator.of(context).pushNamed(
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
                      Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: _authenticate,
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
                              Navigator.of(context)
                                  .pushNamed(ForgetPassword.routeName);
                            },
                          ),
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
