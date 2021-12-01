import 'dart:io';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/screens/security/Forget_Password/Widgets/sucess.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
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
  var notificationType = NotificationType.email;
  bool emailSent = false;
  bool _autoValidate = false;
  final _key = GlobalKey<FormFieldState>();

  _forgotPassword() async {
    setState(() => _autoValidate = true);
    if (!_formKey1.currentState.validate()) return;
    _formKey1.currentState.save();
    try {
      BeStilDialog.showLoading(context, 'Sending Mail');
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .sendPasswordResetEmail(_emailController.text);

      setState(() => step += 1);
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);

      BeStilDialog.showErrorDialog(context, e, null, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);

      BeStilDialog.showErrorDialog(context, e, null, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.backgroundColor,
                ),
                image: DecorationImage(
                  image: AssetImage(StringUtils.backgroundImage),
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(
                      AppColors.backgroundColor[0].withOpacity(0.2),
                      BlendMode.dstATop),
                ),
              ),
              child: Column(
                children: <Widget>[
                  CustomLogoShape(),
                  Container(
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.67,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'RECOVER PASSWORD',
                          style: AppTextStyles.boldText24.copyWith(
                              color: Settings.isDarkMode
                                  ? AppColors.lightBlue3
                                  : AppColors.grey2),
                        ),
                        SizedBox(height: 40),
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
                                      : Column(
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Container(
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(AppColors
                                                                  .lightBlue3),
                                                      padding: MaterialStateProperty
                                                          .all<EdgeInsetsGeometry>(
                                                              EdgeInsets.zero),
                                                      elevation:
                                                          MaterialStateProperty
                                                              .all<double>(0.0),
                                                    ),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.42,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              AppColors.grey),
                                                      margin:
                                                          const EdgeInsets.all(
                                                              0),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 10,
                                                      ),
                                                      child: Text('Cancel',
                                                          style: AppTextStyles
                                                              .regularText16b
                                                              .copyWith(
                                                                  color: AppColors
                                                                      .white)),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                        context,
                                                        SlideRightRoute(
                                                          page: LoginScreen(),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Container(
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Colors
                                                                  .transparent),
                                                      padding: MaterialStateProperty
                                                          .all<EdgeInsetsGeometry>(
                                                              EdgeInsets.zero),
                                                      elevation:
                                                          MaterialStateProperty
                                                              .all<double>(0.0),
                                                    ),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.42,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: _emailController
                                                                .text.isEmpty
                                                            ? AppColors
                                                                .lightBlue4
                                                                .withOpacity(
                                                                    0.5)
                                                            : AppColors
                                                                .lightBlue4,
                                                      ),
                                                      margin:
                                                          const EdgeInsets.all(
                                                              0),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 10,
                                                      ),
                                                      child: Text(
                                                          'Send Password',
                                                          style: AppTextStyles
                                                              .regularText16b
                                                              .copyWith(
                                                                  color: AppColors
                                                                      .white)),
                                                    ),
                                                    onPressed: () {
                                                      _forgotPassword();
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 20.0),
                                          ],
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
      ),
    );
  }

  _buildEmailForm(BuildContext context) {
    return Form(
      key: _formKey1,
      // ignore: deprecated_member_use
      // autovalidate: _autoValidate,

      autovalidateMode: _autoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        children: <Widget>[
          CustomInput(
            textkey: _key,
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
              'An email will be sent to you. Please click on the link in the email to reset your password.',
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
