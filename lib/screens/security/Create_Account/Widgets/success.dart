import 'package:flutter/material.dart';
import 'package:be_still/widgets/Theme/app_theme.dart';

class CreateAccountSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            'Your account has been succesfully created.',
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
