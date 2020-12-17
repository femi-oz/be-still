import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/security/Forget_Password/Widgets/sucess.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgetPassword extends StatefulWidget {
  static const routeName = '/forget-password';

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  int step = 1;
  TextEditingController _emailController = TextEditingController();
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
  var notificationType = NotificationType.email;

  _next() async {
    if (step == 1) {
      setState(() => _autoValidate1 = true);
      if (!_formKey1.currentState.validate()) return;
      _formKey1.currentState.save();
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .sendVerificationEmail(_emailController.text);
    } else if (step == 2) {
      setState(() => _autoValidate2 = true);
      if (!_formKey2.currentState.validate()) return;
      _formKey2.currentState.save();
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .confirmToken(_codeController.text);
    } else if (step == 3) {
      setState(() => _autoValidate3 = true);
      if (!_formKey3.currentState.validate()) return;
      _formKey3.currentState.save();
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .changePassword(_codeController.text, _passwordController.text);
      await Provider.of<UserProvider>(context, listen: false).setCurrentUser();
    }
    setState(() => step += 1);
  }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        body: Container(
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
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: step == 1
                            ? _buildEmailForm(context)
                            : step == 2
                                ? _buildTokenForm()
                                : step == 3
                                    ? _buildPasswordForm()
                                    : ForgetPasswordSucess(),
                      ),
                      step > 3
                          ? Container()
                          : Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => {
                                    setState(() {
                                      _next();
                                    })
                                  },
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
                                      Icons.arrow_forward,
                                      color: AppColors.offWhite1,
                                    ),
                                  ),
                                ),
                                step > 2
                                    ? Container()
                                    : GestureDetector(
                                        child: Text(
                                          "Go Back",
                                          style: AppTextStyles.regularText13,
                                        ),
                                        onTap: () {
                                          if (step == 1) {
                                            Navigator.of(context).pop();
                                          } else {
                                            setState(() {
                                              step -= 1;
                                            });
                                          }
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

  _buildEmailForm(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Form(
      key: _formKey1,
      autovalidate: _autoValidate1,
      child: Column(
        children: <Widget>[
          CustomInput(
            label: 'Email Address',
            controller: _emailController,
            keyboardType: TextInputType.text,
            isRequired: true,
            textInputAction: TextInputAction.done,
            unfocus: true,
          ),
          SizedBox(height: 40.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'How would you like to recieve your password reset code?',
              textAlign: TextAlign.center,
              style: AppTextStyles.regularText16b,
            ),
          ),
          SizedBox(height: 55.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  color: notificationType == NotificationType.email
                      ? AppColors.getActiveBtn(_themeProvider.isDarkModeEnabled)
                          .withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.getCardBorder(
                        _themeProvider.isDarkModeEnabled),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FlatButton(
                  child: Text(
                    NotificationType.email.toUpperCase(),
                    style: AppTextStyles.regularText16,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        notificationType = NotificationType.email;
                      },
                    );
                  },
                ),
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.42,
                decoration: BoxDecoration(
                  color: notificationType == NotificationType.text
                      ? AppColors.getActiveBtn(_themeProvider.isDarkModeEnabled)
                          .withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.getCardBorder(
                        _themeProvider.isDarkModeEnabled),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FlatButton(
                  child: Text(
                    NotificationType.text.toUpperCase(),
                    style: AppTextStyles.regularText16,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        notificationType = NotificationType.text;
                      },
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _buildTokenForm() {
    return Form(
      autovalidate: _autoValidate2,
      key: _formKey2,
      child: Column(
        children: <Widget>[
          CustomInput(
            label: 'Enter Code',
            controller: _codeController,
            keyboardType: TextInputType.number,
            isRequired: true,
          ),
          SizedBox(height: 10.0),
          CustomInput(
            label: 'Confirm Code',
            controller: _confirmcodeController,
            keyboardType: TextInputType.number,
            isRequired: true,
            validator: (value) {
              if (_codeController.text != value) {
                return 'Password fields do not match';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            unfocus: true,
          ),
        ],
      ),
    );
  }

  _buildPasswordForm() {
    return Form(
      key: _formKey3,
      autovalidate: _autoValidate3,
      child: Column(
        children: <Widget>[
          CustomInput(
            isPassword: true,
            label: 'New Password',
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            isRequired: true,
          ),
          SizedBox(height: 10.0),
          CustomInput(
            isPassword: true,
            controller: _confirmPasswordController,
            keyboardType: TextInputType.visiblePassword,
            isRequired: true,
            label: 'Confirm Password',
            textInputAction: TextInputAction.done,
            unfocus: true,
            validator: (value) {
              if (_passwordController.text != value) {
                return 'Password fields do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
