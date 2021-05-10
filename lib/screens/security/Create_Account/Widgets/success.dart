import 'package:be_still/screens/security/login/login_screen.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';

class CreateAccountSuccess extends StatefulWidget {
  static const routeName = 'create-account-success';

  @override
  _CreateAccountSuccessState createState() => _CreateAccountSuccessState();
}

class _CreateAccountSuccessState extends State<CreateAccountSuccess> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Future.delayed(
        Duration(milliseconds: 10000),
        () => Navigator.of(context).pushReplacement(
          SlideRightRoute(
            page: LoginScreen(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(50),
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
            colorFilter: new ColorFilter.mode(
                AppColors.backgroundColor[0].withOpacity(0.2),
                BlendMode.dstATop),
          ),
        ),
        child: Center(
          child: Text(
            'Your account registration has been initiated. \n\n Click the link provided in the email sent to you to complete the registration',
            style: AppTextStyles.regularText16b
                .copyWith(color: AppColors.lightBlue4),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
