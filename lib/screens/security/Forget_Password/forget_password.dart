import 'dart:io';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/screens/security/Forget_Password/Widgets/sucess.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
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
  final _formKey1 = GlobalKey<FormState>();
  bool _autoValidate1 = false;
  var notificationType = NotificationType.email;
  bool emailSent = false;

  _forgotPassword() async {
    setState(() => _autoValidate1 = true);
    if (!_formKey1.currentState.validate()) return;
    _formKey1.currentState.save();
    try {
      await BeStilDialog.showLoading(context, 'Sending Mail');
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .sendPasswordResetEmail(_emailController.text);

      setState(() => step += 1);
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
              image:
                  AssetImage(StringUtils.backgroundImage(Settings.isDarkMode)),
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
                        child: step == 1
                            ? _buildEmailForm(context)
                            : ForgetPasswordSucess(),
                      ),
                      step > 3
                          ? Container()
                          : Column(
                              children: <Widget>[
                                step > 1
                                    ? Container()
                                    : GestureDetector(
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
                                            AppIcons.bestill_next_arrow,
                                            color: AppColors.offWhite4,
                                          ),
                                        ),
                                      ),
                                step > 3
                                    ? Container()
                                    : GestureDetector(
                                        child: Text(
                                          "Go Back",
                                          style: AppTextStyles.regularText13,
                                        ),
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  LoginScreen.routeName);
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
              style: AppTextStyles.regularText16b.copyWith(
                color: AppColors.prayerTextColor,
              ),
            ),
          ),
          SizedBox(height: 55.0),
        ],
      ),
    );
  }
}
