import 'package:be_still/screens/Prayer/prayer_screen.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class ForgetPasswordSucess extends StatefulWidget {
  static const routeName = 'forgot-password-success';

  @override
  _ForgetPasswordSucessState createState() => _ForgetPasswordSucessState();
}

class _ForgetPasswordSucessState extends State<ForgetPasswordSucess> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Future.delayed(
        Duration(milliseconds: 3000),
        () =>
            Navigator.of(context).pushReplacementNamed(PrayerScreen.routeName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            'Your password has been succesfully reset.',
            style: AppTextStyles.regularText16,
          ),
          SizedBox(height: 20),
          Text(
            'Login to your BesStill...',
            style: AppTextStyles.regularText16,
          ),
        ],
      ),
    );
  }
}
