import 'package:be_still/utils/essentials.dart';
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
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => Future.delayed(
        Duration(milliseconds: 10000),
        () => Navigator.of(context).pop(),
      ),
    );
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
            Text(
              'Password reset email has been sent to your email address.',
              style: AppTextStyles.regularText15,
            ),
            SizedBox(height: 80),
            Text(
              'New password must be at least 6 characters long and contain at least 1 lowercase, 1 uppercase and 1 number.',
              style: AppTextStyles.errorText,
            ),
          ],
        ),
      ),
    );
  }
}
