import 'package:be_still/screens/security/login/login_screen.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';

class ForgetPasswordSucess extends StatefulWidget {
  static const routeName = 'forgot-password-success';

  @override
  _ForgetPasswordSucessState createState() => _ForgetPasswordSucessState();
}

class _ForgetPasswordSucessState extends State<ForgetPasswordSucess> {
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) => Future.delayed(
    //     Duration(milliseconds: 10000),
    //     () => Navigator.of(context).pushReplacementNamed(LoginScreen.routeName),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 100),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
          image: DecorationImage(
            image:
                AssetImage(StringUtils.getBackgroundImage(Settings.isDarkMode)),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Password reset email has been sent to your email address.',
              style: AppTextStyles.regularText15,
            ),
            SizedBox(height: 80),
            Text(
              'New password must be at Least 6 characters long and contain at least 1 lowercase, 1 uppercase and 1 number.',
              style: AppTextStyles.errorText,
            ),
            // SizedBox(height: 20),
            // Text(
            //   'Login to your BesStill...',
            //   style: AppTextStyles.regularText15,
            // ),
          ],
        ),
      ),
    );
  }
}
