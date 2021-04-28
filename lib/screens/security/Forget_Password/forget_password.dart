import 'dart:io';
import 'package:be_still/enums/notification_type.dart';
import 'package:be_still/providers/auth_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/screens/security/Forget_Password/Widgets/sucess.dart';
import 'package:be_still/screens/security/Login/login_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_logo_shape.dart';
import 'package:be_still/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
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
  bool disabled = false;

  _forgotPassword() async {
    if (!disabled) {
      setState(() => _autoValidate = true);
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
  }

  @override
  Widget build(BuildContext context) {
    disabled = Provider.of<MiscProvider>(context).disable;

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
                  image: AssetImage(
                      StringUtils.backgroundImage(Settings.isDarkMode)),
                  alignment: Alignment.bottomCenter,
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
                                                        vertical: 20,
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
                                                      Settings.rememberMe
                                                          ? Provider.of<
                                                                      MiscProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .setVisibility(
                                                                  false)
                                                          : Provider.of<
                                                                      MiscProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .setVisibility(
                                                                  true);
                                                      Navigator
                                                          .pushAndRemoveUntil(
                                                        context,
                                                        PageTransition(
                                                            type: PageTransitionType
                                                                .rightToLeftWithFade,
                                                            child:
                                                                LoginScreen()),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false,
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
                                                        color: Colors.blue,
                                                      ),
                                                      margin:
                                                          const EdgeInsets.all(
                                                              0),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 20,
                                                        horizontal: 10,
                                                      ),
                                                      child: Text(
                                                          'Send Password',
                                                          style: disabled
                                                              ? AppTextStyles
                                                                  .regularText16b
                                                                  .copyWith(
                                                                      color: AppColors
                                                                          .grey)
                                                              : AppTextStyles
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
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      autovalidate: _autoValidate,
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
