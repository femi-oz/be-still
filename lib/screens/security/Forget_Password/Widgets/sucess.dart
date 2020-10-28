import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class ForgetPasswordSucess extends StatelessWidget {
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
