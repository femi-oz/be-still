import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';

class ForgetPasswordSucess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            'Your password has been succesfully reset.',
            style: TextStyle(
              color: context.inputFieldText,
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
          ),
          Text(
            'Login to your BesStill...',
            style: TextStyle(
              color: context.inputFieldText,
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
