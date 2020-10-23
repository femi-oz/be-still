import 'package:be_still/data/user.data.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/widgets/auth_screen_painter.dart';
import 'package:be_still/widgets/dialog.dart';
import 'package:be_still/widgets/snackbar.dart';
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
  final _key = GlobalKey<State>();

  _login() async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    await BeStilDialog.showLoading(
        context, _key, context.brightBlue, 'Authenticating');
    try {
      final result =
          await Provider.of<AuthenticationProvider>(context, listen: false)
              .login(
        context: context,
        email: _usernameController.text,
        password: _passwordController.text,
      );
      if (result) {
        BeStilDialog.hideLoading(_key);
        await Provider.of<UserProvider>(context, listen: false)
            .setCurrentUser();
        Navigator.of(context).pushReplacementNamed(PrayerScreen.routeName);
      }
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(_key);
      BeStillSnackbar.showInSnackBar(
          message: 'Username or Password is incorrect.', key: _scaffoldKey);
    } catch (e) {
      BeStilDialog.hideLoading(_key);
      BeStillSnackbar.showInSnackBar(
          message: 'An error occured. Please try again', key: _scaffoldKey);
    }
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
                                    submitForm: () => _login(),
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
                            onTap: _login,
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
