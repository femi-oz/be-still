import 'dart:io';

import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/screens/security/Forget_Password/Widgets/sucess.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:be_still/widgets/snackbar.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool emailSent = false;

  _forgotPassword() async {
    // if (step == 1) {
    setState(() => _autoValidate1 = true);
    if (!_formKey1.currentState.validate()) return;
    _formKey1.currentState.save();
    // ForgetPasswordSucess();
    // Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    await Provider.of<AuthenticationProvider>(context, listen: false)
        .sendPasswordResetEmail(_emailController.text);
    // }
    // } else if (step == 2) {
    //   setState(() => _autoValidate2 = true);
    //   if (!_formKey2.currentState.validate()) return;
    //   _formKey2.currentState.save();
    //   await Provider.of<AuthenticationProvider>(context, listen: false)
    //       .confirmToken(_codeController.text);
    // } else if (step == 3) {
    //   setState(() => _autoValidate3 = true);
    //   if (!_formKey3.currentState.validate()) return;
    //   _formKey3.currentState.save();
    //   await Provider.of<AuthenticationProvider>(context, listen: false)
    //       .changePassword(_codeController.text, _passwordController.text);
    //   await Provider.of<UserProvider>(context, listen: false).setCurrentUser();
    // }
    // setState(() => step += 1);
    try {
      await BeStilDialog.showLoading(context, 'Sending Mail');
      setState(() => step += 1);
      // await Provider.of<AuthenticationProvider>(context, listen: false)
      //     .sendPasswordResetEmail(_emailController.text);
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundColor,
            ),
            image: DecorationImage(
              image: AssetImage(
                  StringUtils.getBackgroundImage(Settings.isDarkMode)),
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
                  height: MediaQuery.of(context).size.height * 0.67,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child:
                            // _buildEmailForm(context)
                            step == 1
                                ? _buildEmailForm(context)
                                // : step == 2
                                //     ? _buildTokenForm()
                                //     : step == 3
                                //         ? _buildPasswordForm()
                                : ForgetPasswordSucess(),
                      ),
                      step > 3
                          ? Container()
                          : Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => {
                                    setState(() {
                                      _forgotPassword();
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
    return Form(
      key: _formKey1,
      autovalidate: _autoValidate1,
      child: Column(
        children: <Widget>[
          CustomInput(
            label: 'Email Address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
            textInputAction: TextInputAction.done,
            unfocus: true,
          ),
          SizedBox(height: 40.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'An email will be sent to you. Please click on the link to reset your password',
              textAlign: TextAlign.center,
              style: AppTextStyles.regularText16b,
            ),
          ),
          SizedBox(height: 55.0),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: <Widget>[
          //     Container(
          //       height: 30,
          //       width: MediaQuery.of(context).size.width * 0.4,
          //       decoration: BoxDecoration(
          //         color: notificationType == NotificationType.email
          //             ? AppColors.activeButton.withOpacity(0.5)
          //             : Colors.transparent,
          //         border: Border.all(
          //           color: AppColors.cardBorder,
          //           width: 1,
          //         ),
          //         borderRadius: BorderRadius.circular(5),
          //       ),
          //       child: FlatButton(
          //         child: Text(
          //           NotificationType.email.toUpperCase(),
          //           style: AppTextStyles.regularText15,
          //         ),
          //         onPressed: () {
          //           setState(
          //             () {
          //               notificationType = NotificationType.email;
          //             },
          //           );
          //         },
          //       ),
          //     ),
          //     Container(
          //       height: 30,
          //       width: MediaQuery.of(context).size.width * 0.42,
          //       decoration: BoxDecoration(
          //         color: notificationType == NotificationType.text
          //             ? AppColors.activeButton.withOpacity(0.5)
          //             : Colors.transparent,
          //         border: Border.all(
          //           color: AppColors.cardBorder,
          //           width: 1,
          //         ),
          //         borderRadius: BorderRadius.circular(5),
          //       ),
          //       child: FlatButton(
          //         child: Text(
          //           NotificationType.text.toLowerCase(),
          //           style: AppTextStyles.regularText15,
          //         ),
          //         onPressed: () {
          //           setState(
          //             () {
          //               notificationType = NotificationType.text;
          //             },
          //           );
          //         },
          //       ),
          //     ),
          //   ],
          // )
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
